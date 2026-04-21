---
name: work-log
description: |
  Friday weekly work log compilation skill. Auto-gathers signals from git commits,
  merged MRs, code reviews, vault artifacts, auto-memory, and the daily scratch file.
  Composes a draft weekly entry and presents it for user review. Use when the user
  says "work log", "compile my week", "what did I ship", or triggered by Friday cron.
---

# Weekly Work Log

Compile the week's work into a structured weekly entry at `Areas/Career/work-log/weeks/`.

## Vault Paths

- Weekly entries: `Areas/Career/work-log/weeks/YYYY-Www.md`
- Daily scratch: `Areas/Career/work-log/today.md`
- OKRs + Config: `Areas/Career/work-log/okrs-2026.md`
- Vault root: `/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain`

## Process

### Phase 1: Read Config

1. Read `Areas/Career/work-log/okrs-2026.md` and parse the `## Config` YAML block to get: `repos`, `vault`, `author_email`, `memory_dirs`, `codebase_project`.
2. Determine current ISO week number and date range (Monday → Friday).

### Phase 2: Gather Signals

Read `references/signal-gathering.md` for detailed instructions on each source.

Gather data from all seven sources:
1. Git commits across configured repos
2. Merged MRs (Codebase MCP)
3. MR reviews given (Codebase MCP)
4. Vault artifacts created this week
5. Auto-memory entries created this week
6. Daily scratch (`today.md`) — **primary source**, auto-populated by hooks all week
7. Previous week's carry-forward (if current week file has empty Carry-forward)

### Phase 3: Compose Draft

Categorize gathered signals into sections:

- **Shipped**: Merged MRs, significant commits, vault artifacts (tech-solution, impl-plan, research). Each entry:
  - **What**: Bullet description
  - **Evidence**: Link to MR, commit, or vault doc
  - A `#project/xxx` tag
  - (Impact added during review — don't block the draft on it)
- **Invisible Work**: Code reviews given, mentoring, unblocking, documentation
- **Learned**: New auto-memory entries, research artifacts, skills acquired
- **Carry-forward**: Unchecked items from `today.md`, unchecked Plan items from current week file

### Phase 4: Present and Write

1. **Present the draft** to the user in the conversation. Ask for review — specifically prompt for Impact on key shipped items.
2. After user approval, **write or update** the weekly file at `weeks/YYYY-Www.md`:
   - If the file exists (created by `/work-plan`), fill in Shipped/Invisible Work/Learned/Carry-forward while preserving the Plan section.
   - If the file doesn't exist, create it with all sections.
   - Update frontmatter: `status: completed`, `last_updated: YYYY-MM-DD`.
3. **Clear `today.md`** — reset to the empty template (keep frontmatter and header).
4. **Open the weekly file** using `open <path>`.

## Weekly Entry Format

```
---
type: work-log
week: YYYY-Www
date_start: YYYY-MM-DD
date_end: YYYY-MM-DD
status: completed
last_updated: YYYY-MM-DD
tags: [work-log]
---

# Week WW — YYYY-MM-DD → YYYY-MM-DD

## Plan
- [x] Completed item #project/xxx
- [ ] Incomplete item #project/yyy

## Shipped
### [Title] #project/xxx
- **What**: Description
- **Evidence**: [[link]] or URL
- **Impact**: (filled during review)

## Invisible Work
- Reviewed N MRs: [list titles/authors]
- [Other invisible contributions]

## Learned
- [Insight or new skill]

## Carry-forward
- [ ] Item for next week #project/xxx
```

## Rules

- Always present the draft for user review before writing.
- Prompt for Impact on top shipped items during review — don't require it in the draft.
- Preserve existing Plan section content when updating a file created by `/work-plan`.
- After writing, clear `today.md` back to its empty template.
- Use `#project/xxx` tags on all items. Infer from repo path, MR title, or vault artifact location.
