# Skill Base — Shared Prerequisites

Reference this file from auto-workflow, auto-explore, auto-debug instead of duplicating.

## Team Setup (MANDATORY)

1. Use `TeamCreate` to create a team for this session
2. Create tasks via `TaskCreate`
3. Spawn teammates via `Agent` tool with `team_name`, `name`, and `isolation: "worktree"` — ALL teammates MUST run in worktrees
4. Assign tasks via `TaskUpdate` with `owner` set to teammate name
5. Shut down teammates via `SendMessage` with `message: {type: "shutdown_request"}` when done
6. Clean up team via `TeamDelete` after all teammates confirm shutdown

## Branch Safety (MANDATORY)

- ALL spawned agents MUST use `isolation: "worktree"` — no exceptions
- Agents MUST NOT merge, rebase, push, or auto-integrate their worktree branches
- If an agent produces changes, report the worktree branch name for manual review
- The lead agent (you) operates on the working branch — only the lead writes final deliverables

## Execution Rules

- Auto-approve, execute, and complete the entire flow without stopping
- Exceptions: Phase 1 Red Team HALT (auto-workflow only), and any phase explicitly configured with `gate=<phase-name>`
- Do not stop before everything is fully complete

## Planning Files

Create persistent planning files in the **vault project folder** using `planning-with-files`:
1. `task-plan.md` — phases matching the skill's workflow
2. `findings.md` — discoveries, feedback, hypotheses
3. `progress.md` — session log

If `obsidian-cli` is unavailable, fall back to `Write` tool at `[project-dir]/Docs/`.

**Note**: Each skill defines its own `light` mode with skill-specific phase-skipping rules. Check the skill's Configuration section.

## Self-Review (MANDATORY before memory storage)

Answer these three questions, then store as MCP memory observations:
1. **Root approach/decision** — key architectural/design choice or methodology (one line)
2. **Surprise** — what was unexpected (one line)
3. **Retrospective** — what would you do differently (one line)

## Promote Findings

Review `findings.md`. Promote valuable discoveries to permanent vault docs via `obsidian-cli` with appropriate templates.

## Team Cleanup (MANDATORY — final step)

1. Send `{type: "shutdown_request"}` via `SendMessage` to each teammate individually
2. Wait up to 60 seconds per teammate for shutdown confirmation. If unconfirmed, proceed anyway and note it.
3. Clean up the team via `TeamDelete`

## Fault Tolerance

**Agent failures:**
- If a spawned agent returns no output, crashes, or times out (no response within 5 minutes): log the failure in `findings.md`, re-spawn once with the same task
- If it fails again, note the coverage gap and proceed — do not block the workflow
- If a response is syntactically valid but missing fields (e.g., no FAILURE_MODES), accept what's present and note the gap

**Reviewer format violations (precedence order):**
1. If the response contains `VERDICT:` on its own line → parse normally
2. If no `VERDICT:` line but the response is >20 words → extract any blocking issues mentioned FIRST, then infer verdict from overall tone (blocking language = REJECT, approving = ACCEPT_WITH_WARNINGS). Note the format violation.
3. If no `VERDICT:` line and response is ≤20 words or empty → treat as PARTIAL

Always add a format reminder to the reviewer prompt footer: "Your response MUST begin with `VERDICT:` on its own line."

**MCP memory fallback**: If `mcp__memory__add_observations` fails, log observations to `findings.md` instead. Do not block the workflow.
