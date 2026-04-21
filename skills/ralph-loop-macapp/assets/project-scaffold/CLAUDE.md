# [App Name]

[One-line description of the macOS app]

**Stack**: Swift 5.9+ / SwiftUI / AppKit

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

**Files**: `PRD.md`, `ARCHITECTURE.md`, `TASKS.md`, `TEST_INSTRUCTIONS.md`

**Rule**: Update docs when code changes affect documented behavior.

---

## Ralph-Loop Protocol

> Autonomous implementation loop with macOS Automator MCP verification.

### Prerequisites Checklist

Before starting Ralph Loop, ensure:

- [ ] **PRD complete** → `Docs/PRD.md` defines all features
- [ ] **Tech design complete** → `Docs/ARCHITECTURE.md` defines implementation
- [ ] **Tasks defined** → `Docs/TASKS.md` lists all atomic tasks
- [ ] **Xcode project exists** → `.xcodeproj` or `Package.swift` present
- [ ] **App builds** → `xcodebuild` succeeds
- [ ] **App running** → App launched and visible in menu bar
- [ ] **macOS Automator MCP enabled** → Check with `/mcp` command
- [ ] **Permissions granted** → Accessibility, Input Monitoring, Microphone as needed

### Build Commands

```bash
# Build
xcodebuild -scheme AppName -configuration Debug build

# Build and run
xcodebuild -scheme AppName -configuration Debug build && \
    open ~/Library/Developer/Xcode/DerivedData/AppName-*/Build/Products/Debug/AppName.app
```

### Iteration Protocol

Each iteration follows **ONE atomic task** from TASKS.md:

```
1. SELECT TASK
   - Pick next task from TASKS.md (e.g., "T1.1")
   - Task must be atomic (single responsibility)
   - Task must have defined acceptance criteria

2. IMPLEMENT
   - Write minimal code to pass the test
   - No scope creep - only what the task requires
   - Follow ARCHITECTURE.md patterns
   - Add accessibilityIdentifier to testable elements

3. BUILD & RUN
   - xcodebuild to compile
   - Launch app if not running
   - Check Console.app for errors

4. VERIFY
   - Use macOS Automator MCP to execute test
   - Check against acceptance criteria in TASKS.md
   - AppleScript/JXA for UI automation

5. EVALUATE
   - PASS → Mark task complete, update memory, next task
   - FAIL → Fix issue, rebuild, re-verify (max 3 retries)
   - BLOCKED → Log to findings.md, escalate to user

6. UPDATE MEMORY
   - Append to history.md: task ID, result, files changed
   - Update context.md: current state
   - Add discoveries to findings.md
```

### macOS Automator MCP Commands

```applescript
-- Check app running
tell application "System Events"
    set isRunning to exists process "AppName"
end tell
return isRunning

-- Click menu bar item
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
    end tell
end tell

-- Simulate hotkey (Option+Shift+S)
tell application "System Events"
    key down option
    key down shift
    keystroke "s"
    delay 1
    key up shift
    key up option
end tell

-- Get window elements
tell application "System Events"
    tell process "AppName"
        set windowInfo to properties of window 1
    end tell
end tell
return windowInfo
```

### Retry Policy

| Attempt | Action |
|---------|--------|
| 1 | Fix obvious issue, rebuild, re-test |
| 2 | Review ARCHITECTURE.md, check permissions, adjust approach |
| 3 | Log to findings.md, ask user for guidance |

---

## Code Style

- Swift 5.9+, SwiftUI for views, AppKit for system integration
- Keep files small and focused
- Use accessibilityIdentifier for all testable UI elements
- Follow KISS, DRY, YAGNI, SOLID
