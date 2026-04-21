# Memory File Templates

Templates for the four memory files used in Ralph Loop.

## context.md

```markdown
# Project Context

> Current state of the project. Update after each session.

## Project Overview

- **Name**: [Project Name]
- **Type**: [Web app / CLI / Library]
- **Stack**: [Tech stack]
- **Status**: [Planning / In Progress / Complete]

## Current Focus

- **Phase**: [Current phase from TASKS.md]
- **Task**: [Current task ID and title]

## Completed

- [x] [Completed item 1]
- [x] [Completed item 2]

## Active Files

\`\`\`
src/
├── [file1.tsx]    # [description]
├── [file2.tsx]    # [description]
└── components/
    └── [Component.tsx]  # [description]
\`\`\`

## Task Progress

| Phase | Status |
|-------|--------|
| 1. [Phase 1] | ✅ / 🔄 / ⏳ |
| 2. [Phase 2] | ✅ / 🔄 / ⏳ |

## Blocked Items

_None_ or list blocked items

## Next Steps

1. [Next action 1]
2. [Next action 2]

---

_Last updated: YYYY-MM-DD_
```

---

## history.md

```markdown
# Session History

> Chronological log of all work sessions. Append new entries at the top.

---

## YYYY-MM-DD - Session Title

### What was done
- [Completed item 1]
- [Completed item 2]
- [Completed item 3]

### Files changed
- \`path/to/file.tsx\` - [description]
- \`path/to/file.css\` - [description]

### State at end
[Brief description of where we left off]

---

## YYYY-MM-DD - Previous Session

...
```

---

## findings.md

```markdown
# Findings & Discoveries

> Gotchas, learnings, and important discoveries. Add new findings at the top.

---

## YYYY-MM-DD - Finding Title

**Context**: [Where/how this was discovered]

**Finding**: [What was learned]
- [Detail 1]
- [Detail 2]

**Impact**: [How this affects the project]

**Solution**: [How to handle it]

---

## YYYY-MM-DD - Previous Finding

...
```

---

## decisions.md

```markdown
# Architecture Decision Records

> Technical decisions and their rationale. Add new decisions at the top.

---

## ADR-XXX: Decision Title

**Date**: YYYY-MM-DD
**Status**: Proposed / Accepted / Deprecated

### Context

[What is the issue that we're seeing that is motivating this decision?]

### Decision

[What is the change that we're proposing?]

### Consequences

**Positive:**
- [Benefit 1]
- [Benefit 2]

**Negative:**
- [Drawback 1]
- [Drawback 2]

### Alternatives Considered

1. **[Alternative 1]** - [Why rejected]
2. **[Alternative 2]** - [Why rejected]

---

## ADR-001: Previous Decision

...
```

---

## Directory Structure

```
.claude/
└── memory/
    ├── context.md    # Current state (update every task)
    ├── history.md    # Session log (append at top)
    ├── findings.md   # Discoveries (append at top)
    └── decisions.md  # ADRs (append at top)
```

## Update Guidelines

| File | When to Update | How |
|------|----------------|-----|
| context.md | Every task | Overwrite with current state |
| history.md | End of session / major milestone | Append new entry at top |
| findings.md | When discovering gotcha | Append new entry at top |
| decisions.md | When making tech decision | Append new ADR at top |
