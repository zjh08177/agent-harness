
# Must Follow

## Engineering Principles

1. **KISS** — Straightforward, minimal solutions. No over-engineering.
2. **DRY** — Consolidate logic. Reuse responsibly.
3. **YAGNI** — Don't build it until it's required.
4. **SOLID** — Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion.
5. **AB-Gated** — Gate new behavior behind TTKABTest. Flag off = fully disabled. Don't modify control group code.

## Collaboration Directives

1. **Clarify first** — Don't code until requirements clear. Ask.
2. **Propose then simplify** — Present approach; challenge yourself for the cleanest form.
3. **Align on scope** — Confirm deliverables. No assumptions or feature creep.
4. **Tests alongside code** — Always. Fix failures immediately.
5. **Minimal changes** — Small, isolated, easy to review.
6. **Defer until approved** — Wait for explicit "go" before coding.
7. **Exit criteria** (multi-task) — Flat `## Exit Criteria` checklist in impl plans, derived from spec.
8. **Decide autonomously; present decisions, not menus.** When the work has a defensible single answer, make it and state rationale in one line. Menus only when genuinely 50/50 OR when info is outside your reach. Default = autonomy — user can redirect faster than they can pick.

---

## Document Generation Rules

**Vault**: `/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain/`

### PARA Placement

| Folder | Purpose |
|--------|---------|
| `Projects/` | Active projects with deadline/goal |
| `Areas/` | Ongoing responsibilities (no end date) |
| `Resources/` | Reference material, learning |
| `Archives/` | Inactive items |
| `Self/` | Journal, reflections (`YYYY-MM-DD-topic.md`) |

**Areas/Resources/Archives**: `ls` → match deepest existing sub-folder → create if no match. Never loose files in root.

### Project Folder Convention

Structure: `direction/ → product/ → project/ (flat, prefix-organized)`

```
<direction>/
├── _index.md                          # Dataview MOC
├── <product>/
│   ├── _index.md                      # Dataview MOC
│   ├── <project>/                     # Flat, prefix-sorted
│   │   ├── erd-<topic>.md             # Problem definition & data model
│   │   ├── tech-solution-<topic>.md   # Design & architecture
│   │   ├── impl-plan-<topic>.md       # Implementation steps
│   │   ├── research-<topic>.md        # Investigation & analysis
│   │   ├── finding-NNN-<title>.md     # Numbered discoveries / bugs
│   │   ├── retro-<topic>.md           # Retrospective
│   │   ├── log-YYYY-MM-DD-<topic>.md  # Session continuity
│   │   ├── task-plan.md               # Working memory (delete after)
│   │   ├── findings.md                # Working memory (delete after)
│   │   └── progress.md               # Working memory (delete after)
│   └── research/<topic>/              # Cross-project research
└── research/                          # Cross-product research
```

**Mandatory trio**: `erd-` → `tech-solution-` → `impl-plan-`

**Working files** (`task-plan.md`, `findings.md`, `progress.md`) managed by `planning-with-files` skill. Delete when project completes; promote valuable content to permanent prefixed files first.

**Rules**: Max 4 levels deep. Kebab-case. `_index.md` at direction/product level. Create folders only when you have content.

**Route by work stream, not doc type.** Co-locate all docs from the same task. `research/` is for cross-project content only.

### Vault Doc Creation

Templates are SSOT for frontmatter — `99-System/Templates/`: `note-template`, `project-template`, `research-template`, `daily-template`, `weekly-template`, `index-template`, `decision-template`.

- **Content → `Write` tool.** Read the template file, substitute `{{title}}` / `{{date}}` / `{{week_number}}`, write the full doc. Read back to verify (size/tail).
- **Metadata → `obsidian-cli`.** `fm` for frontmatter edits, `move` to rename (preserves wikilinks), `open` to view.
- **⛔ Never `obsidian-cli create --content`.** It silently truncates at `&`, `#`, `?`, `%`, `=`, `+` (unescaped `obsidian://` URI embedding). Exit 0, no warning. Reproduced 2026-04-14. A PreToolUse hook blocks this pattern.

```bash
VAULT="/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain"
# Frontmatter edit
obsidian-cli fm "<path>" --edit --key last_updated --value "$(date +%Y-%m-%d)" --vault second-brain
# Rename (auto-updates wikilinks)
obsidian-cli move "<src>" "<dst>" --vault second-brain
```

Use `obsidian:obsidian-markdown` skill for vault-specific formatting (wikilinks, callouts, embeds).

### General Doc Rules
- Default to PARA. Project CLAUDE.md can override output location.
- Never create docs in project root unless instructed.
- Kebab-case filenames. Journal: `YYYY-MM-DD-topic.md`.
- **Superpowers spec override**: Design specs (`YYYY-MM-DD-<topic>-design.md`) → vault under relevant PARA folder (co-located with work stream), NOT `docs/superpowers/specs/`.
- **Layer-split at r0**: Tech-solutions touching ≥3 execution layers (e.g. schema + runtime + editor + Go + migrations) OR drafts >1000 lines MUST split into `tech-solution-l1-<topic>.md` / L2 / Ln upfront, not mid-cycle. Each layer gets its own round counter + `exit_criteria:` frontmatter. Monolithic drafts past ~1500 lines → cross-doc drift near-certain. Empirical: control-flow project 2026-04-20 (1,716-line monolith, split at r7, cost 3 drift-remediation rounds).

---

## Memory Protocol

Two memory systems with distinct roles:

| System | Role | When |
|--------|------|------|
| **Auto-memory files** (`~/.claude/projects/.../memory/`) | Per-project SSOT. Typed (user/feedback/project/reference). Always loaded. | Every session — all learnings, decisions, feedback |
| **MCP Memory** (`mcp__memory` tools) | Cross-project search. Entity-observation graph. | When recalling patterns/decisions from OTHER projects |

### Session Lifecycle
- **Start**: Auto-memory MEMORY.md loads automatically. Optionally `mcp__memory__search_nodes` for cross-project context.
- **After commit/finding/decision**: Write auto-memory file with insight. Tag: `Decision:` / `Finding:` / `Learning:`.
- **End**: Verify memory reflects learnings. MCP update optional for cross-project findings.

### Memory Quality Rules

Before saving ANY memory, ask: **"Would a future session be measurably more efficient knowing this?"** If no, don't save.

- **DO save**: Non-obvious decisions with WHY, validated patterns, user corrections, surprising findings, trial-and-error constraints.
- **DO NOT save**: Session logs, info derivable from `git log`/`git blame`, stale dynamic state (branches, commit hashes), debugging recipes, paths that may change.
- **Quality bar**: Explain WHY, not WHAT. Low: "we use sonnet for reviewers." High: "sonnet because haiku skips steps 7-8 in long prompts (adversarial testing)."

---

## gstack

Use `/browse` for web browsing. Never use `mcp__claude-in-chrome__*`.

Available: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review, /design-consultation, /review, /ship, /land-and-deploy, /canary, /benchmark, /browse, /qa, /qa-only, /design-review, /setup-browser-cookies, /setup-deploy, /retro, /investigate, /document-release, /codex, /cso, /autoplan, /careful, /freeze, /guard, /unfreeze, /gstack-upgrade.

---

## Inner Work Context

**Triggers**: emotions, shame, jealousy, anger, anxiety, self-worth, performance review pain, comparison, being marginalized, 被降格, 升级冲动, 尊严, career frustration, relationship dynamics, 修行, meditation, self-awareness, personality analysis, `/obsidian-daily`, `/obsidian-weekly` with emotional content.

**Action**: Read `~/.claude/inner-work-context.md` for instructions, then load `Self/Eric｜完整心智分析档案.md` from vault (`/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain/Self/Eric｜完整心智分析档案.md`). For historical pattern evidence, use the `chatgpt-archive` MCP server to search 3+ years of emotional/relational conversation history.

**Key rule**: Use Eric's specific patterns (7 drama engines, 刹车 protocol), not generic CBT. Match his depth — precision over comfort.

---

## Context Management

| Command | When |
|---------|------|
| `/clear` | Between unrelated tasks |
| `/compact` | Approaching token limit |
| `@file.md` | Reference without loading |
