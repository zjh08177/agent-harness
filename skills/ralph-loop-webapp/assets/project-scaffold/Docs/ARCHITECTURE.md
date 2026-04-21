# Architecture

> Version: 1.0 | Updated: YYYY-MM-DD

## Tech Stack

- **Framework**: [React / Vue / etc.]
- **Language**: [TypeScript / JavaScript]
- **Build**: [Vite / Webpack / etc.]
- **Styling**: [CSS / Tailwind / etc.]
- **Libraries**: [Key dependencies]

## Component Structure

```
src/
├── App.tsx              # Main app component
├── App.css              # Global styles
├── types.ts             # Type definitions
└── components/
    ├── Component1.tsx   # [Description]
    └── Component2.tsx   # [Description]
```

## Component Details

### App
**Purpose**: Main application container
**State**:
- `state1`: [Description]
- `state2`: [Description]

**Handlers**:
- `handleAction1()`: [Description]
- `handleAction2()`: [Description]

### Component1
**Purpose**: [Description]
**Props**:
- `prop1`: [Type] - [Description]
- `prop2`: [Type] - [Description]

## Data Flow

```
User Action → Handler → State Update → Re-render
```

[Describe how data flows through the application]

## Key Decisions

1. **[Decision]**: [Rationale]
2. **[Decision]**: [Rationale]

## Testing Strategy

- Unit tests: [Approach]
- E2E tests: Playwright MCP verification
- Test fixtures: `test-fixtures/` directory
