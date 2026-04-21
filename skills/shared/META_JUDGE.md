# Meta-Judge — Round Boundary Terminator

Included by auto-workflow / auto-explore / auto-debug at each round boundary. Computes 5 boolean terminator signals from the round's findings; any ONE triggers early exit.

Pattern: AutoGen 0.4 compound-termination (ref: [migration guide](https://github.com/microsoft/autogen/blob/main/python/docs/src/user-guide/agentchat-user-guide/migration-guide.md)). Convergence metric: Shannon-entropy delta on finding-type distribution ([2025 research](https://arxiv.org/html/2602.04234v4)).

## Inputs

- **Round N findings** — list of issues, each tagged with `FINDING_CATEGORIES` per `REVIEWER_CONSTITUTION.md` Output Contract: `architectural | spec-completeness | cross-doc-drift | wire-format | new-lens`
- **Round N-1 findings** — same shape
- **Round N verdicts** — per-reviewer `VERDICT` + `CONFIDENCE`
- **Config** — `max_rounds` from skill, `exit_criteria:` from doc frontmatter

## Terminator signals (boolean OR)

```
terminate = max_rounds_hit
         | no_new_arch_category
         | constitution_soft_convergence
         | entropy_delta_low
         | drift_only_this_round
```

| Signal | Definition | Rationale |
|---|---|---|
| `max_rounds_hit` | round_number ≥ max_rounds | Hard cap. Forces Post-R3 Gate decision. |
| `no_new_arch_category` | no finding in round N tagged `architectural` that wasn't already in N-1 | Architecture has stabilized. Post-R3 findings are spec-completeness. |
| `constitution_soft_convergence` | all verdicts ACCEPT/AWW/READY AND avg_confidence ≥ 75 AND no new issue categories | Existing Constitution rule. Re-evaluated here for discoverability. |
| `entropy_delta_low` | `abs(H_N − H_{N-1}) < 0.1` where H = Shannon entropy of finding-category distribution | Distribution of finding types stable → no new discovery |
| `drift_only_this_round` | ≥80% of findings tagged `cross-doc-drift` | Drift pre-check (D7) should handle pre-dispatch; STOP + re-run drift check before next round |

## Outputs

One-line verdict:
- `CONTINUE` — none of the signals fired; next round legitimate
- `CLOSE_WITH_BACKLOG` — one or more signals fired; ship to next phase, residuals → `findings-NNN-*.md`
- `STOP` — `drift_only_this_round` fired; re-run `drift-check.py` before any further dispatch

Plus a 3-line evidence block: which signals fired, entropy values, new-architectural-count.

## Finding taxonomy

| Category | Examples | Contributes to entropy | Gates `no_new_arch_category`? |
|---|---|---|---|
| architectural | SRP violation, wrong concurrency primitive, unsound invariant, missing contract | ✓ | ✓ |
| spec-completeness | Missing edge case in prose, unspecified error path, undocumented default | ✓ | ✗ |
| cross-doc-drift | L3 doesn't match L1, appendix claim missing in body, stale example | ✓ | ✗ |
| wire-format | NaN, Unicode escape, int64 boundary, byte-ordering | ✗ (delegated to parity corpus) | ✗ |
| new-lens | Reviewer added previously-unreviewed lens (e.g., Go portability) | Re-classify by sub-category | By sub-category |

## Precedence with Post-Round-3 Gate (existing, in Constitution)

- **Rounds 1–3**: meta-judge signals are ADVISORY. Lead may override with rationale in `findings.md`.
- **End of round 3**: meta-judge output becomes DEFAULT input to Post-R3 Gate `AskUserQuestion`. If ANY terminate signal fires, default option = (a) ship to impl-plan.
- **Rounds 4+** (user picked option c, narrow closure): meta-judge BINDS. Any terminate signal halts immediately.

## Dispatch

From auto-workflow / auto-explore / auto-debug end-of-round hook, dispatch a single agent with this prompt:

```
You are the Meta-Judge for round N of <artifact>.

ROUND N FINDINGS (grouped by FINDING_CATEGORIES):
<paste findings with categories>

ROUND N-1 FINDINGS (grouped by FINDING_CATEGORIES):
<paste prior findings>

CONFIG: max_rounds=<N>, exit_criteria=<yaml from doc frontmatter>

Compute:
1. max_rounds_hit? (round_number >= max_rounds)
2. no_new_arch_category? (no round-N 'architectural' finding absent from round N-1)
3. constitution_soft_convergence? (all verdicts ACCEPT/AWW/READY, avg conf >=75, no new cats)
4. entropy_delta_low? (|H_N - H_{N-1}| < 0.1, Shannon on category distribution)
5. drift_only_this_round? (>=80% findings tagged cross-doc-drift)

Emit:
- terminate: CONTINUE | CLOSE_WITH_BACKLOG | STOP
- signals_fired: [list]
- entropy_N: <float>
- entropy_N_minus_1: <float>
- new_arch_count: <int>
- one-sentence rationale

Do NOT evaluate the spec itself. Only the findings delta.
```

Model: `sonnet` by default. Use `codex exec` when `cx=on` (independent lens).

## Override tracking

Lead overrides of meta-judge verdict must include rationale in `findings.md` with tag `[meta-judge-override]`. If override rate exceeds 20% across 5+ projects, escalate: either tune the prompt OR switch to OpenAI-style handoff pattern ([cookbook](https://cookbook.openai.com/examples/orchestrating_agents)) where each reviewer returns explicit next-agent target instead of a central classifier.
