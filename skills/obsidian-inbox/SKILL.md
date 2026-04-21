---
name: obsidian-inbox
description: AI auto-triage — scan 00-Inbox/, suggest category + tags + links, move to 01-Staging/
user_invocable: true
---

# /obsidian-inbox — Stage 1: AI Auto-Triage

**Purpose**: Scan `00-Inbox/`, analyze each note, suggest categorization (PARA zone, tags, wikilinks), write suggestions into YAML frontmatter, and move to `01-Staging/`.

## Workflow

1. **Scan** `00-Inbox/` for all `.md` files
2. **For each note**:
   a. Read content
   b. Analyze to determine:
      - **Target zone**: Projects/, Areas/, Resources/, Archives/, or Self/
      - **Sub-folder**: Which existing sub-folder (ls the target zone first) or suggest new one
      - **四维标签**: type, status, src, topic (max 5)
      - **Wikilinks**: Scan vault for related notes to suggest `[[wikilink]]` connections
      - **Title suggestion**: If filename is generic (e.g., `Untitled.md`), suggest a better name
   c. Write/update YAML frontmatter with suggestions:
      ```yaml
      ---
      ai_suggested:
        target: "Areas/Stocks"
        type: case
        status: seed
        src: web
        topic: [investing, stock-analysis]
        links: ["[[Portfolio Strategy]]", "[[2024 Market Review]]"]
        rename: "tesla-q4-analysis.md"  # only if needed
      ---
      ```
   d. Move file from `00-Inbox/` to `01-Staging/`
3. **Report** summary: N notes triaged, categories assigned

## Rules

- **Never modify note content** — only add/update `ai_suggested` frontmatter block
- **Preserve existing frontmatter** — merge, don't overwrite
- If inbox is empty, say so and suggest `/obsidian-capture` to add notes
- Target: Keep inbox < 20 items
- Always `ls` the target PARA zone before suggesting a sub-folder
- Use `[[wikilinks]]` for content nouns, `#tags` for attributes only

## Health Check

If `01-Staging/` has > 30 items, warn the user to run `/obsidian-review` first.
