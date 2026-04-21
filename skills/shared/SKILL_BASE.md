# Skill Base — Shared Prerequisites

Reference this file from auto-workflow, auto-explore, auto-debug instead of duplicating.

## Phase 0: Dependency Check (MANDATORY)

Run silently before any phase:

```bash
missing=""
for skill in feature-dev superpowers planning-with-files pr-review-toolkit code-simplifier; do
  [ ! -d ~/.claude/skills/$skill ] && missing="$missing $skill"
done
[ -n "$missing" ] && echo "MISSING:$missing" || echo "ALL_PRESENT"
```

**If missing**, inform user ONCE at start:

> ⚠️ **Optional skills not found:**`{list}`
>
> Install: `npx skills add {repo} -g`
>
> Proceeding in **degraded mode** — lead handles these phases inline.

**Degraded mode:**
- Missing `feature-dev` → Lead handles code exploration, architecture review, code review directly
- Missing `superpowers` → Skip structured planning templates; inline task lists
- Missing `planning-with-files` → Use `Write` tool directly
- Missing `pr-review-toolkit` → Skip dedicated test coverage analysis
- Missing `code-simplifier` → Skip post-impl simplification pass

All phases MUST complete. Degraded mode changes WHO, not WHETHER.

## Team Setup (MANDATORY)

1. `TeamCreate` for this session
2. `TaskCreate` for tasks
3. Spawn via `Agent` with `team_name`, `name`, `isolation: "worktree"` — ALL teammates in worktrees
4. Assign via `TaskUpdate` with `owner` = teammate name
5. Shutdown via `SendMessage` `{type: "shutdown_request"}`
6. `TeamDelete` after confirmed shutdowns

## Branch Safety (MANDATORY)

- ALL spawned agents MUST use `isolation: "worktree"` — no exceptions
- Agents MUST NOT merge, rebase, push, or auto-integrate worktree branches
- Agents report worktree branch name; lead reviews manually
- Only the lead writes final deliverables to the working branch

## Execution Rules

- Auto-approve, execute, complete the entire flow without stopping
- Exceptions: Phase 1 Red Team HALT (auto-workflow only); any phase with `gate=<phase-name>`
- Do not stop before fully complete

## Autonomous Decisions (MANDATORY)

When the work has a defensible single answer, **make the decision** and state rationale in one line. Present a menu ONLY when the decision is genuinely 50/50 OR requires info outside your reach. If unsure, default to autonomy — user can redirect faster than they can pick.

## Ad-Hoc Review Dispatch (MANDATORY)

If you dispatch ≥2 review agents via `Agent` tool on the SAME artifact **without invoking `/auto-workflow`**, you MUST:

1. Include the Reviewer Constitution verbatim in every agent's prompt
2. Treat ad-hoc dispatches as review rounds — round-count tracking + Post-Round-3 Gate apply
3. Declare the round header (`REVIEW ROUND N OF <artifact>`) in user-facing text before dispatch

Revision labels (r7 → r8 → r9) do NOT reset round count. Resets only on material scope change (Constitution § Round Header).

Rationale: Constitution convergence criteria only bind reviewers who receive them. Bypassing via ad-hoc `Agent` dispatch historically (2026-04-20, control-flow) led to 9-round loops where convergence criteria were never evaluated.

## Scope Lock (MANDATORY)

Before Round 1 of any review cycle, lead declares:
1. **In-scope**: explicit list
2. **Out-of-scope**: explicit list, especially common expansions the user might request mid-cycle
3. **Scope owner** (user or lead) and any pre-approved expansion triggers

Mid-review scope changes:
- **Narrowing** (explicitly declared out-of-scope) → no reset; note in round log
- **Expansion** (new in-scope item OR new HARD constraint) → **round counter resets to R0**, produce `scope-delta-<topic>.md` in vault project folder:
  - What expanded
  - Which prior-round findings are invalidated
  - Which are still valid under new scope
- Acknowledge the reset with user before continuing

Rationale: without reset, expanded scope re-litigates prior rounds under new criteria, inflating round count as "slow convergence." Empirical: control-flow r5 (ComfyUI ecosystem) and r7→r8 (BC HARD) each caused this.

## Research Gate (MANDATORY)

If any reviewer raises a **scope-level question** (not a spec-gap), lead MUST:

1. **Pause** the review cycle — do NOT dispatch next round
2. **Classify**:
   - Internal (codebase / existing pattern / ownership) → single `feature-dev:code-explorer` agent
   - External (community convention / ecosystem / CVE) → invoke `/auto-explore` (full, not light) with the specific question
3. **Resume** review with research findings in context

Scope-level signals:
- "Is this the right approach vs community convention X?"
- "Does ecosystem Y have a different primitive?"
- "Is this premise correct?"
- Any REJECT citing "assumption not validated"

Rationale: scope questions don't close in review rounds. Control-flow r5 spent a full round partially resolving "should we align with ComfyUI?" before /auto-explore ran in r6. One upfront research pass would have saved r5.

## Planning Files

Create persistent planning files in vault project folder using `planning-with-files`:
1. `task-plan.md` — phases matching skill's workflow
2. `findings.md` — discoveries, feedback, hypotheses
3. `progress.md` — session log

Fallback if `obsidian-cli` unavailable: `Write` tool at `[project-dir]/Docs/`.

Each skill defines its own `light` mode with skill-specific phase-skipping rules.

## Self-Review (MANDATORY before memory storage)

Answer, then store as MCP memory observations:
1. **Root approach** — key architectural/design choice (one line)
2. **Surprise** — what was unexpected (one line)
3. **Retrospective** — what would you do differently (one line)

## Promote Findings

Review `findings.md`. Promote valuable discoveries to permanent vault docs via `obsidian-cli` with appropriate templates.

## Team Cleanup (MANDATORY — final step)

1. `SendMessage` `{type: "shutdown_request"}` to each teammate
2. Wait up to 60s per teammate. If unconfirmed, proceed and note it.
3. `TeamDelete`

## Fault Tolerance

**Agent idles / crashes / timeouts (>5min no response):**

1. Log failure in `findings.md`, re-spawn ONCE with same task
2. If re-spawn also fails AND this leaves <N/2 reviewers → **halt round**, log coverage-gap, do NOT compute convergence, do NOT proceed without user sign-off
3. If ≥N/2 reviewers delivered → proceed BUT tag round as "partial-coverage; re-run required before closure"

Silent-proceed is forbidden. Rationale: absorbs coverage gaps into next round, extending cycle. Control-flow r5 proceeded with 3-of-6 per old rule; same concerns resurfaced in r6/r7.

**Reviewer format violations (precedence order):**
1. Response contains `VERDICT:` on its own line → parse normally
2. No `VERDICT:` but response >20 words → extract blocking issues FIRST, then infer verdict from tone (blocking lang = REJECT, approving = AWW). Note format violation.
3. No `VERDICT:` and response ≤20 words / empty → treat as PARTIAL

Always add to reviewer prompt footer: "Your response MUST begin with `VERDICT:` on its own line."

**MCP memory fallback**: If `mcp__memory__add_observations` fails, log to `findings.md`. Do not block workflow.
