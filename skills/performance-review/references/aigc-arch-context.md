# AIGC Architecture Context

This reference provides domain context for the AIGC Arch work area in TikTok Studio.

## What is AIGC Arch?

DAG-based async task orchestration engine for AI-generated content workflows in TikTok Studio. Manages multi-stage pipelines with persistence, retry, and progress tracking.

**Typical Pipeline:**
```
Quota Check → Upload → Server Request → Progress Polling → Download
```

**Powers Features:**
- Effect AIGC (i2v, i2i, fl2v)
- AI Theater
- AI Self
- Album AI
- Video Enhancement
- Cloud Editing

## Key Technical Components

### Core Engine (AirFlowX)
- `TaskScheduler`: Manages DAG execution, topological ordering
- `AFXTask<I,O>`: Generic task with typed input/output
- Status state machine: waiting → ready → executing → suspend/finish

### Service Layer
- `AIGCWorkflowService`: Singleton for workflow CRUD, lifecycle management
- `AIGCWorkflowConfig`: Configuration model (inputFilePaths, businessScene, serverRequest)

### Task Implementations
| Task | Purpose |
|------|---------|
| `QuotaTask` | Check user quota before generation |
| `ImageUploadTask` | Upload images via BDImageXUploader |
| `ServerTask` | Submit generation request, get serverTaskID |
| `ProgressTask` | Poll server for job status/progress |
| `DownloadTask` | Download result files to sandbox |

### Persistence System
- Auto-save on lifecycle events
- Type resolution for Swift class reconstruction
- Resume with retry support for failed tasks

### Factory + Registry Pattern
- `AIGCWorkflowTaskFactory`: Creates tasks from type strings
- `TaskFactoryRegistry`: Caches factory instances for reuse
- Enables custom task integration (e.g., AI Theater)

## Common Vocabulary

| Term | Meaning |
|------|---------|
| Workflow | A complete DAG of tasks from start to finish |
| Task | Single unit of work (quota, upload, server, progress, download) |
| Scheduler | Manages task execution order and lifecycle |
| GlobalData | Shared context dictionary injected into all tasks |
| serverTaskID | Server-side job identifier for polling |
| Persistence | Auto-save/restore of workflow state |
| i2v | Image-to-video generation |
| i2i | Image-to-image generation |
| fl2v | First-last-frame video generation |
| IH | In-house (effects created by TikTok) |
| EH | Effect House (community creator effects) |
| TTEH | TikTok Effect House |
| AME | Advanced Media Effects team |
| Tiger team | Cross-functional task force for strategic initiatives |

## Technical Challenges Solved

1. **Persistence Type Resolution**: NSStringFromClass/NSClassFromString issues with pure Swift classes
2. **GlobalData Thread Safety**: TOCTOU race conditions in concurrent access
3. **Resume Logic**: Status migration for interrupted workflows
4. **Custom Factory Injection**: Enable business-specific task implementations without core changes

## Metrics/Impact Areas

When writing performance reviews, consider impact on:
- **Reliability**: Workflow completion rate, retry success
- **Performance**: Startup time, memory usage, polling efficiency
- **Developer Experience**: Integration effort (8 days → 2 days), documentation, abstraction quality
- **Scalability**: Support for new business lines (AI Theater, Social Avatar, etc.)
- **Business Metrics**: Publish rate, submission penetration, conversion rates
