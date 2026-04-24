---
name: handoff-update
description: |
  Write or rewrite the rolling `handoff-<topic>.md` resume pointer for an active
  vault project. Overwrite-only (not append), max ~100 lines, constrained fields.
  Loaded at session start by the SessionStart hook so future sessions can resume
  in 60 seconds. Auto-invoked by the PreCompact hook before context compaction,
  or manually via "update handoff" / "write handoff" / "save resume pointer".
  Part of the 005 Context-Sync v2 plan (Areas/dev-workflow/005-*).
user-invocable: true
allowed-tools: "Read, Write, Edit, Bash, Glob"
triggers:
  - update handoff
  - write handoff
  - save resume pointer
  - refresh handoff
metadata:
  version: "1.0.0"
  plan: "[[005-context-sync-workflow-v2]]"
---

# handoff-update

Rolling resume-pointer writer for active vault projects. Implements 005 item 2.

## Purpose

Maintain a tiny (≤100 lines), overwrite-only `handoff-<topic>.md` in the active
vault project folder. It is the **only** always-loaded cross-session artifact —
SessionStart hook injects its first 100 lines so a fresh session resumes in ~60s.

Distinct from:
- `task-plan.md` — skill-mandated ephemeral phase checklist (planning-with-files)
- `progress.md` — skill-mandated ephemeral session log (planning-with-files)
- `findings.md` — skill-mandated ephemeral scratchpad (planning-with-files)
- `archive-<layer>-*.md` — durable append-only round history
- `log-YYYY-MM-DD-<topic>.md` — promoted permanent session snapshot

See [[005-context-sync-workflow-v2#typed-memory-namespace]] for the full map.

## When to invoke

- **Auto**: PreCompact hook fires right before context compaction
- **Auto**: SessionEnd / Stop gate when review state dirty
- **Manual**: user types "update handoff" / "save resume pointer" / before context switch
- **Manual**: before `/clear` when working on a long-running project

Do NOT invoke on every edit — handoff is a compaction-boundary artifact, not
edit-boundary.

## Inputs

- `$TOPIC` — project topic (derived from cwd or vault folder name if not passed)
- `$VAULT_PROJECT_DIR` — vault project directory (read from `.planning-dir` if present)
- Conversation context — the skill reads the current turn's state; no external inputs

## Output contract

Single file: `<VAULT_PROJECT_DIR>/handoff-<TOPIC>.md`

**Overwrite-only**, never append. Max ~100 lines (≈2KB hard cap).

Required frontmatter:

```yaml
---
title: "Handoff: <topic>"
lifecycle_class: working-durable
last_verified_at: "<YYYY-MM-DD>"
expires_or_refreshes: next_session
---
```

Required body sections (in order):

1. **TL;DR (≤3 lines)** — where we are in 60s
2. **Active Files** — absolute paths of docs/code currently being edited
3. **Next Action** — first command for the next session
4. **Open Decisions** — pending design questions with current tentative answer
5. **Do Not Forget** — hard constraints, in-flight tickets, surprise gotchas
6. **Latest Archive Link** — pointer to most recent `archive-<layer>-*.md` entry
7. **Latest Checkpoint ID** — `checkpoint-<run_id>.json` pointer if PreCompact fired

Skip any section that's empty; don't fill with placeholders.

## Process

1. **Locate vault project folder**:
   ```bash
   VAULT_DIR=$(cat .planning-dir 2>/dev/null)
   if [ -z "$VAULT_DIR" ] || [ ! -d "$VAULT_DIR" ]; then
     VAULT_DIR="$(pwd)"  # fallback: assume cwd is already a vault project folder
   fi
   ```

2. **Derive topic**:
   ```bash
   TOPIC=$(basename "$VAULT_DIR")
   ```

3. **Read existing handoff (if any)** for `last_verified_at` continuity. Preserve
   sections with no material change.

4. **Collect state** from conversation:
   - Goal + stage from task-plan.md head (if plan-with-files active)
   - Modified files from `git diff --stat` + `git status --short`
   - Latest archive entry: `ls -t archive-*.md | head -1`
   - Latest checkpoint: `ls -t .checkpoints/checkpoint-*.json | head -1` (if exists)

5. **Compose + write** via Write tool (NOT obsidian-cli --content — that truncates
   at `&`, `#`, `?`, `%`, `=`, `+`). Use the template at `templates/handoff.md`
   as reference.

6. **Verify**: Read the file back, check line count ≤100 and frontmatter parses.

7. **Report**: one line to the user — "Handoff updated: `<path>` (NN lines)".

## Critical rules

- **Never append.** Always overwrite. Handoff is a rolling pointer, not a log.
- **Keep it tiny.** Hard cap at 100 lines. If you need more space, the content
  belongs in `archive-*.md` or `finding-NNN-*.md`, not here.
- **Pointers, not content.** Reference archive entries and checkpoints by path.
  Do not inline 10KB of reviewer output.
- **No external content.** Do not paste web search results or untrusted input;
  that belongs in `findings.md` (planning-with-files security boundary).
- **One handoff per project.** If `handoff-<topic>.md` doesn't match the active
  project, audit naming before creating a second file — usually means topic drift.

## Interaction with planning-with-files skill

No conflict. Division of labor:

| Lifecycle | Skill | Artifacts |
|---|---|---|
| Working-ephemeral (session scope) | planning-with-files | `task-plan.md`, `findings.md`, `progress.md` |
| Working-durable (project scope) | handoff-update (this skill) | `handoff-<topic>.md` |

planning-with-files handles intra-session state; handoff-update handles
cross-session resume.

## Anti-patterns

| Don't | Do |
|---|---|
| Append to handoff | Overwrite entirely |
| Use obsidian-cli create --content | Use Write tool |
| Dump full findings | Link to findings.md or promoted finding-NNN-*.md |
| Invoke on every edit | Invoke at compaction/session boundaries |
| Skip `last_verified_at` | Always update to today's date |
| Leave handoff after project archives | Promote to retro-<topic>.md, then delete |
