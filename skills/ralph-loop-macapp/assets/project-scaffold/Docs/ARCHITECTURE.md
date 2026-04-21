# Architecture: [App Name]

> Technical design for [App Name]

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        [App Name]                            │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ AppDelegate │  │  MenuBar    │  │  PreferencesWindow  │  │
│  │             │──│  Manager    │  │  (SwiftUI)          │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│         │                                                    │
│         ▼                                                    │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    Core Services                        ││
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌─────────┐ ││
│  │  │ Service1  │ │ Service2  │ │ Service3  │ │Service4 │ ││
│  │  └───────────┘ └───────────┘ └───────────┘ └─────────┘ ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
AppName/
├── AppName.xcodeproj
├── AppName/
│   ├── App/
│   │   ├── AppNameApp.swift      # @main entry point
│   │   ├── AppDelegate.swift     # NSApplicationDelegate
│   │   └── AppState.swift        # Global observable state
│   ├── Services/
│   │   ├── [Service1].swift
│   │   ├── [Service2].swift
│   │   └── [Service3].swift
│   ├── Views/
│   │   ├── MenuBarView.swift
│   │   └── PreferencesView.swift
│   ├── Utilities/
│   │   ├── KeychainManager.swift
│   │   └── PermissionManager.swift
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Info.plist
│       └── AppName.entitlements
└── Package.swift (if using SPM)
```

## Components

### App Layer

#### AppNameApp.swift
- SwiftUI @main entry point
- Configures app as LSUIElement (no dock icon)
- Sets up Settings scene for preferences

#### AppDelegate.swift
- Creates and manages NSStatusItem
- Handles app lifecycle events
- Coordinates between services

#### AppState.swift
- Observable object for app-wide state
- Published properties for UI binding
- State machine for app status

### Services Layer

#### [Service1].swift
- [Purpose]
- [Key methods]
- [Dependencies]

#### [Service2].swift
- [Purpose]
- [Key methods]
- [Dependencies]

### Views Layer

#### MenuBarView.swift
- NSMenu construction
- Status display
- Action handlers

#### PreferencesView.swift
- SwiftUI Settings view
- API key input
- Configuration options

### Utilities Layer

#### KeychainManager.swift
- Secure credential storage
- CRUD operations for secrets

#### PermissionManager.swift
- Permission status checking
- Permission request helpers

---

## Data Flow

```
[Trigger] → [Service] → [Processing] → [Output]
    │           │            │            │
    ▼           ▼            ▼            ▼
[Input]    [Business]   [Transform]   [Result]
           [Logic]
```

---

## State Machine

```
         ┌──────────┐
         │   Idle   │◄──────────────────────┐
         └────┬─────┘                       │
              │ [trigger]                   │
              ▼                             │
         ┌──────────┐                       │
         │ Active   │                       │
         └────┬─────┘                       │
              │ [complete]                  │
              ▼                             │
         ┌──────────┐                       │
         │Processing│───────────────────────┘
         └──────────┘        [done]
```

---

## Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| [Package] | X.Y.Z | [Purpose] |

---

## Info.plist Keys

```xml
<!-- Menu bar app (no dock icon) -->
<key>LSUIElement</key>
<true/>

<!-- Usage descriptions -->
<key>NS[Permission]UsageDescription</key>
<string>[Explanation]</string>
```

---

## Entitlements

```xml
<key>com.apple.security.[capability]</key>
<true/>
```

---

## Testing Strategy

### Unit Tests
- Service logic
- State transitions
- Data transformations

### UI Automation Tests
- macOS Automator MCP
- AppleScript/JXA verification
- See TEST_INSTRUCTIONS.md

---

## Security Considerations

- API keys stored in Keychain
- No logging of sensitive data
- Minimal permission requests

---

## Performance Targets

| Metric | Target |
|--------|--------|
| RAM (idle) | < 50 MB |
| CPU (idle) | < 1% |
| [Action] latency | < X seconds |
