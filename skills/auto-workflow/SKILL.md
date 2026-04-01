---
name: auto-workflow
description: Fully autonomous development workflow with 8 phases — Context Gathering, Red Team, Tech Solution, Implementation Planning, Implementation, Code Review, Testing, and Conclusion. ERD must exist before invoking. Orchestrates N parallel review sub-agents per phase (default 5, configurable) with iterative feedback loops (default 3 rounds, configurable). This skill should be used when the user invokes "auto-workflow", requests a full autonomous development cycle, or needs a rigorous multi-phase engineering process with heavy agent-based review.
---

# Workflow Heavy

## Configuration

| Param | Alias | Default | Syntax | Effect |
|-------|-------|---------|--------|--------|
| `agents` | `a` | 5 | `auto-workflow a=8` | Minimum sub-agents per review phase |
| `rounds` | `r` | 3 | `auto-workflow r=5` | Minimum review loop iterations |
| `intensity` | `i` | balanced | `auto-workflow i=ruthless` | Red Team intensity (gentle/balanced/ruthless) |
| `light` | — | off | `auto-workflow light` | Lightweight mode for ≤3 file changes |
| `gate` | — | none | `auto-workflow gate=tech-solution` | Halt for user approval at specified phase |
| `verify` | — | off | `auto-workflow verify=true` | Add false-positive verification pass to reviews |

## Prerequisites

Read these shared files at session start:
- `~/.claude/skills/shared/SKILL_BASE.md` — Team Setup, Branch Safety, Execution Rules, Planning Files, Self-Review, Team Cleanup, Fault Tolerance
- `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` — Review agent prompts AND convergence/round exit criteria (the lead needs this to control review loops)

**Lightweight mode** (`auto-workflow light`): For tasks with ≤3 files changed — skip TeamCreate, planning files, vault doc routing, and all agent spawns. Run all phases inline with the main agent. Phase 1 Red Team runs as inline analysis (no sub-agents). Phases 2/3/5 reviews are done by the lead directly using the Constitution's output contract. Phase 6 testing still runs fully.

**Skills to use:**
- `superpowers` skills for planning and coding
- `pua-debugging` skills for debugging
- Code review skills for code review
- `ai-multimodal`, `seedance`, and other prompting skills for prompt-engineering work
- For any other work, proactively search for and use the best existing skill

## Phase 0 — Context Gathering

### Doc Output Routing

Save specs and design docs to the **second-brain vault** following the Project Folder Convention in user-scope CLAUDE.md.

| Phase output | `doc_type` value | Template |
|---|---|---|
| ERD | `erd` | `note-template` |
| Tech Solution | `tech-solution` | `note-template` |
| Implementation Plan | `impl-plan` | `note-template` |
| Design Decision | `decision` | `decision-template` |

### Context Reading

**The ERD must already exist before invoking this skill.** Phase 0 reads context, not writes docs.

1. Read the ERD provided by the user (path in args or recent vault docs)
2. Read all source files referenced in the ERD
3. Read existing tests, CLAUDE.md, and relevant docs
4. Search MCP memory for prior decisions on this project
5. Understand the current codebase state before any design work
6. Declare the session deliverable in one line: "Deliverable: [artifact path or commit description]"

## Phase 1 — Red Team (Question the ERD)

> A perfect implementation of the wrong idea is still wrong.

**Intensity levels:**
- `gentle` (default for ≤3 file changes) — flag only disproven premises and clear over-engineering
- `balanced` (default) — first-principles decomposition + community search + 2-3 alternatives
- `ruthless` — everything in balanced + pre-mortem + force 3-5 competing hypotheses ranked by simplicity

Spawn **TWO specialized Red Team agents in parallel**:

### Agent 1: CEO/First-Principles Validator

Spawn with **general-purpose** agent type. Use the `plan-ceo-review` skill methodology.

**Goal**: Challenge the ERD's premises. Return PROCEED or HALT with evidence.

**Prompt**: "You are an adversarial premise validator. Your job is to find reasons this ERD should NOT proceed to implementation. Invoke the `plan-ceo-review` skill methodology. Specifically:
1. List every premise the design depends on — explicit and hidden
2. Flag unverified premises — assumptions taken on faith
3. Flag over-engineering — could a simpler approach achieve 80%+ of the goal?
4. Generate 2-3 genuinely different alternative approaches BEFORE validating the ERD (reduces anchoring)
5. Use `WebSearch` to find 2-3 reference implementations of similar problems
6. Return verdict: PROCEED or HALT (with which premises failed and why). If PROCEED, rank ERD approach vs. alternatives."

### Agent 2: Codebase Evidence Gatherer

Spawn with `subagent_type: "feature-dev:code-explorer"`, `model: "sonnet"`.

**Prompt**: "Search the codebase for evidence that validates or disproves the ERD's premises. For each premise:
1. How is this model/API/tool ACTUALLY used today?
2. Are there existing patterns that contradict the proposed approach?
3. Are there hidden dependencies the ERD doesn't account for?
4. Flag any premise contradicted by codebase evidence with file:line references."

### Verdict

Merge findings. **If HALT**: Use `AskUserQuestion` to surface the disproven premise. Wait for user redirect. **If PROCEED**: Continue.

## Phase 2 — Tech Solution + Agent Review

Design the technical solution. Write the **Tech Solution** document:
- Architecture, file decomposition
- Key design decisions, AB-gate strategy
- Testing strategy, migration plan

Spawn at least N review teammates. Distribute evenly across types; assign remainders to the last type:

| Agent Type | `subagent_type` | `model` | Role |
|-----------|----------------|---------|------|
| Backend Architect | `backend-architect` | `sonnet` | API design, data flow, scalability, performance |
| Frontend Developer | `frontend-developer` | `sonnet` | UI architecture, state management, component design |
| Code Architect | `feature-dev:code-architect` | `sonnet` | Overall architecture, patterns, module cohesion, SOLID |

**Reviewer Constitution (MANDATORY):** Read `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` and include its full content in each reviewer's prompt. Since this is a design document, reviewers SHOULD evaluate stated rationale (per Constitution's design-doc rule). Pass the tech solution document without the lead's conversational reasoning.

Collect structured verdicts. Update design. Repeat per Constitution's convergence/round rules.

**Gate**: Skip by default. If `gate=tech-solution`, halt for user approval via `AskUserQuestion`.

## Phase 3 — Implementation Planning + Agent Review

Write a concrete **Implementation Plan**:
- **Task breakdown** with clear boundaries per task
- **File list** per task (which files created/modified)
- **Parallel execution waves** — independent vs sequential
- **Verification steps** per task
- **Integration points** — where tasks connect, merge order

Spawn at least N review teammates using `subagent_type: "Plan"`, `model: "sonnet"`.

**Reviewer Constitution (MANDATORY):** Include Constitution in each reviewer's prompt. Pass the impl plan + a problem-context-only ERD summary (strip solution-space content — describe the problem, not the approach).

Collect structured verdicts. Update plan. Repeat per Constitution's convergence/round rules.

**Gate**: Skip by default. If `gate=impl-plan`, halt for user approval.

## Phase 4 — Implementation

Execute the plan. Create implementation tasks via `TaskCreate`, spawn teammates with `isolation: "worktree"` for parallel file-safe work, assign tasks via `TaskUpdate`.

## Phase 5 — Code Review + /simplify

### Code Review

Spawn at least N review teammates. Distribute evenly; assign remainders to Code Reviewer:

| Agent Type | `subagent_type` | `model` | Role |
|-----------|----------------|---------|------|
| Code Reviewer | `feature-dev:code-reviewer` | `sonnet` | Confidence-based review — logic errors, correctness, architecture, SOLID violations |
| Silent Failure Hunter | `pr-review-toolkit:silent-failure-hunter` | `sonnet` | Error handling audit — swallowed exceptions, missing error propagation, inappropriate fallbacks |

**Reviewer Constitution (MANDATORY):** Include Constitution in each reviewer's prompt. Pass only the diff — not implementation reasoning. This is code, so reviewers review cold per Constitution.

Collect structured verdicts. Address feedback. Repeat per Constitution's convergence/round rules.

### /simplify Pass (MANDATORY after code review)

After code review fixes, get the full diff with `git diff` and launch 3 agents in parallel:

**Agent 1: Code Reuse** (`subagent_type: "code-simplifier:code-simplifier"`, `model: "sonnet"`)
- Search for existing utilities that could replace new code
- Flag duplicated functionality and inline logic that should use existing utilities

**Agent 2: Code Quality** (`subagent_type: "feature-dev:code-reviewer"`, `model: "sonnet"`)
- Redundant state, parameter sprawl, copy-paste, leaky abstractions, stringly-typed code, unnecessary comments

**Agent 3: Dead Code & Efficiency** (`subagent_type: "unused-code-cleaner"`, `model: "sonnet"`)
- Unnecessary work, N+1 patterns, unused imports/functions, memory leaks, overly broad operations

Fix FIX-level issues. Skip false positives. Commit as separate `refactor:` commit.

## Phase 6 — Testing

1. Write unit tests and verify all pass. Do not modify tests to make them pass.
2. Think how to test like a human — use browser automation if applicable.
3. Think of other ways to test. Verify.
4. Spawn 1 **Test Analyzer** (`subagent_type: "pr-review-toolkit:pr-test-analyzer"`, `model: "sonnet"`) to review coverage.

### Real API/LLM Verification (MANDATORY for model/API changes)

When the task involves AI model changes, API integrations, or prompt engineering:
1. Make a REAL API call through the actual code path (not a mock)
2. Inspect the REAL output — verify correctness
3. Log the evidence in the commit message
4. If it fails, treat as test failure — do NOT proceed

Skip ONLY for pure refactoring, UI-only changes, or non-API code paths.

## Phase 7 — Conclusion

Follow SKILL_BASE.md Self-Review and Promote Findings sections.

### Commit and Memory

Store memory (including self-review answers) and commit. Update docs if needed. Mark all phases complete in `task-plan.md`.

Follow SKILL_BASE.md Team Cleanup section.
