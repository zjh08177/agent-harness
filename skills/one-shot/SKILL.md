---
name: one-shot
description: Autonomous zero-to-one project delivery — takes a project idea and delivers a working codebase through 6 phases (Brainstorm, Decompose, Scaffold, Implement, Verify, Ship). Orchestrates existing skills (brainstorming, auto-workflow, auto-debug) with new capabilities (spec-driven decomposition, deterministic scaffolding, build-loop verification, wave-based parallel implementation). Designed around the 35-minute context degradation constraint — every agent task is session-segmented with fresh context. Human gates after decomposition and before ship are mandatory. This skill should be used when the user says "build X from scratch", "create a new project", "zero to one", "one shot", or wants to autonomously deliver a complex multi-module project.
---

# Project Zero-to-One

Build a complex project from scratch in one orchestrated pass.

## Design Principles

Three pillars from community research (MetaGPT, OpenHands, Cursor, aider, Kiro, Anthropic C compiler):

1. **Structured decomposition before code** — resolve all ambiguity at spec level before writing a single file
2. **Scoped context per agent** — never feed the entire project into one context window; fresh agent per task
3. **Execution-in-the-loop** — every implementation task runs build→lint→test→fix before marking done

Hard constraints this skill is designed around:
- **35-minute degradation**: Agent accuracy degrades after ~35 min. Budget 25 min per agent task (soft limit).
- **80/20 problem**: ~85% failure rate on ambiguous tasks without human input. Human gates are mandatory, not optional.
- **17x error amplification**: Poorly coordinated multi-agent systems amplify errors. File ownership + artifact-driven communication prevent this.

## Configuration

| Param | Alias | Default | Syntax | Effect |
|-------|-------|---------|--------|--------|
| `agents` | `a` | 3 | `one-shot a=5` | Max parallel agents per implementation wave |
| `rounds` | `r` | 2 | `one-shot r=3` | Review rounds per phase |
| `stack` | `s` | auto | `one-shot s=react-ts` | Tech stack preset (see Stack Presets) |
| `gate` | — | decompose,ship | `one-shot gate=all` | Which phases require human approval |
| `light` | — | off | `one-shot light` | Single-module projects: skip waves, inline reviews |

**Stack presets** (determines build-loop exit criteria and scaffold template):

| Preset | Build | Lint | Typecheck | Test |
|--------|-------|------|-----------|------|
| `react-ts` | `vite build` | `eslint .` | `tsc --noEmit` | `vitest run` |
| `next-ts` | `next build` | `eslint .` | `tsc --noEmit` | `vitest run` |
| `python-flask` | — | `ruff check .` | `mypy .` | `pytest` |
| `python-fastapi` | — | `ruff check .` | `mypy .` | `pytest` |
| `rust` | `cargo check` | `cargo clippy` | (included in check) | `cargo test` |
| `swift` | `xcodebuild` | `swiftlint` | (included in build) | `xcodebuild test` |
| `node-ts` | `tsc` | `eslint .` | `tsc --noEmit` | `vitest run` |
| `auto` | Detect from project files | — | — | — |

## Prerequisites

Read these shared files at session start:
- `~/.claude/skills/shared/SKILL_BASE.md` — Team Setup, Branch Safety, Execution Rules, Planning Files, Self-Review, Team Cleanup, Fault Tolerance
- `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` — Review agent prompts AND convergence/round exit criteria

**Skills invoked by this skill:**
- `brainstorming` — Phase 0 idea refinement
- `auto-workflow` — Phase 3 per-module implementation (reused, not duplicated)
- `auto-debug` — When build-loop iterations fail repeatedly
- `simplify` — Post-implementation cleanup
- For any other work, proactively search for and use the best existing skill

**Lightweight mode** (`one-shot light`): For single-module projects (≤10 files total). Skip TeamCreate, wave orchestration, and planning files. Run all phases inline. Phase 3 uses `auto-workflow light` directly. Still requires human gate after decompose.

---

## Phase 0 — Brainstorm

> Turn a vague idea into a validated design.

Invoke the `brainstorming` skill. It handles:
1. Project context exploration
2. Clarifying questions (one at a time)
3. 2-3 approaches with trade-offs
4. Design presentation + user approval
5. Spec written to `docs/superpowers/specs/`

**Brainstorming outputs** (the spec) become the input to Phase 1.

**Skip condition**: If the user provides a complete spec (requirements + architecture + task breakdown), skip to Phase 1 and validate the spec instead of writing one.

---

## Phase 1 — Decompose

> Break the spec into modules, waves, and tasks with explicit contracts.

### 1.1 — Generate the Spec Triad

From the brainstorming spec, produce three files checked into the repo at `.project/`:

```
.project/
├── requirements.md    # User stories + acceptance criteria (GIVEN/WHEN/THEN)
├── design.md          # Architecture, module graph, API contracts, data flow
└── tasks.md           # Implementation waves with file ownership + dependencies
```

**requirements.md structure:**
```markdown
# Requirements: {Project Name}

## User Stories
- US-1: As a [role], I want [action] so that [benefit]
  - AC-1.1: GIVEN [context] WHEN [action] THEN [result]
  - AC-1.2: ...

## Non-Functional Requirements
- NFR-1: Performance — [specific measurable target]
- NFR-2: Security — [specific constraint]

## Out of Scope
- [Explicitly excluded items to prevent scope creep]
```

**design.md structure:**
```markdown
# Design: {Project Name}

## Architecture Overview
[Mermaid diagram of module relationships]

## Module Decomposition
| Module | Purpose | Public API | Dependencies |
|--------|---------|-----------|-------------|
| core   | ...     | ...       | none        |
| api    | ...     | ...       | core        |
| ui     | ...     | ...       | api, core   |

## API Contracts
[Interface definitions between modules — the source of truth for cross-module communication]

## Data Model
[Entity definitions, relationships, persistence strategy]

## Tech Stack
[Explicit decisions — framework, language, build tool, test framework, design system]

## Error Handling Strategy
[How errors propagate across module boundaries]
```

**tasks.md structure:**
```markdown
# Tasks: {Project Name}

## Wave 0: Scaffold (sequential, automated)
- [ ] T-0.1: Project skeleton + build system + CI
- [ ] T-0.2: CLAUDE.md for new project
- [ ] T-0.3: Design system setup (if web)
- [ ] T-0.4: Auth + logging skeleton

## Wave 1: Core (sequential or parallel if independent)
- [ ] T-1.1: {module} — Files: [...] — Depends: none — Owner: agent-1
- [ ] T-1.2: {module} — Files: [...] — Depends: none — Owner: agent-2

## Wave 2: Features (parallel, file-isolated)
- [ ] T-2.1: {feature} — Files: [...] — Depends: T-1.1 — Owner: agent-1
- [ ] T-2.2: {feature} — Files: [...] — Depends: T-1.2 — Owner: agent-2

## Wave 3: Integration (sequential)
- [ ] T-3.1: Integration tests across modules
- [ ] T-3.2: E2E tests (Playwright if web)
- [ ] T-3.3: Security audit

## Exit Criteria
- [ ] All acceptance criteria from requirements.md pass
- [ ] Build + lint + typecheck + test all green
- [ ] No TODO/FIXME in production code
- [ ] CLAUDE.md accurately describes the project
```

**Task rules:**
- Each task lists its **file ownership** — which files it creates/modifies. No two tasks in the same wave share files.
- Each task lists its **dependencies** — which prior tasks must complete first.
- Each task is scoped to **<25 minutes** of agent work (the session budget).
- Waves are sequential; tasks within a wave are parallel.

### 1.2 — Red Team the Decomposition

Spawn 2 agents in parallel:

**Agent 1: Premise Validator** (`subagent_type: "general-purpose"`, `model: "sonnet"`)
Use `plan-ceo-review` methodology. Challenge:
- Are the module boundaries correct? Could a simpler decomposition work?
- Are the API contracts between modules complete? Any implicit assumptions?
- Is the wave ordering optimal? Could more tasks be parallelized?
- Does the tech stack match the requirements? Any over-engineering?

**Agent 2: Feasibility Checker** (`subagent_type: "technical-researcher"`, `model: "sonnet"`)
- Verify every external dependency exists and is maintained (check npm/PyPI/crates.io)
- Verify API/SDK capabilities claimed in design.md are real (not hallucinated)
- Check for known incompatibilities between chosen dependencies
- Estimate total LOC — flag if any single task exceeds complexity ceiling (~500 LOC)

Merge verdicts. Fix issues. Repeat per Constitution convergence rules.

### 1.3 — Human Gate (MANDATORY)

```
AskUserQuestion: "Spec triad written to .project/. Please review:
  - .project/requirements.md (user stories + acceptance criteria)
  - .project/design.md (architecture + module graph + API contracts)
  - .project/tasks.md (implementation waves + file ownership)
Approve to proceed to scaffolding, or request changes."
```

**Do NOT proceed without explicit approval.** This gate exists because the 80/20 problem makes autonomous architecture decisions unreliable on complex projects.

---

## Phase 2 — Scaffold

> Create the project skeleton deterministically.

### 2.1 — Project Skeleton

Based on `design.md` tech stack and module decomposition:

1. **Initialize project** — `npm init` / `cargo init` / etc. + package manifest with all dependencies from design.md
2. **Directory structure** — Create all directories from module decomposition. Empty placeholder files for each module's public API.
3. **Build system** — Configure build tool, scripts (`dev`, `build`, `test`, `lint`, `typecheck`), CI config
4. **CLAUDE.md** — Generate for the new project:
   - Architecture overview (from design.md)
   - Directory map
   - Build commands
   - Code conventions
   - Node type / module registration patterns
5. **Design system** (web projects) — `npx shadcn@latest init`, Tailwind config, CSS variables, base theme
6. **Auth + logging skeleton** — Stub implementations that can be filled in later
7. **Git init** — Initial commit with scaffold

**Key principle**: Scaffold deterministically where possible. Package manifests, configs, and directory structure should NOT be LLM-generated — use CLI tools and templates. LLM generates only application-logic stubs.

### 2.2 — Verify Scaffold

Run the full build-loop (see Phase 3.2) on the scaffold:
- Build passes
- Lint passes
- Typecheck passes
- Test runner finds 0 tests (not errors)

If any fail, fix before proceeding. This establishes the "green baseline" — every subsequent task must keep it green.

### 2.3 — Commit

```bash
git add -A && git commit -m "scaffold: project skeleton with build system, CLAUDE.md, and design system"
```

---

## Phase 3 — Implement

> Execute tasks wave-by-wave with build-loop verification per task.

### 3.1 — Wave Execution

For each wave in `tasks.md`:

1. **Read current state**: Load `.project/tasks.md`, identify next incomplete wave
2. **Spawn agents**: One agent per task in the wave (up to `agents` limit), each in `isolation: "worktree"`
3. **Each agent receives**:
   - The specific task description from tasks.md
   - The CLAUDE.md for the project
   - The relevant API contracts from design.md (only the interfaces this task depends on)
   - The file list it owns (enforce: agent cannot edit files outside this list)
   - The build-loop exit criteria for this stack
4. **Each agent executes**: implement → build-loop (see 3.2) → commit when green
5. **Lead merges**: Sequential merge of all wave branches into main, run full build-loop after merge
6. **Consistency check** (see 3.3): Validate cross-module contracts after merge
7. **Update tasks.md**: Mark completed tasks, commit the update
8. **Proceed to next wave**

**If a wave merge breaks the build**: The lead agent runs `auto-debug` to identify which merge introduced the failure, then spawns a fix agent for that specific module.

### 3.2 — Build-Loop (per task)

The inner verification loop that runs after every implementation task:

```
REPEAT (max 5 iterations):
  1. RUN build command    → if errors, feed to agent, CONTINUE
  2. RUN lint             → if errors, feed to agent, CONTINUE
  3. RUN typecheck        → if errors, feed to agent, CONTINUE
  4. RUN affected tests   → if failures, feed to agent, CONTINUE
  5. ALL GREEN            → BREAK (success)

IF 5 iterations exhausted:
  - Log failure details to .project/findings.md
  - Mark task as BLOCKED in tasks.md
  - Escalate: try auto-debug skill
  - If still failing: flag for human intervention via AskUserQuestion
```

**Exit criteria are stack-specific** — see the Configuration table. "Compiles" ≠ "correct." The loop must run tests, not just type-check.

**Affected test detection**: If the project has a dependency graph tool (e.g., `jest --findRelatedTests`, `pytest --co -q`), use it to run only tests affected by the changed files. Otherwise, run the full suite.

### 3.3 — Consistency Check (post-wave)

After merging a wave, run these deterministic checks:

1. **Import validation**: All imports resolve to existing files/modules
2. **Interface contract check**: grep for each function/type defined in design.md API contracts — verify they exist in code with matching signatures
3. **Naming convention scan**: Check for mixed naming styles (`camelCase` vs `snake_case` where project convention specifies one)
4. **Duplicate detection**: Search for near-identical functions/blocks across modules (>10 lines)
5. **Dead export scan**: Exports that nothing imports

These are grep/AST-based checks, not LLM calls — deterministic is more reliable than probabilistic for structural validation.

Flag issues as build-loop input for a fix agent. Do not block the wave for style issues — only for contract violations and broken imports.

### 3.4 — Visual Verify (web projects, post-wave)

If the project has a UI and the wave included UI changes:

1. Start the dev server (`npm run dev` or equivalent)
2. Spawn a **subagent** (not main agent — screenshots are 2-5K tokens each):
   - Navigate to key pages with Playwright
   - Take screenshots
   - Compare against design descriptions from design.md
   - Report: layout issues, missing components, broken styling, empty states
3. Feed visual issues back as build-loop input for a fix agent
4. Stop the dev server

**Subagent delegation is mandatory** — visual verification must not pollute the lead agent's context.

---

## Phase 4 — Integration Verify

> Full-project validation after all waves complete.

### 4.1 — Full Test Suite

Run the complete test suite (unit + integration). All must pass.

### 4.2 — E2E Tests (if applicable)

For web projects:
1. Write Playwright E2E tests covering each user story from requirements.md
2. Run them against the dev server
3. Fix failures via build-loop

For CLI tools:
1. Write shell-based integration tests
2. Test key workflows end-to-end

### 4.3 — Security Scan

Run available security tooling:
- `npm audit` / `pip audit` / `cargo audit` for dependency vulnerabilities
- If a SAST tool is configured, run it
- Manually review: auth flows, input validation, secret handling, CORS configuration

Flag findings in `.project/findings.md`. Critical vulns block ship.

### 4.4 — Acceptance Criteria Validation

Walk through every acceptance criterion in requirements.md. For each:
- Is there a test that validates it? (If not, write one)
- Does the test pass?
- Mark as PASS/FAIL in a verification report

### 4.5 — Code Review + Simplify

Invoke `auto-workflow` Phase 5 (Code Review + /simplify) on the full diff from scaffold to current HEAD. This reuses the existing review infrastructure.

---

## Phase 5 — Ship

> Final polish, documentation, and human sign-off.

### 5.1 — Documentation

1. Update CLAUDE.md to reflect final architecture (not the initial scaffold version)
2. Generate README.md with: project description, setup instructions, architecture overview, dev workflow
3. Clean up `.project/tasks.md` — all tasks should be marked complete
4. Promote valuable findings from `.project/findings.md` to permanent docs

### 5.2 — Self-Review

Per SKILL_BASE.md:
1. **Root approach**: Key architectural choice (one line)
2. **Surprise**: What was unexpected (one line)
3. **Retrospective**: What would you do differently (one line)

Store as MCP memory observations.

### 5.3 — Human Gate (MANDATORY)

```
AskUserQuestion: "Project implementation complete. Summary:
  - [N] modules across [M] waves
  - [X] tests passing, [Y] acceptance criteria verified
  - Findings: .project/findings.md
  - Open issues: [list any unresolved items]

Please review the codebase and let me know:
  1. Approve for commit/PR
  2. Request changes (specify what)
  3. Flag for deeper review (I'll run additional analysis)"
```

### 5.4 — Final Commit + Memory

After human approval:
1. Squash or organize commits as requested
2. Store project summary in MCP memory
3. Follow SKILL_BASE.md Team Cleanup section

---

## Session Continuity

This skill is designed for multi-session execution. A complex project may span 3-10 sessions.

**How continuity works:**
- `.project/requirements.md`, `design.md`, `tasks.md` are the persistent state — checked into git
- `tasks.md` tracks completion status — new sessions resume from the first incomplete wave
- `CLAUDE.md` contains architecture context — new sessions read this first
- MCP memory stores cross-session decisions and findings

**Resuming a session:**
1. Read `.project/tasks.md` — find first incomplete wave
2. Read `.project/design.md` — load API contracts for current wave
3. Read `CLAUDE.md` — load project conventions
4. Search MCP memory for prior decisions on this project
5. Continue from the incomplete wave

**Never rely on accumulated context** — always re-read spec files. This is the mitigation for the 35-minute degradation constraint.

---

## Relationship to Existing Skills

```
one-shot (this skill — orchestrator)
│
├── Phase 0: brainstorming (existing, invoked as-is)
│   └── Outputs: spec document
│
├── Phase 1: Decompose (NEW in this skill)
│   ├── plan-ceo-review (existing, used for red team)
│   └── Outputs: .project/ spec triad
│
├── Phase 2: Scaffold (NEW in this skill)
│   └── Outputs: working project skeleton
│
├── Phase 3: Implement (NEW orchestration, reuses auto-workflow per task)
│   ├── auto-workflow light (existing, per-task implementation)
│   ├── auto-debug (existing, for build-loop failures)
│   └── Outputs: implemented modules
│
├── Phase 4: Verify (NEW in this skill)
│   ├── auto-workflow Phase 5 (existing, code review + simplify)
│   └── Outputs: verified, reviewed code
│
└── Phase 5: Ship (enhanced conclusion)
    └── Outputs: documented, approved project
```

New code in this skill: Phase 1 (decompose), Phase 2 (scaffold), Phase 3 orchestration (wave execution + build-loop + consistency check + visual verify), Phase 4 (integration verify + acceptance criteria).

Reused: brainstorming, auto-workflow (review phases), auto-debug, plan-ceo-review, simplify.
