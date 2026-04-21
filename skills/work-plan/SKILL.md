---
name: work-plan
description: |
  Monday weekly planning skill. Creates a weekly work-log entry with priorities
  aligned to OKRs, seeded from last week's carry-forward. Use when starting a
  new work week or when the user says "plan my week", "weekly plan", or "work plan".
---

# Weekly Work Plan

Create a weekly plan entry in the second-brain vault at `Areas/Career/work-log/weeks/`.

## Vault Paths

- Weekly entries: `Areas/Career/work-log/weeks/YYYY-Www.md`
- OKRs: `Areas/Career/work-log/okrs-2026.md`
- Daily scratch: `Areas/Career/work-log/today.md`
- Vault root: `/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain`

## Process

1. **Determine the current ISO week** using `date +%V` and `date +%Y`.

2. **Read carry-forward** from the previous week's file (`weeks/YYYY-Www.md` where w = current week - 1). Extract the `## Carry-forward` section. If no previous file exists, skip.

3. **Read OKRs** from `Areas/Career/work-log/okrs-2026.md`. Present the objectives as context.

4. **Ask the user**: "What are your top priorities this week?" Present carry-forward items (if any) and OKR context. Accept the user's input.

5. **Create the weekly file** at `Areas/Career/work-log/weeks/YYYY-Www.md` with this format:

```
---
type: work-log
week: YYYY-Www
date_start: YYYY-MM-DD (Monday)
date_end: YYYY-MM-DD (Friday)
status: active
last_updated: YYYY-MM-DD
tags: [work-log]
---

# Week WW — YYYY-MM-DD → YYYY-MM-DD

## Plan
- [ ] Priority 1 #project/xxx
- [ ] Priority 2 #project/yyy
- [ ] Carry-forward item #project/zzz

## Shipped

## Invisible Work

## Learned

## Carry-forward
```

6. **Seed `today.md`** by appending a Monday section with today's items from the plan:

```
### YYYY-MM-DD Mon
- [ ] Item from plan #project/xxx
```

7. **Open the weekly file** using `open <path>`.

## Rules

- Always include `#project/xxx` tags on plan items. Ask the user which project each item belongs to if unclear.
- Use ISO week numbers (W01-W53).
- Compute `date_start` as the Monday of that ISO week, `date_end` as the Friday.
- If a weekly file already exists for the current week, update the Plan section instead of overwriting.
- **`## Plan` MUST be a single flat checklist.** Do NOT create subsections (`### Must-do`, `### Carry-forward from Wxx`, `### Project X`, etc.). Carry-forward items and new priorities live in the same flat list, distinguished only by their `#project/xxx` tag. One checkbox per line — no nested sub-tasks unless the work is a single deliverable with genuine sub-steps.
