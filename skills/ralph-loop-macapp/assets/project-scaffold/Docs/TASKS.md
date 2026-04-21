# Tasks: [App Name]

> Version: 0.1 | Updated: YYYY-MM-DD

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

## Phase 1: App Shell

### T1.1 Create Xcode Project
**Goal:** Basic macOS app project with correct configuration

**Implementation:**
- Create new macOS App project in Xcode
- Set deployment target to macOS 13.0+
- Configure as LSUIElement (no dock icon)
- Add required Info.plist keys

**Acceptance Criteria:**
- [ ] Project builds without errors
- [ ] App launches without dock icon
- [ ] App appears in Activity Monitor

**Verification:**
```bash
xcodebuild -scheme AppName -configuration Debug build
# Should succeed with no errors
```

---

### T1.2 Add Menu Bar Status Item
**Goal:** App shows icon in menu bar

**Implementation:**
- Create NSStatusItem in AppDelegate
- Set status item button image
- Retain status item as property

**Acceptance Criteria:**
- [ ] Menu bar icon visible when app runs
- [ ] Icon appears in correct menu bar area

**Verification:**
```applescript
tell application "System Events"
    tell process "AppName"
        return exists menu bar item 1 of menu bar 2
    end tell
end tell
-- Should return: true
```

---

### T1.3 Add Status Menu
**Goal:** Clicking menu bar icon shows dropdown menu

**Implementation:**
- Create NSMenu with basic items
- Attach menu to status item
- Add "Quit" menu item

**Acceptance Criteria:**
- [ ] Clicking icon shows menu
- [ ] Menu contains expected items
- [ ] Quit item terminates app

**Verification:**
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
-- Should contain: {"Status", "-", "Settings...", "Quit"}
```

---

## Phase 2: Preferences

### T2.1 Create Preferences Window
**Goal:** Settings menu item opens preferences window

**Implementation:**
- Create SwiftUI PreferencesView
- Add Settings scene to App
- Connect menu item to open settings

**Acceptance Criteria:**
- [ ] "Settings..." menu item opens window
- [ ] Window has correct title
- [ ] Window is properly styled

**Verification:**
```applescript
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
        delay 0.2
        click menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2
    end tell
end tell
delay 0.5
tell application "System Events"
    return (count of windows of process "AppName")
end tell
-- Should return: 1
```

---

### T2.2 Add API Key Input Field
**Goal:** User can enter API key in preferences

**Implementation:**
- Add SecureField for API key
- Add accessibilityIdentifier
- Style appropriately

**Acceptance Criteria:**
- [ ] Text field visible in preferences
- [ ] Field accepts input
- [ ] Field is accessible for testing

**Verification:**
```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
const textFields = app.windows[0].textFields.length;
JSON.stringify({ textFieldCount: textFields });
// Should have at least 1 text field
```

---

## Phase 3: Core Service

### T3.1 [First Core Task]
**Goal:** [Description]

**Implementation:**
- [Step 1]
- [Step 2]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Verification:**
```applescript
-- Verification script
```

---

## Phase 4: Integration

### T4.1 [Integration Task]
**Goal:** [Description]

**Implementation:**
- [Step 1]
- [Step 2]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Verification:**
```applescript
-- Verification script
```

---

## Phase 5: Polish

### T5.1 [Polish Task]
**Goal:** [Description]

**Implementation:**
- [Step 1]
- [Step 2]

**Acceptance Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Verification:**
```applescript
-- Verification script
```
