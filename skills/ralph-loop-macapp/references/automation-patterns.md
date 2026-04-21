# Automation Patterns: macOS Automator MCP

AppleScript and JXA patterns for testing macOS apps with Ralph Loop.

## Basic Patterns

### Check If App Is Running

**AppleScript:**
```applescript
tell application "System Events"
    set isRunning to exists process "AppName"
end tell
return isRunning
```

**JXA:**
```javascript
const se = Application("System Events");
const running = se.processes.byName("AppName").exists();
JSON.stringify({ running });
```

### Launch App

**AppleScript:**
```applescript
tell application "AppName" to activate
delay 1
```

**JXA:**
```javascript
const app = Application("AppName");
app.activate();
delay(1);
```

### Quit App

**AppleScript:**
```applescript
tell application "AppName" to quit
```

**JXA:**
```javascript
const app = Application("AppName");
app.quit();
```

---

## Menu Bar Apps

### Click Status Item

```applescript
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
    end tell
end tell
```

### Get Menu Items

```applescript
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
        delay 0.3
        set menuItems to name of every menu item of menu 1 of menu bar item 1 of menu bar 2
        keystroke escape -- close menu
    end tell
end tell
return menuItems
```

### Click Specific Menu Item

```applescript
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
        delay 0.2
        click menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2
    end tell
end tell
```

### Check Menu Bar Icon State

```applescript
tell application "System Events"
    tell process "AppName"
        set iconInfo to properties of menu bar item 1 of menu bar 2
    end tell
end tell
return iconInfo
```

---

## Window Operations

### Count Windows

```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
JSON.stringify({ windowCount: app.windows.length });
```

### Get Window Properties

```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
const win = app.windows[0];
JSON.stringify({
    title: win.title(),
    position: win.position(),
    size: win.size(),
    focused: win.focused()
});
```

### Close Window

```applescript
tell application "System Events"
    tell process "AppName"
        click button 1 of window 1 -- close button
    end tell
end tell
```

### Bring Window to Front

```applescript
tell application "AppName" to activate
tell application "System Events"
    tell process "AppName"
        set frontmost to true
    end tell
end tell
```

---

## UI Element Interaction

### Click Button by Name

```applescript
tell application "System Events"
    tell process "AppName"
        click button "Save" of window 1
    end tell
end tell
```

### Click Button by Position

```applescript
tell application "System Events"
    tell process "AppName"
        click button 1 of window 1  -- first button
    end tell
end tell
```

### Get All Buttons

```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
const buttons = app.windows[0].buttons.name();
JSON.stringify({ buttons });
```

### Type in Text Field

```applescript
tell application "System Events"
    tell process "AppName"
        set focused of text field 1 of window 1 to true
        keystroke "Hello World"
    end tell
end tell
```

### Clear and Replace Text Field

```applescript
tell application "System Events"
    tell process "AppName"
        set focused of text field 1 of window 1 to true
        keystroke "a" using command down  -- select all
        keystroke "New Text"
    end tell
end tell
```

### Get Text Field Value

```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
const value = app.windows[0].textFields[0].value();
JSON.stringify({ value });
```

### Click Checkbox

```applescript
tell application "System Events"
    tell process "AppName"
        click checkbox "Enable feature" of window 1
    end tell
end tell
```

### Check Checkbox State

```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
const checkbox = app.windows[0].checkboxes[0];
JSON.stringify({
    title: checkbox.title(),
    checked: checkbox.value() === 1
});
```

---

## Keyboard Simulation

### Simple Keystroke

```applescript
tell application "System Events"
    keystroke "hello"
end tell
```

### Keystroke with Modifiers

```applescript
tell application "System Events"
    -- Cmd+S
    keystroke "s" using command down

    -- Cmd+Shift+S
    keystroke "s" using {command down, shift down}

    -- Option+Space
    keystroke space using option down
end tell
```

### Key Down / Key Up (for Hold-to-Talk)

```applescript
tell application "System Events"
    key down option
    key down space
    delay 2  -- hold for 2 seconds
    key up space
    key up option
end tell
```

### Special Keys

```applescript
tell application "System Events"
    -- Escape
    key code 53

    -- Return/Enter
    key code 36

    -- Tab
    key code 48

    -- Arrow keys
    key code 123  -- left
    key code 124  -- right
    key code 125  -- down
    key code 126  -- up

    -- Function keys
    key code 122  -- F1
    key code 120  -- F2
end tell
```

---

## Finding Elements

### By Accessibility Identifier

```javascript
const se = Application("System Events");
const app = se.processes.byName("AppName");
// SwiftUI uses description for accessibilityIdentifier
const buttons = app.windows[0].buttons.whose({description: "submit-button"});
JSON.stringify({ found: buttons.length > 0 });
```

### By Title/Name

```applescript
tell application "System Events"
    tell process "AppName"
        set btn to first button of window 1 whose title is "Submit"
        click btn
    end tell
end tell
```

### Get UI Hierarchy

```javascript
function describeElement(el, depth = 0) {
    const indent = "  ".repeat(depth);
    let desc = `${indent}${el.role()}: "${el.title() || el.description() || ''}"`;

    try {
        const children = el.uiElements();
        for (let i = 0; i < children.length; i++) {
            desc += "\n" + describeElement(children[i], depth + 1);
        }
    } catch (e) {}

    return desc;
}

const se = Application("System Events");
const app = se.processes.byName("AppName");
describeElement(app.windows[0]);
```

---

## Waiting and Timing

### Wait for Window

```applescript
tell application "System Events"
    repeat 10 times
        if exists window 1 of process "AppName" then
            exit repeat
        end if
        delay 0.5
    end repeat
end tell
```

### Wait for Element

```javascript
function waitForElement(app, predicate, timeout = 5) {
    const startTime = Date.now();
    while ((Date.now() - startTime) / 1000 < timeout) {
        try {
            if (predicate(app)) return true;
        } catch (e) {}
        delay(0.5);
    }
    return false;
}

const se = Application("System Events");
const app = se.processes.byName("AppName");
const found = waitForElement(app, (a) => a.windows.length > 0);
JSON.stringify({ found });
```

---

## Complete Test Examples

### Test: Menu Bar App Opens Settings

```applescript
-- Click menu bar item
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
        delay 0.3
        click menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2
    end tell
end tell

delay 0.5

-- Verify settings window opened
tell application "System Events"
    tell process "AppName"
        set windowExists to exists window "Settings"
        set windowCount to count of windows
    end tell
end tell

return {windowExists:windowExists, windowCount:windowCount}
```

### Test: Hotkey Triggers Recording State

```applescript
-- Simulate hotkey
tell application "System Events"
    key down option
    key down shift
    keystroke "s"
end tell

delay 0.5

-- Check state changed (menu bar icon description or title)
tell application "System Events"
    tell process "AppName"
        set iconState to description of menu bar item 1 of menu bar 2
    end tell
end tell

-- Release hotkey
tell application "System Events"
    key up shift
    key up option
end tell

return iconState
```

### Test: API Key Saved to Preferences

```applescript
-- Open settings
tell application "System Events"
    tell process "AppName"
        click menu bar item 1 of menu bar 2
        delay 0.2
        click menu item "Settings..." of menu 1 of menu bar item 1 of menu bar 2
    end tell
end tell

delay 0.5

-- Enter API key
tell application "System Events"
    tell process "AppName"
        set focused of text field 1 of window 1 to true
        keystroke "a" using command down
        keystroke "sk-test-api-key-12345"
        click button "Save" of window 1
    end tell
end tell

delay 0.3

-- Verify window closed or saved indicator
tell application "System Events"
    tell process "AppName"
        set windowCount to count of windows
    end tell
end tell

return windowCount
```

---

## MCP Invocation Patterns

### Using execute_script with AppleScript

```
mcp__macos-automator__execute_script
- language: applescript
- script_content: |
    tell application "System Events"
        tell process "AppName"
            click menu bar item 1 of menu bar 2
        end tell
    end tell
```

### Using execute_script with JXA

```
mcp__macos-automator__execute_script
- language: javascript
- script_content: |
    const se = Application("System Events");
    const app = se.processes.byName("AppName");
    JSON.stringify({ windows: app.windows.length });
```

### Using Knowledge Base Scripts

```
mcp__macos-automator__get_scripting_tips
- search_term: "menu bar click"

mcp__macos-automator__execute_script
- kb_script_id: "system_menu_bar_click"
- input_data: { "appName": "AppName" }
```
