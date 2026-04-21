---
name: ralph-loop-webapp
description: |
  Autonomous web app development using the Ralph Loop protocol. This skill should be used when
  building localhost web applications iteratively with Playwright MCP verification. Triggers on
  "ralph loop", "build webapp", "implement from tasks", "fix bug", "add feature", or when a
  project has TASKS.md with atomic task definitions. Supports both full feature development and
  bug fix/small feature workflows with dual-approval gates. Requires Playwright MCP for browser
  automation and verification.
---

# Ralph Loop: Autonomous Web App Development

A systematic protocol for building web applications through atomic task execution with automated browser verification.

## Overview

Ralph Loop is an autonomous development workflow that:
1. Executes atomic tasks sequentially from TASKS.md
2. Verifies each task using Playwright MCP browser automation
3. Maintains context across sessions via memory files
4. Handles failures with a structured retry policy

## Workflow Modes

### Mode 1: Full Feature Development (from TASKS.md)

For new features with existing TASKS.md - skip to [Iteration Protocol](#iteration-protocol).

### Mode 2: Bug Fix / Small Feature Workflow

For bug fixes and small additional requirements:

#### Step 1: START SESSION
```
Read .claude/memory/context.md and findings.md
```

#### Step 2: CLARIFY REQUIREMENTS
- Don't code until requirements are clear
- Ask questions to understand the issue/requirement
- Confirm understanding before proceeding

#### Step 3: PROPOSE APPROACH
- Present solution approach
- Simplify it (apply KISS, YAGNI)
- **Wait for user approval** ⏸️

#### Step 4: BREAKDOWN INTO TASKS + UPDATE DOCS
After approach approval:
- Break solution into atomic, testable tasks
- Each task must have:
  - Clear acceptance criteria
  - Auto-verifiable steps (Playwright MCP)
  - Single responsibility
- **Update documentation** to reflect new requirement/solution:
  - `Docs/PRD.md` → Add/update requirement description
  - `Docs/ARCHITECTURE.md` → Add/update technical solution
  - `Docs/TASKS.md` → Add new atomic tasks
- Present task list and doc changes to user
- **Wait for user approval** ⏸️

#### Step 5: IMPLEMENT (Ralph Loop)
After task approval:
- Execute tasks using [Iteration Protocol](#iteration-protocol)
- **Each task must follow ALL steps (1-6)** - no merging, no skipping
- One task at a time with verification and auto-commit

**NOTE:** Memory updates and auto-commit happen per-task in the Iteration Protocol.
Session-end updates are only needed if session ends mid-task.

---

## Prerequisites Checklist

Before starting Ralph Loop iterations, verify:

```
- [ ] PRD complete → Docs/PRD.md defines all features
- [ ] Architecture defined → Docs/ARCHITECTURE.md defines implementation
- [ ] Tasks atomized → Docs/TASKS.md lists all tasks with acceptance criteria
- [ ] Test fixtures ready → test-fixtures/ contains test data
- [ ] Dev server running → App accessible at localhost
- [ ] Playwright MCP enabled → Browser automation available
```

To verify Playwright MCP: Check `/mcp` command or attempt `browser_navigate`.

## Iteration Protocol

Execute ONE atomic task per iteration.

**CRITICAL RULES:**
- **NO MERGING**: Each task must be implemented separately, even if small
- **NO SKIPPING**: Every step (1-6) must be followed for every task
- **NO BATCHING**: Complete all 6 steps before starting next task

---

### 1. SELECT TASK

Pick the next pending task from TASKS.md:
- Task must be atomic (single responsibility)
- Task must have defined acceptance criteria
- Task must have verification steps

Use `TodoWrite` to mark task as `in_progress`.

### 2. IMPLEMENT

Write minimal code to satisfy acceptance criteria:
- No scope creep - only what the task requires
- Follow patterns from ARCHITECTURE.md
- Use `data-testid` attributes for testable elements

### 3. VERIFY

Use Playwright MCP to execute verification:

```
# Navigation
browser_navigate → http://localhost:PORT

# Element interaction
browser_click → element with data-testid
browser_type → text input
browser_file_upload → file paths array

# Verification
browser_snapshot → accessibility tree (preferred)
browser_take_screenshot → visual verification
browser_console_messages → check for errors
```

### 4. EVALUATE

Based on verification results:
- **PASS** → Proceed to step 5
- **FAIL** → Fix issue, re-verify (max 3 retries)
- **BLOCKED** → Log to findings.md, ask user for guidance

### 5. UPDATE DOCS & MEMORY

**IMPORTANT: Update in this order (required for auto-commit hook):**

1. **`history.md` FIRST** → Append: task ID, result, files changed
   - This provides the commit message for auto-commit
2. `context.md` → Update: current state, next focus
3. `findings.md` → Add: any discoveries, gotchas, bugs found
4. `TASKS.md` → Mark task as complete (✅)
5. `CHANGELOG.md` → Add entry if user-facing change
6. `ARCHITECTURE.md` → Update if implementation differs from plan

### 6. MARK COMPLETE (triggers auto-commit)

Use `TodoWrite` to mark task as `completed`.

This triggers the auto-commit hook which:
- Checks that `history.md` was updated
- Extracts commit message from history.md
- Commits all changes
- Pushes to remote

**Do NOT proceed to next task until step 6 is complete.**

---

## Memory Protocol

Memory files in `.claude/memory/`:

| File | Purpose | Update Frequency |
|------|---------|------------------|
| `context.md` | Current state, next steps | Every task |
| `history.md` | Session log (newest at top) | Every task |
| `findings.md` | Bugs, gotchas, learnings | When discovered |
| `decisions.md` | Technical decisions (ADRs) | When decisions made |

**On START**: Read `context.md` and `findings.md`
**On END**: Update all relevant memory files

## Task Granularity

**Good (atomic):**
- "Create file input that accepts .pdf files"
- "Display filename after upload"
- "Render first page of uploaded PDF"

**Bad (too broad):**
- "Implement PDF upload feature"
- "Add signature functionality"

Each task should be completable in 1-3 tool calls.

## Retry Policy

| Attempt | Action |
|---------|--------|
| 1 | Fix obvious issue, re-verify |
| 2 | Review ARCHITECTURE.md, adjust approach |
| 3 | Log to findings.md, ask user for guidance |

## Playwright MCP Patterns

Common verification patterns:

```javascript
// Check element exists
browser_snapshot → look for element in accessibility tree

// File upload flow
browser_click → file input
browser_file_upload → ["/path/to/test-file.pdf"]

// Form interaction
browser_type → {element, ref, text}
browser_click → submit button

// Visual verification
browser_take_screenshot → {filename: "step-name.png"}

// Dialog handling
browser_handle_dialog → {accept: true, promptText: "value"}

// Multi-step with code
browser_run_code → async (page) => { /* operations */ }
```

## Project Structure

Recommended structure for Ralph Loop projects:

```
project/
├── CLAUDE.md              # Project instructions with Ralph Loop config
├── Docs/
│   ├── PRD.md             # Product requirements
│   ├── ARCHITECTURE.md    # Technical design
│   └── TASKS.md           # Atomic task list
├── .claude/
│   └── memory/
│       ├── context.md     # Current state
│       ├── history.md     # Session log
│       ├── findings.md    # Discoveries
│       └── decisions.md   # ADRs
├── test-fixtures/         # Test data files
├── scripts/               # Helper scripts
└── src/                   # Source code
```

## Best Practices

1. **Start small**: Begin with UI shell before adding functionality
2. **Test early**: Verify each component works before moving on
3. **Use data-testid**: Add testable attributes to all interactive elements
4. **Screenshot failures**: Capture visual state when tests fail
5. **Document findings**: Record gotchas immediately in findings.md
6. **Atomic commits**: One task = one logical change

## Resources

### references/

- `tasks-template.md` - Template for TASKS.md with proper structure
- `common-gotchas.md` - Platform-specific issues and solutions
- `memory-templates.md` - Templates for memory files

### assets/

- `project-scaffold/` - Starter project structure with all required files
