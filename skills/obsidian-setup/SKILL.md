---
name: obsidian-setup
description: First-time scaffold for Obsidian AI-native vault (八区架构, templates, agents, CLAUDE.md)
user_invocable: true
---

# /obsidian-setup — First-Time Vault Scaffold

**Purpose**: One-click setup that transforms an existing Obsidian vault into an AI-native knowledge system with 八区架构, 四维标签, and two-stage inbox.

## Prerequisites
- Must be run from within an Obsidian vault directory
- Vault should have existing PARA folders (Projects, Areas, Resources, Archives)

## What This Skill Does

1. **Creates 4 new folders** (does NOT touch existing ones):
   - `00-Inbox/` — All raw input lands here
   - `01-Staging/` — AI-triaged, awaiting human review
   - `Self/` — Journal + reflections + fleeting notes
   - `99-System/Templates/`, `99-System/Schemas/` — System configs

2. **Creates vault-level `.claude/` config**:
   - `settings.json` — Permissions
   - `agents/inbox-processor.md` — GTD inbox categorization
   - `agents/note-organizer.md` — Link repair, dedup, hygiene
   - `agents/research-assistant.md` — Multi-source research
   - `agents/weekly-reviewer.md` — Weekly synthesis
   - `hooks/post-session.sh` — Session end reminder

3. **Creates `CLAUDE.md`** at vault root with:
   - 八区 structure map
   - 四维标签 rules (type/, status/, src/, topic/)
   - Inbox processing protocol
   - Frontmatter schema
   - Skills reference

4. **Creates templates and schemas** in `99-System/`:
   - `Templates/note-template.md`
   - `Templates/project-template.md`
   - `Templates/daily-template.md`
   - `Templates/weekly-template.md`
   - `Templates/research-template.md`
   - `Schemas/frontmatter-schema.md`
   - `Schemas/tag-taxonomy.md`
   - `Dashboard.md`

5. **Does NOT** move, rename, or modify any existing files

## Execution Steps

1. Detect vault root (look for `.obsidian/` directory)
2. Verify existing PARA folders exist
3. Create folder structure
4. Write all config files, templates, schemas
5. Write `CLAUDE.md`
6. Print summary and next steps

## Next Steps (printed after setup)

```
Setup complete! Your vault now has:
- 八区架构 folder structure
- AI agents for inbox processing, research, and review
- Templates for daily notes, projects, and research
- Tag taxonomy and frontmatter schema

Recommended next steps:
1. Install kepano/obsidian-skills for markdown/bases/canvas skills
2. Run /obsidian-migrate to interactively move Journal/ → Self/
3. Run /obsidian-capture "test idea" to test the inbox
4. Run /obsidian-daily to generate your first daily note
```
