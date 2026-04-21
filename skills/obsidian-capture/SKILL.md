---
name: obsidian-capture
description: Quick capture to 00-Inbox/ — zero-friction note creation
user_invocable: true
---

# /obsidian-capture — Quick Capture

**Purpose**: Instantly capture a thought, idea, link, or snippet to `00-Inbox/` with minimal friction.

## Usage

- `/obsidian-capture <content>` — Capture with auto-generated title
- `/obsidian-capture "<title>" <content>` — Capture with specific title

## Workflow

1. **Parse input**: Extract title (if quoted) and content
2. **Generate filename**: `YYYY-MM-DD-<slugified-title>.md`
3. **Create note** in `00-Inbox/` with minimal frontmatter:
   ```yaml
   ---
   type: concept
   status: seed
   src: conversation
   topic: []
   captured: {{datetime}}
   ---
   ```
4. **Write content** as-is (preserve formatting)
5. **Quick scan**: If content mentions known vault topics, add `[[wikilinks]]` suggestions in a comment block:
   ```markdown
   %% AI suggestions: possibly related to [[Project X]], [[Topic Y]] %%
   ```
6. **Confirm**: Print note path and remind about `/obsidian-inbox` for triage

## Examples

```
/obsidian-capture The key insight from today's meeting is that we should decouple the auth layer
→ Creates: 00-Inbox/2024-03-15-auth-layer-insight.md

/obsidian-capture "React Server Components" RSC allows server-side rendering without hydration cost
→ Creates: 00-Inbox/2024-03-15-react-server-components.md
```

## Rules

- **Zero friction** — never ask clarifying questions, just capture
- Always use `00-Inbox/` — triage happens later via `/obsidian-inbox`
- Auto-detect `src` from context (conversation with AI = `conversation`)
- Keep frontmatter minimal — `/obsidian-inbox` will enrich it later
- If multiple captures in one session, batch them silently
