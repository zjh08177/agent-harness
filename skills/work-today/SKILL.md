---
name: work-today
description: |
  Daily work checklist skill. Shows today's auto-captured entries and weekly plan,
  accepts manual items for work hooks can't detect (meetings, discussions).
  Use when the user says "what am I doing today", "today's tasks", or "work today".
---

# Daily Work Checklist

View and manually supplement the daily scratch file at `Areas/Career/work-log/today.md`.

> **Note**: Commits, vault doc writes, and Lark doc creation are auto-logged by hooks.
> This skill is for viewing what's logged and adding items hooks can't detect.

## Vault Paths

- Daily scratch: `Areas/Career/work-log/today.md`
- Current week plan: `Areas/Career/work-log/weeks/YYYY-Www.md`
- Vault root: `/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain`

## Process

1. **Read current `today.md`** — show what hooks have auto-captured so far.

2. **Read the current week's plan** from `weeks/YYYY-Www.md` (using `date +%V`). Show unchecked `## Plan` items as context.

3. **Accept input**: User provides additional items (meetings, discussions, debugging sessions) or selects plan items to focus on. If no input needed, just display the current state.

4. **Append items** to today's section in `today.md`:

```
### YYYY-MM-DD Day
- 09:00 Commit abc1234: fix banner layout          ← auto-captured by hook
- 10:30 Wrote [[tech-solution-seedream-v2]]         ← auto-captured by hook
- [ ] Sprint planning meeting #project/storyboard   ← manually added
- [ ] Debug V2V upload issue #project/tiktok-ios     ← manually added
```

5. **Open `today.md`** using `open <path>`.

## Wrap-Up Mode (Yesterday)

When the user says "wrap up yesterday", "plan today", or "carry over unfinished":

1. **Scan yesterday's signals** before relying solely on `today.md`:
   - `git log --author="eric.zhang1@bytedance.com" --since="YYYY-MM-DD" --until="YYYY-MM-DD" --pretty=format:"%h %s"` across configured repos (`/Users/bytedance/Work/comment/loki_web_integrations`, `/Users/bytedance/Work/comment/TikTok`)
   - `find` vault `Projects/` and `Areas/` for files modified yesterday (`-newermt "YYYY-MM-DD" ! -newermt "YYYY-MM-DD+1"`)
   - Check for auto-captured hook entries already in `today.md` under yesterday's section
2. **Cross-reference** signals against yesterday's checklist items — mark any unchecked items that have matching commits/artifacts as done.
3. **Surface unlogged work** — if git/vault signals exist that aren't reflected in any `today.md` entry, present them to the user and offer to add them.
4. **Carry forward** unchecked items to today's section.

## Rules

- Include `#project/xxx` tags on manual items. Infer from context or ask.
- Never overwrite existing content — always append.
- If today's section already exists, add items to it (don't duplicate the header).
- Auto-captured lines (from hooks) use `HH:MM` timestamps. Manual items use `- [ ]` checkboxes.
