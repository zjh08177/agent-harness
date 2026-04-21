---
name: ralph-loop-macapp
description: |
  Autonomous native macOS app development using the Ralph Loop protocol. This skill should be used
  when building Swift/SwiftUI Mac applications iteratively with macOS Automator MCP verification.
  Triggers on "ralph loop macapp", "build mac app", "implement mac app from tasks", or when a
  project has TASKS.md with atomic task definitions for a native macOS application.

  IMPORTANT: Requires approved PRD, ARCHITECTURE, and TASKS.md before execution.
  Requires macOS Automator MCP for AppleScript/JXA automation and verification.
---

# Ralph Loop: Autonomous macOS App Development

Systematic protocol for building native macOS apps through atomic task execution with AppleScript/JXA verification.

---

## Prerequisites (ALL MUST BE USER-APPROVED)

Before starting Ralph Loop, verify all prerequisites are approved:

```
- [x] PRD approved        → Docs/PRD.md (user approved)
- [x] ARCH approved       → Docs/ARCHITECTURE.md (user approved)
- [x] TASKS approved      → Docs/TASKS.md (user approved)
- [ ] Xcode project       → .xcodeproj or Package.swift present
- [ ] App builds          → xcodebuild succeeds
- [ ] App running         → App launched and accessible
- [ ] macOS Automator MCP → AppleScript execution available
- [ ] Permissions granted → Accessibility, Input Monitoring as needed
```

**DO NOT START if PRD, ARCH, or TASKS are not explicitly approved by user.**

To verify macOS Automator MCP: `mcp__macos-automator__get_scripting_tips`

---

## Iteration Protocol

Execute ONE atomic task per iteration.

**CRITICAL RULES:**
- **NO MERGING**: Each task must be implemented separately, even if small
- **NO SKIPPING**: Every step (1-7) must be followed for every task
- **NO BATCHING**: Complete all 7 steps before starting next task

---

### 1. SELECT TASK

Pick next pending task from TASKS.md:
- Must be atomic (single responsibility)
- Must have acceptance criteria
- Must have verification steps

Use `TodoWrite` to mark task as `in_progress`.

### 2. IMPLEMENT

Write minimal code to satisfy acceptance criteria:
- No scope creep — only what task requires
- Follow ARCHITECTURE.md patterns
- Add `accessibilityIdentifier` to testable elements

### 3. BUILD & RUN

```bash
# Build
xcodebuild -scheme AppName -configuration Debug build

# Build and run
xcodebuild -scheme AppName -configuration Debug build && open /path/to/AppName.app
```

### 4. VERIFY

Use macOS Automator MCP to execute verification (see patterns below).

### 5. EVALUATE

| Result | Action |
|--------|--------|
| PASS | Proceed to step 6 |
| FAIL | Fix, rebuild, re-verify (max 3 retries) |
| BLOCKED | Log to findings.md, ask user |

### 6. UPDATE DOCS & MEMORY

**IMPORTANT: Update in this order (required for auto-commit hook):**

1. **`history.md` FIRST** → Append: task ID, result, files changed
   - This provides the commit message for auto-commit
2. `context.md` → Update: current state, next focus
3. `findings.md` → Add: any discoveries, gotchas, bugs found
4. `TASKS.md` → Mark task as complete (✅)
5. `CHANGELOG.md` → Add entry if user-facing change
6. `ARCHITECTURE.md` → Update if implementation differs from plan

### 7. MARK COMPLETE (triggers auto-commit)

Use `TodoWrite` to mark task as `completed`.

This triggers the auto-commit hook which:
- Checks that `history.md` was updated
- Extracts commit message from history.md
- Commits all changes
- Pushes to remote

**Do NOT proceed to next task until step 7 is complete.**

---

---

## Retry Policy

| Attempt | Action |
|---------|--------|
| 1 | Fix obvious issue, rebuild, re-verify |
| 2 | Review ARCHITECTURE.md, check permissions |
| 3 | Log to findings.md, ask user |

---

## macOS Automator MCP Patterns

### Check App Running
```javascript
mcp__macos-automator__execute_script({
  language: "javascript",
  script_content: `
    const se = Application("System Events");
    return { running: se.processes.byName("AppName").exists() };
  `
})
```

### Click Menu Bar Item
```applescript
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
        delay 0.3
        set menuItems to name of every menu item of menu 1 of menu bar item 1 of menu bar 2
    end tell
end tell
return menuItems
```

### Simulate Hotkey
```applescript
tell application "System Events"
    key down option
    keystroke space
    delay 1
    key up space
    key up option
end tell
```

### Get Window Elements
```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
const window = app.windows[0];
return {
    title: window.title(),
    buttons: window.buttons.name(),
    textFields: window.textFields.name(),
    staticTexts: window.staticTexts.value()
};
```

### Check Element by Accessibility ID
```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
const buttons = app.windows[0].buttons.whose({description: "submit-button"});
return { found: buttons.length > 0 };
```

### Type into Text Field
```applescript
tell application "System Events"
    tell process "AppName"
        set focused of text field 1 of window 1 to true
        keystroke "test input"
    end tell
end tell
```

---

## Accessibility Identifiers

For testable elements:

```swift
// SwiftUI
Button("Submit") { }
    .accessibilityIdentifier("submit-button")

TextField("API Key", text: $apiKey)
    .accessibilityIdentifier("api-key-field")

// AppKit
button.setAccessibilityIdentifier("submit-button")
```

---

## Task Granularity

**Good (atomic):**
- "Create menu bar status item with icon"
- "Add preferences window with API key field"
- "Implement global hotkey detection"

**Bad (too broad):**
- "Implement menu bar app"
- "Add settings functionality"

Each task: 1-5 tool calls to complete.

---

## Limitations

**Cannot automate:**
- Microphone/audio input (needs virtual device)
- Permission grant dialogs (manual first)
- Some secure text fields

**Workarounds:**
- Audio: Use BlackHole virtual audio device
- Permissions: Document in TEST_INSTRUCTIONS.md
- Secure fields: Use Keychain API, verify via behavior

---

## Best Practices

1. Build frequently — verify code compiles after each change
2. Test permissions early — grant before testing
3. Use accessibility IDs on all interactive elements
4. Log to Console with `os_log` or `print`
5. Document findings immediately
6. Atomic commits — one task = one logical change
