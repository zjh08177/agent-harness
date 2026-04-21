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
        "type": "calls | uses | depends-on | integrates-with | supports"
      }
    ]
  }
}
```

## Component Types

| Type | Description | Example |
|------|-------------|---------|
| `frontend-app` | Web/mobile UI application | Next.js app, React Native |
| `backend-api` | REST/GraphQL API service | FastAPI, Express |
| `database` | Data storage | PostgreSQL, MongoDB |
| `cache` | Caching layer | Redis, Memcached |
| `queue` | Message queue | Kafka, RabbitMQ |
| `gateway` | API gateway/proxy | Kong, Nginx |
| `service` | Microservice | User service, Auth service |
| `agent` | AI agent/worker | Research agent, Coordinator |
| `tool` | External tool integration | Search tool, Code executor |
| `storage` | File/object storage | S3, GCS |
| `cdn` | Content delivery | CloudFront, Akamai |
| `container` | Grouping container | Layer, Module group |
| `external` | Third-party service | Stripe, Twilio |

## Relationship Types

| Type | Description | Visual |
|------|-------------|--------|
| `calls` | Synchronous API call | Solid arrow |
| `uses` | Utilization relationship | Thin arrow |
| `depends-on` | Dependency relationship | Dashed arrow |
| `integrates-with` | Bidirectional integration | Double arrow |
| `supports` | Supporting relationship | Dotted arrow |

## Example: Multi-Agent System

```json
{
  "diagram": {
    "title": "DeerFlow Multi-Agent Research System",
    "layers": [
      {
        "id": "interface-layer",
        "name": "访问层",
        "level": 1,
        "components": [
          {
            "id": "web-ui",
            "name": "Web UI",
            "type": "frontend-app",
            "module": "web/",
            "provider": "Next.js"
          },
          {
            "id": "cli",
            "name": "CLI Tool",
            "type": "frontend-app",
            "module": "cli/"
          }
        ]
      },
      {
        "id": "orchestration-layer",
        "name": "编排层",
        "level": 2,
        "components": [
          {
            "id": "coordinator",
            "name": "协调器",
            "type": "agent",
            "module": "src/graph/",
            "dependencies": ["research-agent", "writer-agent"]
          }
        ]
      },
      {
        "id": "agent-layer",
        "name": "Agent 层",
        "level": 3,
        "components": [
          {
            "id": "research-agent",
            "name": "研究员",
            "type": "agent",
            "dependencies": ["search-tool", "crawl-tool"]
          },
          {
            "id": "writer-agent",
            "name": "写作者",
            "type": "agent",
            "dependencies": ["llm-gateway"]
          }
        ]
      },
      {
        "id": "tool-layer",
        "name": "工具层",
        "level": 4,
        "components": [
          {
            "id": "search-tool",
            "name": "搜索工具",
            "type": "tool",
            "provider": "Tavily"
          },
          {
            "id": "crawl-tool",
            "name": "爬虫工具",
            "type": "tool",
            "provider": "Jina"
          },
          {
            "id": "llm-gateway",
            "name": "LLM 网关",
            "type": "gateway",
            "provider": "OpenAI/Claude"
          }
        ]
      }
    ]
  }
}
```

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
