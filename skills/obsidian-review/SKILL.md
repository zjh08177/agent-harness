---
name: obsidian-review
description: Human review of 01-Staging/ — approve, edit, or reject AI triage suggestions
user_invocable: true
---

# /obsidian-review — Stage 2: Human Review

**Purpose**: Present `01-Staging/` items for human review. User approves, edits, or rejects AI suggestions. Approved notes move to their final PARA location.

## Workflow

1. **Scan** `01-Staging/` for all `.md` files
2. **Present dashboard** — list all staged notes with AI suggestions:
   ```
   ## Staging Review (7 items)

   1. tesla-q4-analysis.md → Areas/Stocks/ [case, seed, investing]
   2. obsidian-plugin-ideas.md → Resources/Obsidian/ [tool, seed, productivity]
   3. standup-2024-03-15.md → Self/ [reflection, seed, work]
   ...

   Actions: [A]pprove all | [R]eview one-by-one | [S]kip
   ```
3. **For each reviewed note**:
   - Show AI suggestions and note preview (first 10 lines)
   - User chooses: Approve / Edit / Reject / Skip
   - **Approve**: Apply tags, move to target location, create wikilinks
   - **Edit**: User modifies suggestions, then apply
   - **Reject**: Move back to `00-Inbox/` with feedback note
   - **Skip**: Leave in staging for later
4. **On approve/edit**:
   a. Convert `ai_suggested` block into real frontmatter
   b. Rename file if `rename` was suggested and approved
   c. Move to target zone/sub-folder
   d. Add wikilinks to the note body (bottom section)

## Rules

- Always show the user what will change before applying
- Never auto-approve — this is the human decision gate
- After processing, report: N approved, N edited, N rejected, N remaining
- Target: Keep staging < 30 items
