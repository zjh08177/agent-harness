---
name: auto-debug
description: Fully autonomous issue troubleshooting workflow. 5 phases per bug — Reproduce, Diagnose, Fix, Verify, Conclude. Uses pua-debugging skill as core debugging engine. Deploys parallel diverse sub-agents for root-cause analysis and fix review, with meta-judge terminated rounds. Supports bug lists — processes sequentially, commits separately, reports summary. This skill should be used when the user invokes "auto-debug", reports a bug or bug list, encounters errors, or needs autonomous issue troubleshooting.
---

# Auto Debug

**Use `pua:pua-debugging` throughout all phases. Never give up. Never deflect.**

## Configuration

| Param | Alias | Default | Syntax | Effect |
|---|---|---|---|---|
| `agents` | `a` | 4 | `auto-debug a=8` | Minimum sub-agents for diagnosis/review |
| `rounds` | `r` | 2 | `auto-debug r=3` | Minimum review rounds |
| `max_rounds` | `mr` | 3 | `auto-debug mr=4` | Hard cap |
| `codex` | `cx` | off | `auto-debug cx=on` | Replace Claude subagents (diagnose + review) with parallel `codex exec` |
| `cursor` | `cs` | off | `auto-debug cs=on` | Replace Claude subagents (diagnose + review) with parallel `cursor-agent`. Mutually exclusive with `cx=on`. |

Combine: `auto-debug a=6 r=3 cx=on` or `auto-debug a=6 cs=on`

**Lightweight** (`light`): ≤2 files, obvious root cause — skip TeamCreate, planning files, vault routing. Diagnose + fix inline, no sub-agents. Phase 4 verification still runs. Use when fix is a clear one-liner.

## Prerequisites

Read at session start:
- `~/.claude/skills/shared/SKILL_BASE.md` — Team Setup, Branch Safety, Autonomous Decisions, Scope Lock, Fault Tolerance, Self-Review, Team Cleanup
- `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` — Review prompts, Reviewer Diversity, Round-Phase Rules, convergence
- `~/.claude/skills/shared/META_JUDGE.md` — Round-boundary terminator
- `~/.claude/skills/shared/CODEX_REVIEW.md` — **read only if `cx=on`**

## Codex review mode (`codex=on`)

Every Claude subagent in Phase 2 (Diagnose) + Phase 3 (Fix review) replaced 1:1 by parallel `codex exec`. N, roles, hypothesis structure, Constitution, rounds unchanged.

Preflight from `CODEX_REVIEW.md`. Codex unavailable → degrade to `codex=off`, tell user.

Per phase:
1. Build `_CX_ROLE_NAMES` + `_CX_ROLE_PROMPTS` from phase's agent table (one codex per role, Constitution inlined, artifact attached)
2. Launch via parallel block in `CODEX_REVIEW.md`
3. Apply degradation matrix
4. Merge findings, apply convergence rules identically

Artifact handoff:
- Phase 2 (Diagnose) — bug report + stack trace + reproduction steps + hypothesis (per role) → temp file
- Phase 3 (Fix review) — `git diff` patch + Phase 2 root-cause summary (Constitution's cold-review exception for bug fixes applies)
- Phase 4 (Test Analyzer) — test diff + reproduction-step list

Anti-confirmation-bias from Phase 2 (disprove your hypothesis, not prove it) stays in each codex prompt.

**Skills:**
- `pua:pua-debugging` for all debugging — non-negotiable
- `superpowers:systematic-debugging` for structured root-cause analysis
- Code review skills for fix review
- Proactively search for best existing skill for other work

### Environment Setup

Verify environment before any debugging:
1. Python: `source .venv/bin/activate` (worktrees use main repo's venv)
2. Node: verify `node_modules`, run `npm install` if missing
3. Run project's test suite for baseline (green = good, failures = pre-existing)
4. Fix environment setup before proceeding if it fails

Each sub-agent must also activate the project environment. Include env activation in every agent prompt.

## Bug List Handling

Multiple bugs:
- Triage first. Order by severity (blockers first) then dependency.
- Process each through Phase 1-4 sequentially. One bug = one commit.
- Independent non-overlapping bugs → dispatch parallel agents.
- After all fixes, run Phase 5 once for the batch.
- Report summary table at end.

## Phase 1 — Reproduce

Reproduce the issue reliably.

- Read bug report, error message, stack trace, user description
- Read all relevant code, logs, configuration
- Reproduce locally. UI bug → Playwright MCP to trigger.
- Not reproducible → investigate deeper: environment differences, timing, races, data-dependent paths. Do not give up.
- Document exact reproduction steps.

## Phase 2 — Diagnose

Find the root cause. Specialized sub-agents in parallel.

Spawn ≥N investigation teammates. Distribute evenly; remainders to Debugger.

| Agent Type | `subagent_type` | `model` | Role |
|---|---|---|---|
| Debugger | `debugger` | `sonnet` | Systematic root-cause, stack trace interpretation, hypothesis testing |
| Code Explorer | `feature-dev:code-explorer` | `sonnet` | Execution paths, architecture mapping, bug entry point |

**Diversity floor** (per Constitution §Reviewer Diversity): ≥2 distinct types. Homogeneous pools rejected.

**Anti-confirmation-bias**: Generate ≥3 competing hypotheses before investigating any. Each agent MUST try to DISPROVE its assigned hypothesis, not prove it. Require disconfirming evidence before accepting any root cause.

Assign hypothesis tasks via `TaskUpdate`. Focus on root cause, not symptoms.

Collect findings. Identify root cause. If unclear → new hypotheses, re-assign. End-of-round meta-judge. Repeat min R rounds, cap at `max_rounds`.

Confirm root cause with evidence (code path, log output, or reproducible test).

**Root cause summary**: Write 3-5 sentence artifact. Passed to Phase 3 reviewers as cold-review exception — fix review needs root-cause context.

## Phase 3 — Fix

Implement the fix.

- Design minimal correct fix. No over-engineering. Fix root cause, not symptom.
- Implement.
- Spawn ≥N review teammates. Distribute evenly; remainders to Code Reviewer.

| Agent Type | `subagent_type` | `model` | Role |
|---|---|---|---|
| Code Reviewer | `feature-dev:code-reviewer` | `sonnet` | Confidence-based — logic errors, correctness, regression risk |
| Silent Failure Hunter | `pr-review-toolkit:silent-failure-hunter` | `sonnet` | Error handling — swallowed exceptions, inadequate fallbacks, missing propagation |

Diversity floor applies.

**Reviewer Constitution (MANDATORY):** Include full content. Pass diff + Phase 2 root-cause summary (debugging-specific cold-review exception — reviewers need root-cause context to judge if fix addresses the actual problem).

Collect verdicts. Address feedback. End-of-round meta-judge. Repeat per Constitution rules.

## Phase 4 — Verify

1. Confirm original issue no longer reproduces. Run exact Phase 1 reproduction steps.
2. All existing tests pass. No regressions. Do not modify tests to pass.
3. Write new tests covering the bug. Must FAIL without fix, PASS with it.
4. UI bug → Playwright MCP to verify visually.
5. Think of related edge cases. Test them.
6. Spawn 1 **Test Analyzer** (`pr-review-toolkit:pr-test-analyzer`, `sonnet`) for coverage completeness.

### Real API/LLM Verification (MANDATORY for model/API bugs)

1. REAL API call through actual code path
2. Inspect REAL output — verify correctness
3. Log evidence. "It works" without evidence ≠ verification.
4. If fails → fix is incomplete. Do NOT commit. Debug further.

## Phase 5 — Conclusion

Follow SKILL_BASE.md Self-Review + Promote Findings.

### Commit and Memory

Store memory (including self-review answers) + commit (one per bug, or one batch commit if trivially related).

Multiple bugs → summary table:

| Bug | Root Cause | Fix | Status |
|---|---|---|---|
| ... | ... | ... | Fixed / Partial / Blocked |

Follow SKILL_BASE.md Team Cleanup.
