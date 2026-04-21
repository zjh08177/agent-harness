# Common Gotchas: macOS App Development

Platform-specific issues discovered during Ralph Loop macOS development.

## Swift / Xcode

### Missing Entitlements

**Error:** App crashes or feature doesn't work silently

**Context:** Using system features without proper entitlements

**Solution:** Add required entitlements to `*.entitlements` file:
```xml
<!-- For Accessibility API -->
<key>com.apple.security.automation.apple-events</key>
<true/>

<!-- For Keychain access -->
<key>com.apple.security.keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)com.yourcompany.appname</string>
</array>
```

---

### Menu Bar App Not Showing

**Error:** App runs but no menu bar icon appears

**Context:** LSUIElement is set but NSStatusItem not created properly

**Cause:** NSStatusItem must be retained and created on main thread

**Solution:**
```swift
// Wrong - not retained
func applicationDidFinishLaunching(_ notification: Notification) {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    // statusItem gets deallocated!
}

// Correct - retained as property
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }
}
```

---

### Info.plist Missing Keys

**Error:** Permission dialogs don't appear or app rejected

**Context:** Using protected resources without usage descriptions

**Solution:** Add all required keys:
```xml
<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>Whisper needs microphone access to record your voice for transcription.</string>

<!-- Accessibility -->
<key>NSAppleEventsUsageDescription</key>
<string>Whisper needs accessibility access to insert text at your cursor position.</string>
```

---

## Permissions

### Accessibility Permission Not Working

**Error:** AXUIElement operations fail silently

**Context:** App has Accessibility permission but operations fail

**Cause:** Permission granted to wrong binary (Debug vs Release) or not propagated

**Solution:**
1. Remove app from Accessibility list
2. Quit app completely
3. Re-add the correct binary
4. Restart app

```bash
# Check TCC database
sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db \
    "SELECT client FROM access WHERE service='kTCCServiceAccessibility'"
```

---

### Input Monitoring Not Detecting Keys

**Error:** Global hotkey not triggering

**Context:** Input Monitoring permission granted but hotkeys don't work

**Cause:** Need to use CGEventTap or proper hotkey library

**Solution:**
```swift
// Using HotKey library (recommended)
import HotKey

let hotKey = HotKey(key: .space, modifiers: [.option])
hotKey.keyDownHandler = { print("Key down") }
hotKey.keyUpHandler = { print("Key up") }
```

---

## Audio Recording

### AVAudioEngine Input Not Working

**Error:** No audio captured or error on start

**Context:** Using AVAudioEngine for microphone recording

**Cause:** Input node not properly configured

**Solution:**
```swift
let engine = AVAudioEngine()
let inputNode = engine.inputNode

// Must install tap BEFORE starting engine
let format = inputNode.outputFormat(forBus: 0)
inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
    // Process audio buffer
}

do {
    try engine.start()
} catch {
    print("Failed to start engine: \(error)")
}
```

---

### Audio Format Mismatch

**Error:** `The operation couldn't be completed. (OSStatus error -10868.)`

**Context:** Saving audio to file or converting format

**Cause:** Format incompatibility between engine format and file format

**Solution:**
```swift
// Use the actual hardware format
let hardwareFormat = inputNode.outputFormat(forBus: 0)

// Convert if needed for API compatibility
let targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                  sampleRate: 16000,
                                  channels: 1,
                                  interleaved: false)!

let converter = AVAudioConverter(from: hardwareFormat, to: targetFormat)
```

---

## Keychain

### Keychain Item Not Found

**Error:** `errSecItemNotFound` when retrieving

**Context:** Storing/retrieving API key from Keychain

**Cause:** Query attributes don't match stored item

**Solution:**
```swift
// Store
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "api-key",
    kSecAttrService as String: "com.yourcompany.appname",
    kSecValueData as String: apiKey.data(using: .utf8)!
]

// Retrieve - must match EXACTLY
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "api-key",
    kSecAttrService as String: "com.yourcompany.appname",
    kSecReturnData as String: true
]
```

---

## SwiftUI

### Menu Bar App with SwiftUI Window

**Error:** Window doesn't appear or app activates unexpectedly

**Context:** Menu bar app that opens SwiftUI preferences window

**Solution:**
```swift
// In App struct
@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView()
        }
    }
}

// Open settings programmatically
NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)

// Or for older macOS
if #available(macOS 13, *) {
    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
} else {
    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
}
```

---

### @AppStorage Not Updating UI

**Error:** SwiftUI view doesn't update when UserDefaults changes

**Context:** Using @AppStorage for preferences

**Cause:** Changes made outside SwiftUI don't trigger updates

**Solution:**
```swift
// Use ObservableObject instead
class Settings: ObservableObject {
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
    }

    init() {
        apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    }
}
```

---

## macOS Automator MCP

### Process Not Found

**Error:** `Can't get process "AppName"`

**Context:** Trying to automate app via System Events

**Cause:** Process name doesn't match app name or app not running

**Solution:**
```applescript
-- List all running processes to find correct name
tell application "System Events"
    set allProcesses to name of every process whose background only is false
end tell
return allProcesses
```

---

### Menu Bar Item Index Wrong

**Error:** Clicking wrong menu bar item

**Context:** Menu bar items indexed differently than expected

**Cause:** Menu bar 1 = Apple menu bar, Menu bar 2 = status items

**Solution:**
```applescript
-- Menu bar 2 is the status item bar (right side)
tell application "System Events"
    tell process "AppName"
        -- menu bar item 1 of menu bar 2 = your status item
        click menu bar item 1 of menu bar 2
    end tell
end tell
```

---

### Keystroke Not Registering

**Error:** Simulated keystrokes don't trigger app's hotkey

**Context:** Testing global hotkeys with System Events

**Cause:** App needs Input Monitoring, System Events needs Accessibility

**Solution:**
1. Grant Accessibility to "System Events" app
2. Grant Input Monitoring to your app
3. Use explicit key down/up:

```applescript
tell application "System Events"
    key down option
    key down shift
    keystroke "s"
    delay 0.5
    key up shift
    key up option
end tell
```

---

## Text Insertion

### AXUIElement Not Returning Focused Element

**Error:** `AXUIElementCopyAttributeValue` returns nil

**Context:** Getting focused element to insert text

**Cause:** No text field focused or app doesn't expose accessibility

**Solution:**
```swift
// Check if element supports value attribute
var role: CFTypeRef?
AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)

if let roleString = role as? String,
   roleString == kAXTextFieldRole || roleString == kAXTextAreaRole {
    // Can set value
}

// Fallback: use clipboard paste
let pasteboard = NSPasteboard.general
pasteboard.clearContents()
pasteboard.setString(text, forType: .string)

// Simulate Cmd+V
let source = CGEventSource(stateID: .hidSystemState)
let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
keyDown?.flags = .maskCommand
keyUp?.flags = .maskCommand
keyDown?.post(tap: .cghidEventTap)
keyUp?.post(tap: .cghidEventTap)
```

---

## Build Issues

### xcodebuild Fails with Signing Error

**Error:** `Code signing is required for product type 'Application'`

**Context:** Building via command line

**Solution:**
```bash
# For development/testing, use ad-hoc signing
xcodebuild -scheme AppName \
    -configuration Debug \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    build
```

---

### Module Not Found

**Error:** `No such module 'HotKey'`

**Context:** Using Swift Package Manager dependencies

**Solution:**
```bash
# Resolve packages first
xcodebuild -resolvePackageDependencies

# Then build
xcodebuild -scheme AppName -configuration Debug build
```
