# [Project Name]

[One-line description of the project]

**Stack**: [Technology stack]

---

## Memory Protocol

> Update memory files after each task/iteration to maintain continuity.

**Files** (in `.claude/memory/`):
- `context.md` - Current state, focus, next steps
- `history.md` - Session log (append new entries at top)
- `findings.md` - Discoveries, bugs, gotchas
- `decisions.md` - Technical decisions (ADRs)

**On START**: Read `context.md` and `findings.md`

**On END** (session or ralph-loop iteration):
1. Append to `history.md`: date, what was done, files changed
2. Update `context.md`: current state, next steps
3. Add new discoveries to `findings.md`

---

## Docs Protocol

**Location**: `/Docs` folder for stable, versioned documentation

**Files**: `PRD.md`, `ARCHITECTURE.md`, `TASKS.md`

**Rule**: Update docs when code changes affect documented behavior.

---

## Ralph-Loop Protocol

> Autonomous implementation loop with verification.

### Prerequisites Checklist

Before starting Ralph Loop, ensure:

- [ ] **PRD complete** → `Docs/PRD.md` defines all features
- [ ] **Tech design complete** → `Docs/ARCHITECTURE.md` defines implementation
- [ ] **Tasks defined** → `Docs/TASKS.md` lists all atomic tasks
- [ ] **Test fixtures created** → `test-fixtures/` contains test data
- [ ] **App running** → `npm run dev` on localhost
- [ ] **Playwright MCP enabled** → Check with `/mcp` command

### Iteration Protocol

Each iteration follows **ONE atomic task** from TASKS.md:

```
1. SELECT TASK
   - Pick next task from TASKS.md
   - Task must be atomic (single responsibility)
   - Task must have defined acceptance criteria

2. IMPLEMENT
   - Write minimal code to pass the test
   - No scope creep - only what the task requires
   - Follow ARCHITECTURE.md patterns

3. VERIFY
   - Use Playwright MCP to execute test
   - Check against acceptance criteria in TASKS.md
   - Take screenshot if visual verification needed

4. EVALUATE
   - PASS → Mark task complete, update memory, next task
   - FAIL → Fix issue, re-verify (max 3 retries)
   - BLOCKED → Log to findings.md, escalate to user

5. UPDATE MEMORY
   - Append to history.md: task ID, result, files changed
   - Update context.md: current state
   - Add discoveries to findings.md
```

### Retry Policy

| Attempt | Action |
|---------|--------|
| 1 | Fix obvious issue, re-test |
| 2 | Review ARCHITECTURE.md, adjust approach |
| 3 | Log to findings.md, ask user for guidance |

---

## Code Style

- TypeScript, functional components
- Keep components small and focused
- Follow KISS, DRY, YAGNI, SOLID
