# Tasks Template

Template for creating TASKS.md with atomic task definitions for Ralph Loop.

## Structure

```markdown
# Tasks: [Project Name]

> Version: X.X | Updated: YYYY-MM-DD

## Overview

Atomic tasks for Ralph Loop implementation. Each task has:
- **Single responsibility**
- **Clear acceptance criteria**
- **Playwright MCP verification**

---

## Task Status Legend

- `[ ]` Pending
- `[~]` In Progress
- `[x]` Complete
- `[!]` Blocked

---

## Phase 1: [Phase Name]

### T1.1 [Task Title]
**Goal:** [One-sentence description of what this task accomplishes]

**Implementation:**
- [Specific code/file change 1]
- [Specific code/file change 2]
- [Specific code/file change 3]

**Acceptance Criteria:**
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
- [ ] [Testable criterion 3]

**Verification:**
\`\`\`
1. Navigate to http://localhost:PORT
2. [Playwright action]
3. Verify: [Expected result]
\`\`\`

---

### T1.2 [Next Task Title]
...

---

## Phase 2: [Next Phase Name]

### T2.1 [Task Title]
...
```

## Guidelines

### Task Naming
- Use format: `T{phase}.{task}` (e.g., T1.1, T2.3)
- Keep task titles short but descriptive
- Start with action verb: "Create", "Add", "Implement", "Fix"

### Goal Statement
- One sentence only
- Describes the outcome, not the implementation
- Example: "Basic app structure with toolbar and viewer areas"

### Implementation Section
- 3-5 bullet points maximum
- Specific file/component names
- No vague instructions

### Acceptance Criteria
- Testable with Playwright MCP
- Use checkboxes `[ ]` for tracking
- Be specific about expected behavior

### Verification Section
- Step-by-step Playwright commands
- Include data-testid references
- End with clear pass/fail condition

## Example Phase Progression

Typical web app phases:

1. **App Shell** - Layout, routing, base components
2. **Data Input** - Forms, file uploads, user input
3. **Data Display** - Rendering, formatting, visualization
4. **Navigation** - Pagination, filtering, search
5. **Interactions** - Drag/drop, modals, dialogs
6. **State Management** - CRUD operations, persistence
7. **Export/Output** - Downloads, sharing, printing
8. **Error Handling** - Validation, error states, recovery
