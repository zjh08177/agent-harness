---
name: cursor
description: Cursor CLI wrapper — delegate implementation, review, or investigation to cursor-agent for a second voice outside the main Claude thread. Triggers on "cursor review", "ask cursor", "cursor second opinion", "hand this to cursor", "/cursor". Parallel to the codex skill; different provider, same shape.
---

# Cursor

Thin routing skill — no domain logic. Hands work to the `cursor-rescue` subagent.

## When to invoke

User phrases that trigger this skill:

- "ask cursor ...", "run this through cursor", "cursor review", "cursor second opinion"
- "hand this to cursor", "/cursor", "use cursor for this"
- "what does cursor think about ..."

If the user explicitly asked for codex / gpt-5 / o-series, defer to the `codex` skill instead.

## How to delegate

Spawn the `cursor-rescue` subagent with the user's request verbatim. Let `cursor-rescue` do the `cursor-agent` CLI invocation.

Do NOT:
- Invoke `cursor-agent` directly from this skill (that's `cursor-rescue`'s job)
- Inspect files, reason about the problem, or prepare a "better" prompt — forward as-is
- Post-process the returned output — return verbatim

## Routing flags the user may include

Pass these through to `cursor-rescue` in the task text; `cursor-rescue` strips them before calling cursor-agent:

| Flag | Effect |
|---|---|
| `--resume` | Adds `--continue` to continue prior cursor-agent session in this repo |
| `--fresh` | Forces a fresh session (never `--continue`) |
| `--read-only` | Adds `--mode plan --sandbox enabled` (review/diagnosis only, no edits, OS-sandboxed) |
| `--worktree` | Runs inside an isolated `~/.cursor/worktrees/...` branch |
| `--model <name>` | Overrides default model (see `cursor-agent --list-models`) |

## Review-mode vs rescue

- **Review mode (`cs=on`)** — belongs in `/auto-workflow`, `/auto-debug`, `/auto-explore`. Orchestrated parallel N-reviewer replacement. Uses `~/.claude/skills/shared/CURSOR_REVIEW.md`. NOT this skill.
- **Rescue** — this skill. Single handoff for a specific task outside the auto-* flow.

## Prerequisites

- `cursor-agent` binary on `$PATH`
- Auth: `cursor-agent login` completed, or `CURSOR_API_KEY` in env

`cursor-agent status` reports current auth. If missing, prompt the user to run `cursor-agent login` before retrying — do not attempt to auth from this skill.
