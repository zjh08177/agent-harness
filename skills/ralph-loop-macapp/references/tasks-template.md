# Tasks Template for macOS Apps

Template for creating TASKS.md with atomic task definitions for Ralph Loop macOS development.

## Structure

```markdown
# Tasks: [App Name]

> Version: X.X | Updated: YYYY-MM-DD

## Overview

Atomic tasks for Ralph Loop implementation. Each task has:
- **Single responsibility**
- **Clear acceptance criteria**
- **macOS Automator MCP verification**

---

## Task Status Legend

- `[ ]` Pending
- `[~]` In Progress
- `[x]` Complete
- `[!]` Blocked

---

## Phase 1: [Phase Name]

### T1.1 [Task Title]
**Goal:** [One-sentence description]

**Implementation:**
- [Specific code/file change 1]
- [Specific code/file change 2]

**Acceptance Criteria:**
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]

**Verification:**
\`\`\`applescript
-- AppleScript/JXA verification
tell application "System Events"
    tell process "AppName"
        -- verification steps
    end tell
end tell
\`\`\`

---
```

## Guidelines

### Task Naming
- Use format: `T{phase}.{task}` (e.g., T1.1, T2.3)
- Keep task titles short but descriptive
- Start with action verb: "Create", "Add", "Implement", "Fix"

### Goal Statement
- One sentence only
- Describes the outcome, not the implementation
- Example: "Menu bar icon visible with idle state indicator"

### Implementation Section
- 3-5 bullet points maximum
- Specific file/component names
- Include Swift/SwiftUI patterns to use

### Acceptance Criteria
- Testable with macOS Automator MCP
- Use checkboxes `[ ]` for tracking
- Be specific about expected behavior

### Verification Section
- AppleScript or JXA code
- Include process name and element references
- End with clear pass/fail condition

## Example Phase Progression

Typical macOS menu bar app phases:

1. **App Shell** - Menu bar item, basic structure, LSUIElement
2. **UI Components** - Preferences window, status menu
3. **Core Services** - Hotkey detection, audio recording
4. **API Integration** - OpenAI transcription, error handling
5. **System Integration** - Accessibility, text insertion
6. **State Management** - App state, user preferences
7. **Persistence** - Keychain, UserDefaults
8. **Polish** - Icons, animations, edge cases

## macOS-Specific Verification Patterns

### Check Menu Bar Item Exists
```applescript
tell application "System Events"
    tell process "AppName"
        return exists menu bar item 1 of menu bar 2
    end tell
end tell
```

### Verify Menu Contents
```applescript
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
        delay 0.3
        set menuItems to name of every menu item of menu 1 of menu bar item 1 of menu bar 2
        keystroke escape
    end tell
end tell
return menuItems
```

### Check Window Opens
```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
delay(0.5);
return {
    windowCount: app.windows.length,
    windowTitle: app.windows.length > 0 ? app.windows[0].title() : null
};
```

### Verify Button Click Response
```applescript
tell application "System Events"
    tell process "AppName"
        click button "Save" of window 1
        delay 0.3
        -- Check for expected result (e.g., window closes)
        return (count of windows)
    end tell
end tell
```

### Simulate Hotkey and Check State
```applescript
-- Simulate hotkey
tell application "System Events"
    key down option
    keystroke space
    delay 0.5
end tell

-- Check app state changed
tell application "System Events"
    tell process "AppName"
        set iconDesc to description of menu bar item 1 of menu bar 2
    end tell
end tell

-- Release hotkey
tell application "System Events"
    key up space
    key up option
end tell

return iconDesc
```
