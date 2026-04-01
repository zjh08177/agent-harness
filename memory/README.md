# Memory System

Dual-system memory that gives agents persistent cross-session knowledge.

## Two Systems, Non-Overlapping Roles

| System | Role | When |
|--------|------|------|
| **Auto-memory files** (`~/.claude/projects/.../memory/`) | Per-project SSOT, typed, always loaded | All learnings, decisions, feedback |
| **MCP Memory** (`mcp__memory` tools) | Cross-project entity-observation graph | Recalling patterns from OTHER projects |

## Memory Types

Each memory file has typed frontmatter:

- **user** — Role, preferences, knowledge level
- **feedback** — Corrections and confirmed approaches (rule + WHY + how to apply)
- **project** — Ongoing work context, decisions, deadlines
- **reference** — Pointers to external resources

## Quality Rules

Before saving ANY memory, ask: **"Would a future session be measurably more efficient knowing this?"**

**DO save**: Non-obvious decisions with WHY, validated patterns, user corrections, surprising findings.

**DO NOT save**: Session logs, git history, debugging recipes, file paths that change.

**Format**: Lead with the rule, then `**Why:**` and `**How to apply:**`.

## Setup

```bash
mkdir -p ~/.claude/projects/<your-project>/memory/
cp MEMORY.md.template ~/.claude/projects/<your-project>/memory/MEMORY.md
```

See `examples/` for one sample of each memory type.
