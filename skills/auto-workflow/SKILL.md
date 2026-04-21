---
name: auto-workflow
description: Fully autonomous development workflow with 8 phases — Context Gathering, Red Team, Tech Solution, Implementation Planning, Implementation, Code Review, Testing, Conclusion. ERD must exist before invoking. Orchestrates N parallel diverse review sub-agents per phase (default 5) with meta-judge terminated review loops (min 3, max 3 rounds, configurable). This skill should be used when the user invokes "auto-workflow", requests a full autonomous development cycle, or needs a rigorous multi-phase engineering process with heavy agent-based review.
---

# Workflow Heavy

## Configuration

| Param | Alias | Default | Syntax | Effect |
|-------|-------|---------|--------|--------|
| `agents` | `a` | 5 | `auto-workflow a=8` | Minimum sub-agents per review phase |
| `rounds` | `r` | 3 | `auto-workflow r=5` | Minimum review loop iterations |
| `max_rounds` | `mr` | 3 | `auto-workflow mr=4` | Hard cap on review rounds. After this, Post-R3 Gate fires REQUIRED. |
| `intensity` | `i` | balanced | `auto-workflow i=ruthless` | Red Team intensity (gentle/balanced/ruthless) |
| `light` | — | off | `auto-workflow light` | Lightweight mode for ≤3 file changes |
| `gate` | — | none | `auto-workflow gate=tech-solution` | Halt for user approval at specified phase |
| `verify` | — | off | `auto-workflow verify=true` | Add false-positive verification pass to reviews |
| `codex` | `cx` | off | `auto-workflow cx=on` | Replace every Claude subagent reviewer with `codex exec` (same N, same roles, same Constitution) |

## Prerequisites

Read at session start:
- `~/.claude/skills/shared/SKILL_BASE.md` — Team Setup, Branch Safety, Execution, Autonomous Decisions, Scope Lock, Research Gate, Fault Tolerance, Self-Review, Team Cleanup
- `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` — Review prompts, Reviewer Diversity mandate, Round-Phase Rules, convergence criteria
- `~/.claude/skills/shared/META_JUDGE.md` — Round-boundary terminator (5 boolean signals, meta-judge dispatch)
- `~/.claude/skills/shared/CODEX_REVIEW.md` — **read only if `codex=on`.** Preflight, parallel invocation, degradation matrix.

## Codex review mode (`codex=on`)

Every reviewer in Phases 1-3, 5, 6 replaced 1:1 by parallel `codex exec`. N, roles, focus, Constitution, rounds unchanged — provider switches.

Before any review phase: Preflight block from `CODEX_REVIEW.md`. If Codex unavailable → degrade whole session to `codex=off` and tell user.

Per phase:
1. Build `_CX_ROLE_NAMES` + `_CX_ROLE_PROMPTS` from phase's reviewer table (inline Constitution, append artifact path)
2. Launch via parallel block in `CODEX_REVIEW.md` (N background calls, `wait`, collect outputs per role)
3. Apply degradation matrix
4. Merge findings, apply convergence rules identically

Artifact handoff per phase:
- Phase 1 (Red Team) — ERD path (repo-relative or temp-copied)
- Phase 2 (Tech Solution) — tech-solution doc path
- Phase 3 (Impl Plan) — impl plan + problem-context-only ERD summary
- Phase 5 (Code Review) — `git diff` patch written to temp file
- Phase 6 (Test Analyzer) — diff + test file list

Cold-review exceptions unchanged (design docs allow rationale eval; code review stays cold).

**Lightweight mode** (`light`): ≤3 files changed — skip TeamCreate, planning files, vault doc routing, all agent spawns. All phases inline with main agent. Phase 1 Red Team = inline analysis. Phases 2/3/5 reviews = lead direct via Constitution. Phase 6 testing still runs fully.

**Skills:**
- `superpowers` for planning + coding
- `pua-debugging` for debugging
- Code review skills for review
- `ai-multimodal`, `seedance`, other prompting skills for prompt-engineering
- Proactively search for best existing skill for other work

## Phase 0 — Context Gathering

### Doc Output Routing

Save specs + design docs to **second-brain vault** per Project Folder Convention in user-scope CLAUDE.md.

| Phase output | `doc_type` | Template |
|---|---|---|
| ERD | `erd` | `note-template` |
| Tech Solution | `tech-solution` | `note-template` |
| Implementation Plan | `impl-plan` | `note-template` |
| Design Decision | `decision` | `decision-template` |

### Context Reading

**ERD must already exist.** Phase 0 reads context, doesn't write docs.

1. Read ERD (path in args or recent vault docs)
2. Read all source files referenced in ERD
3. Read existing tests, CLAUDE.md, relevant docs
4. Search MCP memory for prior decisions
5. Understand current codebase state before design
6. Declare deliverable: "Deliverable: [artifact path or commit description]"
7. **Declare scope** per `SKILL_BASE.md §Scope Lock`: in-scope list, out-of-scope list, scope owner. Lock before Phase 1.
8. **Read `exit_criteria:` block** from doc frontmatter if present; use as meta-judge config.

## Phase 1 — Red Team (Question the ERD)

> A perfect implementation of the wrong idea is still wrong.

**Intensity:**
- `gentle` (default ≤3 file changes) — flag disproven premises + clear over-engineering only
- `balanced` (default) — first-principles + community search + 2-3 alternatives
- `ruthless` — balanced + pre-mortem + force 3-5 competing hypotheses ranked by simplicity

Spawn TWO Red Team agents in parallel:

### Agent 1: CEO/First-Principles Validator

`general-purpose` agent. Uses `plan-ceo-review` skill methodology.

**Prompt**: "You are an adversarial premise validator. Find reasons this ERD should NOT proceed. Invoke `plan-ceo-review`:
1. List every premise (explicit + hidden)
2. Flag unverified premises — assumptions on faith
3. Flag over-engineering — simpler approach for 80%+ goal?
4. Generate 2-3 genuinely different alternatives BEFORE validating (reduces anchoring)
5. Use `WebSearch` for 2-3 reference implementations of similar problems
6. Verdict: PROCEED or HALT (which premises failed + why). If PROCEED, rank ERD vs alternatives."

### Agent 2: Codebase Evidence Gatherer

`subagent_type: "feature-dev:code-explorer"`, `model: "sonnet"`.

**Prompt**: "Search codebase for evidence validating/disproving ERD premises. For each premise:
1. How is this model/API/tool ACTUALLY used today?
2. Existing patterns contradict proposed approach?
3. Hidden dependencies ERD doesn't account for?
4. Flag codebase-contradicted premises with file:line references."

### Verdict

Merge findings. **HALT**: `AskUserQuestion` to surface disproven premise. Wait for redirect. **PROCEED**: Continue.

## Phase 2 — Tech Solution + Agent Review

Design the technical solution. Write **Tech Solution** doc:
- Architecture, file decomposition
- Key design decisions, AB-gate strategy
- Testing strategy, migration plan

### Layer-split preflight (MANDATORY before Round 1)

BEFORE dispatching Round 1, check:
- Touches ≥3 execution layers (e.g. schema + runtime + editor + Go + migrations)?
- Draft >1000 lines?

If YES → split into `tech-solution-l1-<topic>.md` / L2 / Ln BEFORE Round 1 dispatch. Each layer gets its own round counter + `exit_criteria:` block. Cross-layer drift tracked by drift pre-check hook. Monolithic drafts past ~1500 lines → drift near-certain.

Rationale: control-flow monolith hit 1,716 lines before r7 split. Post-split L3 drifted on every L1 revision, costing one full round per drift incident. Split at r0 avoids this.

### Review dispatch

Spawn ≥N review teammates using opus. Distribute evenly; last type gets remainders.

| Agent Type | `subagent_type` | `model` | Role |
|---|---|---|---|
| Backend Architect | `backend-architect` | `opus` | API design, data flow, scalability, performance |
| Frontend Developer | `frontend-developer` | `opus` | UI architecture, state management, component design |
| Code Architect | `feature-dev:code-architect` | `opus` | Overall architecture, patterns, module cohesion, SOLID |

**Diversity floor** (per Constitution §Reviewer Diversity): dispatch must include ≥2 distinct types OR ≥1 codex session. Homogeneous pools rejected.

**Reviewer Constitution (MANDATORY):** Include full content in each reviewer's prompt. Design doc → reviewers SHOULD evaluate stated rationale. Pass tech solution WITHOUT lead's conversational reasoning.

Collect structured verdicts. Update design. Per-round end: invoke meta-judge (`META_JUDGE.md`) to compute terminator signals. Repeat per Constitution rules.

### Research Gate trigger

If any reviewer raises a scope-level question, pause reviews and invoke per `SKILL_BASE.md §Research Gate`. Resume with research findings in context.

**Gate**: Skip by default. `gate=tech-solution` → halt for user approval via `AskUserQuestion`.

## Phase 3 — Implementation Planning + Agent Review

Write concrete **Implementation Plan**:
- Task breakdown with clear boundaries
- File list per task
- Parallel execution waves — independent vs sequential
- Verification steps per task
- Integration points — where tasks connect, merge order

### Parity corpus requirement (MANDATORY for cross-runtime specs)

Ships BEFORE any closure round (Wasm/test262 pattern — [testsuite](https://github.com/WebAssembly/testsuite), [test262](https://github.com/tc39/test262)):
- `{feature}_corpus.json` ≥50 entries per wire-format concern (Unicode, int64-boundary, HTML-escape, signed-zero, BOM, NaN, byte-ordering)
- CI harness comparing Python / Go / TS implementations byte-for-byte
- Corpus PR merged BEFORE closure rounds

Rationale: wire-format edge cases are asymptotically detailable by reviewers. Corpus catches in ms what takes N rounds in prose.

### Review dispatch

Spawn ≥N review teammates using `subagent_type: "Plan"`, `model: "sonnet"`. Apply diversity floor.

**Reviewer Constitution (MANDATORY):** Include in each prompt. Pass impl plan + problem-context-only ERD summary (strip solution-space — describe problem, not approach).

Collect verdicts. Update plan. End-of-round meta-judge. Repeat per Constitution rules.

**Gate**: Skip by default. `gate=impl-plan` → halt for user approval.

## Phase 4 — Implementation

Execute the plan. `TaskCreate` for impl tasks, spawn teammates with `isolation: "worktree"` for parallel file-safe work, assign via `TaskUpdate`.

## Phase 5 — Code Review + /simplify

### Code Review

Spawn ≥N review teammates. Distribute evenly; remainders to Code Reviewer.

| Agent Type | `subagent_type` | `model` | Role |
|---|---|---|---|
| Code Reviewer | `feature-dev:code-reviewer` | `sonnet` | Confidence-based — logic errors, correctness, architecture, SOLID |
| Silent Failure Hunter | `pr-review-toolkit:silent-failure-hunter` | `sonnet` | Error handling — swallowed exceptions, missing propagation, inappropriate fallbacks |

Diversity floor applies.

**Reviewer Constitution (MANDATORY):** Include in each prompt. Pass ONLY the diff — not impl reasoning. Code review stays cold per Constitution.

Collect verdicts. Address feedback. End-of-round meta-judge. Repeat per Constitution rules.

### /simplify Pass (MANDATORY after code review)

Get full diff with `git diff`. Launch 3 agents in parallel:

**Agent 1: Code Reuse** (`code-simplifier:code-simplifier`, `sonnet`) — existing utilities, duplicated functionality, inline logic that should delegate

**Agent 2: Code Quality** (`feature-dev:code-reviewer`, `sonnet`) — redundant state, parameter sprawl, copy-paste, leaky abstractions, stringly-typed code, unnecessary comments

**Agent 3: Dead Code & Efficiency** (`unused-code-cleaner`, `sonnet`) — unnecessary work, N+1, unused imports/functions, memory leaks, overly broad ops

Fix FIX-level issues. Skip false positives. Commit as separate `refactor:` commit.

## Phase 6 — Testing

1. Unit tests — all pass. Do not modify tests to make them pass.
2. Think like a human — browser automation if applicable.
3. Consider other testing angles. Verify.
4. Spawn 1 **Test Analyzer** (`pr-review-toolkit:pr-test-analyzer`, `sonnet`) for coverage review.

### Real API/LLM Verification (MANDATORY for model/API changes)

1. REAL API call through actual code path (not mock)
2. Inspect REAL output — verify correctness
3. Log evidence in commit message
4. If fails → test failure. Do NOT proceed.

Skip ONLY for pure refactoring, UI-only, or non-API paths.

## Phase 7 — Conclusion

Follow SKILL_BASE.md Self-Review and Promote Findings.

### Commit and Memory

Store memory (including self-review answers) + commit. Update docs if needed. Mark all phases complete in `task-plan.md`.

Follow SKILL_BASE.md Team Cleanup.
