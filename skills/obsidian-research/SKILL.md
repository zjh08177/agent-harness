---
name: obsidian-research
description: 4R deep research workflow — Request, Research, Refine, Report with vault integration
user_invocable: true
---

# /obsidian-research — 4R Deep Research

**Purpose**: Conduct structured research using the 4R framework (Request → Research → Refine → Report), saving all artifacts to the vault.

## Usage

`/obsidian-research <topic or question>`

## 4R Framework

### R1: Request (Clarify)
1. Parse the research question
2. Check vault for existing notes on this topic (grep + glob)
3. Identify what's already known vs. what needs research
4. Confirm scope with user: breadth vs. depth, sources to include

### R2: Research (Gather)
1. Search multiple sources (web, vault notes, linked references)
2. For each source, create a capture note in `00-Inbox/` with:
   ```yaml
   ---
   type: case
   status: seed
   src: web  # or book, video, conversation
   topic: [<research-topic>]
   research_session: "{{session_id}}"
   ---
   ```
3. Extract key claims, data points, and quotes
4. Note contradictions and gaps

### R3: Refine (Synthesize)
1. Cross-reference findings across sources
2. Identify patterns, consensus, and outliers
3. Connect to existing vault knowledge via `[[wikilinks]]`
4. Upgrade note status from `seed` → `growing`

### R4: Report (Deliver)
1. Create research report from `99-System/Templates/research-template.md`
2. Save to appropriate PARA zone:
   - Active project research → `Projects/<project>/`
   - Domain knowledge → `Resources/<topic>/`
   - Ongoing responsibility → `Areas/<area>/`
3. Link all source notes to the report
4. Present summary to user

## File Location

Report: `<PARA-zone>/<sub-folder>/research-<topic>.md`
Source notes: `00-Inbox/` → triaged via `/obsidian-inbox`

## Rules

- Always check vault first — don't research what you already know
- Cite sources with links or references
- Each source gets its own capture note (atomic notes)
- The report synthesizes; source notes preserve raw material
- Ask user before creating > 5 new notes
