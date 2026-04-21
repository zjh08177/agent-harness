# Architecture Diagram JSON Schema

## Full Schema Definition

```json
{
  "diagram": {
    "title": "string - Descriptive title for the architecture",
    "subtitle": "string (optional) - Additional context",
    "layers": [
      {
        "id": "string - Unique identifier (kebab-case)",
        "name": "string - Display name for the layer",
        "level": "number - Hierarchy level (1 = top)",
        "description": "string (optional) - Layer purpose",
        "components": [
          {
            "id": "string - Unique identifier",
            "name": "string - Display name",
            "type": "string - Component type (see types below)",
            "module": "string (optional) - Source code path",
            "provider": "string (optional) - Technology/vendor",
            "dependencies": ["string (optional) - IDs of dependent components"],
            "methods": ["string (optional) - Method signatures for class diagrams"],
            "properties": ["string (optional) - Property declarations for class diagrams"],
            "description": "string (optional) - Component purpose",
            "contains": [
              "/* Nested components - same structure, MAX 3-4 LEVELS */"
            ]
          }
        ]
      }
    ],
    "relationships": [
      {
        "from": "string - Source component ID",
        "to": "string - Target component ID",
        "type": "calls | uses | depends-on | integrates-with | supports | implements | extends",
        "label": "string (optional) - Edge label text"
      }
    ],
    "sequences": [
      {
        "id": "string - Sequence identifier",
        "title": "string - Sequence diagram title",
        "actors": ["string - Participant names in order"],
        "steps": [
          {
            "from": "string - Source actor",
            "to": "string - Target actor",
            "message": "string - Message/call description",
            "type": "sync | async | reply | note",
            "activate": "boolean (optional) - Activate target lifeline"
          }
        ]
      }
    ],
    "states": [
      {
        "id": "string - State machine identifier",
        "title": "string - State diagram title",
        "states": ["string - State names"],
        "transitions": [
          {
            "from": "string - Source state (use '[*]' for initial/final)",
            "to": "string - Target state (use '[*]' for initial/final)",
            "trigger": "string - Transition trigger/event"
          }
        ]
      }
    ]
  }
}
```

## Component Types

| Type | Description | Mermaid Shape |
|------|-------------|---------------|
| `frontend-app` | Web/mobile UI application | `([name])` stadium |
| `backend-api` | REST/GraphQL API service | `[name]` rectangle |
| `database` | Data storage | `[(name)]` cylinder |
| `cache` | Caching layer | `[(name)]` cylinder |
| `queue` | Message queue | `>name]` asymmetric |
| `gateway` | API gateway/proxy | `{name}` diamond |
| `service` | Microservice | `[name]` rectangle |
| `agent` | AI agent/worker | `[[name]]` subroutine |
| `tool` | External tool integration | `(name)` rounded |
| `storage` | File/object storage | `[(name)]` cylinder |
| `container` | Grouping container | subgraph |
| `external` | Third-party service | `((name))` circle |

## Relationship Types

| Type | Description | Mermaid Arrow |
|------|-------------|---------------|
| `calls` | Synchronous API call | `-->` solid arrow |
| `uses` | Utilization relationship | `-.->` dotted arrow |
| `depends-on` | Dependency relationship | `==>` thick arrow |
| `integrates-with` | Bidirectional integration | `<-->` double arrow |
| `supports` | Supporting relationship | `-.->` dotted arrow |
| `implements` | Interface implementation | `..>` (class diagram) |
| `extends` | Inheritance | `--|>` (class diagram) |

## Sequence Step Types

| Type | Description | Mermaid Arrow |
|------|-------------|---------------|
| `sync` | Synchronous call | `->>` solid arrowhead |
| `async` | Asynchronous call | `-->>` dashed arrowhead |
| `reply` | Return/response | `-->>` dashed arrowhead |
| `note` | Annotation | `Note over` / `Note right of` |

## Best Practices

### Layer Organization
1. **Top layer**: User-facing interfaces (UI, CLI, API)
2. **Middle layers**: Business logic, orchestration, services
3. **Bottom layer**: Infrastructure, tools, external services

### Naming Conventions
- Use Chinese for display names in CN diagrams
- Keep technical terms in English (Next.js, FastAPI, etc.)
- Use kebab-case for IDs

### Depth Guidelines
- **Level 1-2**: High-level architecture overview
- **Level 3-4**: Detailed component breakdown
- **Avoid**: More than 4 nesting levels

### Component Grouping
- Group related components in the same layer
- Use `contains` for sub-components within a module
- Limit to 5-8 components per layer for clarity
