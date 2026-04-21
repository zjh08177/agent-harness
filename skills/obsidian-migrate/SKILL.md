---
name: obsidian-migrate
description: One-time interactive migration — move Journal/ → Self/, suggest re-tags for existing notes
user_invocable: true
---

# /obsidian-migrate — One-Time Migration

**Purpose**: Interactively migrate existing vault content to the new 八区架构. Moves `Journal/` entries to `Self/`, and suggests re-tagging for notes missing 四维标签.

## Workflow

### Phase 1: Journal → Self Migration
1. **Scan** `Journal/` for all `.md` files
2. **Present plan**:
   ```
   ## Journal → Self Migration

   Found 42 journal entries in Journal/
   Proposed: Move all to Self/ (preserving filenames)

   Preview:
   - Journal/2024-01-15-standup.md → Self/2024-01-15-standup.md
   - Journal/2024-01-16-retro.md → Self/2024-01-16-retro.md
   ...

   [A]pprove all | [R]eview one-by-one | [S]kip phase
   ```
3. **On approve**: Move files, update any `[[wikilinks]]` pointing to old paths
4. **After move**: Optionally delete empty `Journal/` folder (ask user)

### Phase 2: Re-Tag Existing Notes
1. **Scan** all PARA zones for notes missing 四维标签 frontmatter
2. **Batch by zone** (e.g., "12 notes in Projects/ missing tags")
3. **For each batch**, suggest tags:
   ```yaml
   ---
   type: project       # AI suggested
   status: growing     # AI suggested
   src: original       # AI suggested
   topic: [aigc]       # AI suggested
   ---
   ```
4. **User reviews** each suggestion: Approve / Edit / Skip
5. **Apply** approved tags (merge with existing frontmatter)

### Phase 3: Summary
- Report: N files moved, N notes re-tagged, N skipped
- Suggest running `/obsidian-connect` to find new link opportunities

## Rules

- **Interactive only** — every move and tag requires user approval
- **Non-destructive** — original content is never modified, only frontmatter added
- **Wikilink repair** — after moving files, grep vault for broken `[[wikilinks]]` and fix
- **Idempotent** — safe to run multiple times (skips already-migrated content)
- Phase 2 can be run standalone: `/obsidian-migrate --tags-only`
