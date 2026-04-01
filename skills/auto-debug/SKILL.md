---
name: auto-debug
description: Fully autonomous issue troubleshooting workflow for one or many bugs. 5 phases per bug — Reproduce, Diagnose, Fix, Verify, Conclude. Uses pua-debugging skill as the core debugging engine. Deploys parallel sub-agents for root cause analysis and fix review. Supports a bug list — processes each bug sequentially, commits separately, and reports a summary at the end. This skill should be used when the user invokes "auto-debug", reports a bug or bug list, encounters errors, or needs autonomous issue troubleshooting.
---

# Auto Debug

**CRITICAL: Use `pua:pua-debugging` skill throughout all debugging phases. Never give up. Never deflect. Never stop trying.**

## Configuration

| Param | Alias | Default | Syntax | Effect |
|-------|-------|---------|--------|--------|
| `agents` | `a` | 4 | `auto-debug a=8` | Minimum sub-agents for diagnosis/review |
| `rounds` | `r` | 2 | `auto-debug r=3` | Minimum review loop iterations |

Both can be combined: `auto-debug a=6 r=3`

**Lightweight mode** (`auto-debug light`): For bugs affecting ≤2 files with obvious root cause — skip TeamCreate, planning files, vault doc routing. Diagnose and fix inline (no sub-agents). Phase 4 verification still runs fully. Use when the fix is clearly a one-liner.

## Prerequisites

Read these shared files at session start:
- `~/.claude/skills/shared/SKILL_BASE.md` — Team Setup, Branch Safety, Execution Rules, Planning Files, Self-Review, Team Cleanup, Fault Tolerance
- `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` — Review agent prompts AND convergence/round exit criteria

**Skills to use:**
- `pua:pua-debugging` for all debugging work — non-negotiable
- `superpowers:systematic-debugging` for structured root cause analysis
- Code review skills when reviewing the fix
- For any other work, proactively search for and use the best existing skill

### Environment Setup

Before any debugging, verify the environment:
1. Python: `source .venv/bin/activate` (for worktrees, use main repo's venv)
2. Node: verify `node_modules` exists, run `npm install` if missing
3. Run the project's test suite once to confirm baseline (green = good, failures = pre-existing)
4. If environment setup fails, fix it before proceeding.

Each sub-agent must also activate the project environment. Include env activation in every agent prompt.

## Bug List Handling

When given multiple bugs:
- Triage all bugs first. Order by severity (blockers first) then by dependency.
- Process each bug through Phase 1-4 sequentially. One bug = one commit.
- If bugs are independent and non-overlapping, dispatch parallel agents.
- After all bugs are fixed, run Phase 5 once for the entire batch.
- Report a summary table at the end.

## Phase 1 — Reproduce

Reproduce the issue reliably.

- Read the bug report, error message, stack trace, or user description.
- Read all relevant code, logs, and configuration.
- Reproduce the issue locally. If it involves UI, use Playwright MCP to trigger the bug.
- If the issue cannot be reproduced, investigate deeper: environment differences, timing, race conditions, data-dependent paths. Do not give up.
- Document the exact reproduction steps.

## Phase 2 — Diagnose

Find the root cause. Deploy **specialized** sub-agents for parallel investigation.

Spawn at least N investigation teammates. Distribute evenly; assign remainders to Debugger:

| Agent Type | `subagent_type` | `model` | Role |
|-----------|----------------|---------|------|
| Debugger | `debugger` | `sonnet` | Systematic root cause analysis, stack trace interpretation, hypothesis testing |
| Code Explorer | `feature-dev:code-explorer` | `sonnet` | Trace execution paths, map architecture layers, find where the bug enters the system |

**Anti-confirmation-bias**: Generate at least 3 competing hypotheses before investigating any. Each agent MUST try to disprove its assigned hypothesis, not prove it. Require disconfirming evidence before accepting any root cause.

Assign each a hypothesis task via `TaskUpdate`. Focus on root cause identification, not symptoms.
Collect findings from teammates. Identify the root cause.
If the root cause is unclear, form new hypotheses and re-assign. Repeat at least R rounds.

Confirm the root cause with evidence (code path, log output, or reproducible test).

**Root cause summary**: Write a 3-5 sentence root cause summary artifact. This is passed to Phase 3 reviewers as an exception to cold-review — fix review requires root-cause context to evaluate correctness.

## Phase 3 — Fix

Implement the fix.

- Design the minimal, correct fix. Do not over-engineer. Fix the root cause, not the symptom.
- Implement the fix.
- Spawn at least N review teammates. Distribute evenly; assign remainders to Code Reviewer:

| Agent Type | `subagent_type` | `model` | Role |
|-----------|----------------|---------|------|
| Code Reviewer | `feature-dev:code-reviewer` | `sonnet` | Confidence-based review — logic errors, correctness, regression risk |
| Silent Failure Hunter | `pr-review-toolkit:silent-failure-hunter` | `sonnet` | Error handling audit — swallowed exceptions, inadequate fallbacks, missing error propagation |

**Reviewer Constitution (MANDATORY):** Read `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` and include its full content in each reviewer's prompt. Pass the diff + the root cause summary from Phase 2 (this is a debugging-specific exception to cold-review — reviewers need root-cause context to judge whether the fix addresses the actual problem).

Collect structured verdicts. Address feedback. Repeat per Constitution's convergence/round rules.

## Phase 4 — Verify

1. Confirm the original issue no longer reproduces. Run the exact reproduction steps from Phase 1.
2. Run all existing tests. No regressions allowed. Do not modify existing tests to pass.
3. Write new tests that cover the bug scenario. These tests must fail without the fix and pass with it.
4. If the issue involved UI, use Playwright MCP to verify the fix visually.
5. Think of related edge cases. Test those too.
6. Spawn 1 **Test Analyzer** (`subagent_type: "pr-review-toolkit:pr-test-analyzer"`, `model: "sonnet"`) to review test coverage completeness.

### Real API/LLM Verification (MANDATORY for model/API bugs)

When the bug involves AI models, API integrations, or prompt changes:
1. Make a REAL API call through the actual code path
2. Inspect the REAL output — verify correctness
3. Log the evidence. "It works" without evidence is not verification.
4. If it fails, the fix is incomplete — do NOT commit. Debug further.

## Phase 5 — Conclusion

Follow SKILL_BASE.md Self-Review and Promote Findings sections.

### Commit and Memory

Store memory (including self-review answers) and commit (one commit per bug, or one batch commit if trivially related).

When multiple bugs were processed, output a summary table:

| Bug | Root Cause | Fix | Status |
|-----|-----------|-----|--------|
| ... | ... | ... | Fixed / Partial / Blocked |

Follow SKILL_BASE.md Team Cleanup section.
