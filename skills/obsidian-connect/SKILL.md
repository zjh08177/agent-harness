---
name: obsidian-connect
description: Find and create wikilinks between related notes across the vault
user_invocable: true
---

# /obsidian-connect — Wikilink Builder

**Purpose**: Analyze vault notes to discover and create meaningful `[[wikilink]]` connections between related notes.

## Usage

- `/obsidian-connect` — Scan recent/modified notes for connection opportunities
- `/obsidian-connect <note-path>` — Find connections for a specific note
- `/obsidian-connect --orphans` — Find orphan notes (no incoming/outgoing links)

## Workflow

### Default Mode (recent notes)
1. Find notes modified in the last 7 days
2. For each note, extract key concepts and entities
3. Search vault for related notes by:
   - Shared topics/tags
   - Similar content (keyword matching)
   - Referenced but non-existent notes (potential stubs)
4. Present connection suggestions:
   ```
   ## Connection Opportunities

   ### tesla-q4-analysis.md
   - Add link to [[Portfolio Strategy]] (shared topic: investing)
   - Add link to [[EV Market Trends]] (related concept)
   - Create stub: [[Tesla Valuation Model]] (referenced but doesn't exist)

   ### react-server-components.md
   - Add link to [[Frontend Architecture]] (shared topic)
   - Add link to [[Next.js Notes]] (related technology)
   ```
5. User approves/rejects each suggestion
6. Apply approved links by adding to note body

### Orphan Mode
1. Scan all vault notes
2. Identify notes with no `[[wikilinks]]` (incoming or outgoing)
3. For each orphan, suggest potential connections
4. Present as batch for review

## Rules

- **双链 protocol**: Use `[[wikilinks]]` for content nouns (people, concepts, projects), `#tags` for attributes only
- Never auto-apply — always present suggestions for human approval
- Prefer linking to existing notes over creating stubs
- Add links in a `## Related` section at the bottom of notes (create if missing)
- Report: N connections suggested, N approved, N orphans found
