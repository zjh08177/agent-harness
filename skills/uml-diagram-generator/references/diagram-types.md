# Supported Diagram Types

## Structural Diagrams

### 1. Component Diagram
**Mermaid syntax**: `flowchart TD`
**Best for**: System architecture overview, service boundaries

```mermaid
flowchart TD
    subgraph frontend["Frontend Layer"]
        webapp(["Web App"])
        mobile(["Mobile App"])
    end
    subgraph backend["Backend Layer"]
        api["API Gateway"]
        auth["Auth Service"]
        users["User Service"]
    end
    subgraph data["Data Layer"]
        db[(PostgreSQL)]
        cache[(Redis)]
    end

    webapp --> api
    mobile --> api
    api --> auth
    api --> users
    users --> db
    users --> cache
```

**When to use**:
- High-level system overview
- Microservice architecture
- Service dependencies and data flow

### 2. Class Diagram
**Mermaid syntax**: `classDiagram`
**Best for**: Object model, API surface, type relationships

```mermaid
classDiagram
    class User {
        +String name
        +String email
        +login()
        +logout()
    }
    class Order {
        +Number id
        +Date createdAt
        +calculate()
    }
    class Product {
        +String name
        +Number price
    }

    User "1" --> "*" Order : places
    Order "*" --> "*" Product : contains
```

**When to use**:
- Object model documentation
- API type definitions
- Interface/implementation relationships
- Data model visualization

### 3. Package Diagram
**Mermaid syntax**: `flowchart TD` with nested subgraphs
**Best for**: Module organization, dependency boundaries

```mermaid
flowchart TD
    subgraph app["Application"]
        subgraph ui["UI Module"]
            components["Components"]
            pages["Pages"]
        end
        subgraph core["Core Module"]
            services["Services"]
            models["Models"]
        end
    end
    subgraph infra["Infrastructure"]
        db["Database"]
        api["API Client"]
    end

    pages --> services
    services --> models
    services --> api
    models --> db
```

**When to use**:
- Module boundaries and dependencies
- Monorepo package organization
- Layer architecture visualization

### 4. Deployment Diagram
**Mermaid syntax**: `flowchart TD` with styled subgraphs
**Best for**: Infrastructure layout, deployment topology

```mermaid
flowchart TD
    subgraph cloud["Cloud Infrastructure"]
        subgraph k8s["Kubernetes Cluster"]
            pod1["API Pod x3"]
            pod2["Worker Pod x2"]
        end
        subgraph managed["Managed Services"]
            rds[(RDS PostgreSQL)]
            redis[(ElastiCache)]
            s3[(S3 Storage)]
        end
    end
    subgraph cdn["CDN"]
        cf["CloudFront"]
    end

    cf --> pod1
    pod1 --> rds
    pod1 --> redis
    pod2 --> s3
```

**When to use**:
- Cloud architecture
- Infrastructure documentation
- Scaling and redundancy visualization

---

## Behavioral Diagrams

### 5. Sequence Diagram
**Mermaid syntax**: `sequenceDiagram`
**Best for**: Request flows, API interactions, message passing

```mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant API
    participant DB

    User->>Frontend: Click Login
    Frontend->>API: POST /auth/login
    activate API
    API->>DB: SELECT user
    DB-->>API: User record
    API-->>Frontend: JWT token
    deactivate API
    Frontend-->>User: Show dashboard
```

**When to use**:
- API call flows
- Authentication/authorization flows
- Multi-service interactions
- WebSocket/SSE message flows

### 6. Activity Diagram
**Mermaid syntax**: `flowchart TD`
**Best for**: Business logic, workflow steps, decision trees

```mermaid
flowchart TD
    start([Start]) --> input[/Receive Order/]
    input --> validate{Valid?}
    validate -->|Yes| process[Process Payment]
    validate -->|No| reject[Reject Order]
    process --> payment{Payment OK?}
    payment -->|Yes| fulfill[Fulfill Order]
    payment -->|No| retry{Retry?}
    retry -->|Yes| process
    retry -->|No| cancel[Cancel Order]
    fulfill --> notify[Send Confirmation]
    notify --> done([End])
    reject --> done
    cancel --> done
```

**When to use**:
- Business process documentation
- Decision logic visualization
- Error handling flows
- User journey mapping

### 7. State Diagram
**Mermaid syntax**: `stateDiagram-v2`
**Best for**: Entity lifecycle, status transitions

```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Pending : Submit
    Pending --> Approved : Approve
    Pending --> Rejected : Reject
    Rejected --> Draft : Revise
    Approved --> Published : Publish
    Published --> Archived : Archive
    Archived --> [*]
```

**When to use**:
- Order/ticket lifecycle
- Document workflow states
- Connection/session states
- Feature flag states

---

## Selection Guide

| Scenario | Recommended Type |
|----------|-----------------|
| "How does our system look?" | Component |
| "What are the data types?" | Class |
| "How are modules organized?" | Package |
| "Where is it deployed?" | Deployment |
| "What happens when user clicks X?" | Sequence |
| "What's the business logic?" | Activity |
| "What states can an order be in?" | State |

## Quick Selection Shortcuts

- **[a] All structural**: Component + Class + Package + Deployment
- **[b] All behavioral**: Sequence + Activity + State
- **[c] All**: Generate everything
