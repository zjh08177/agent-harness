---
name: obsidian-weekly
description: Weekly synthesis — review daily notes, detect patterns, update project status
user_invocable: true
---

# /obsidian-weekly — Weekly Synthesis

**Purpose**: Review the past week's daily notes, detect patterns, synthesize insights, and update project status.

## File Location

`Self/YYYY-WNN-weekly.md` (e.g., `Self/2024-W11-weekly.md`)

## Workflow

1. **Gather inputs**:
   - Read all daily notes from the past 7 days (`Self/YYYY-MM-DD-daily.md`)
   - Read recent notes added to PARA zones this week
   - Check `00-Inbox/` and `01-Staging/` counts

2. **Generate weekly review** from `99-System/Templates/weekly-template.md`:
   - **Accomplishments**: What was completed (from Top 3s and task completions)
   - **Patterns**: Recurring themes, energy trends, blocked items
   - **Insights**: Synthesized learnings from daily captures
   - **Vault health**: Inbox/staging counts, orphan notes, stale projects
   - **Next week**: Suggested priorities based on patterns

3. **Update project notes**:
   - For each active project mentioned this week, suggest status updates
   - Flag projects with no activity for > 2 weeks

4. **Connection discovery**:
   - Scan notes created/modified this week
   - Suggest new `[[wikilinks]]` between related notes
   - Flag potential duplicate notes

5. **Present to user** for review and approval

## Template Structure

```markdown
---
type: reflection
status: seed
src: original
topic: [weekly-review]
date: {{date}}
week: {{week_number}}
---

# Week {{week_number}} Review

## Accomplishments
-

## Patterns & Themes
-

## Key Insights
-

## Vault Health
- Inbox: {{inbox_count}} items
- Staging: {{staging_count}} items
- New notes this week: {{new_count}}
- Suggested connections: {{connections}}

## Next Week Priorities
1.
2.
3.

## Project Status Updates
| Project | Status | Notes |
|---------|--------|-------|
```

## Rules

- Read-only analysis — present findings, let user decide what to act on
- Focus on patterns, not just summaries
- Always include vault health metrics
