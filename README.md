# Agent Harness

Hooks, memory system, and meta-skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Built over 2+ months of daily use on real projects.

## What's in here

### Hooks (`hooks/`)

8 shell scripts that hook into Claude Code's lifecycle events. They turn CLAUDE.md suggestions into mechanically enforced rules.

**Deliverable Gate** (`deliverable-gate.sh`) — Runs on every `UserPromptSubmit`. Injects a one-line rule: "declare what you'll produce before you start exploring." Prevents the agent from wandering for 10 minutes without output.

**Memory Chain** — Four hooks that work together to force the agent to store learnings after every git commit:
- `memory-commit-flag.sh` (`PostToolUse[Bash]`) — Detects `git commit` in Bash output, writes a `/tmp` flag file
- `memory-gate.sh` (`UserPromptSubmit`) — Checks for the flag, blocks the agent with a `BLOCKED — MEMORY UPDATE REQUIRED` message until it saves a memory
- `memory-clear-flag.sh` (`PostToolUse[Write, mcp__memory]`) — Clears the flag once memory is stored
- `memory-update-check.sh` (`Stop`) — Final check before session ends

**Environment & Guards:**
- `env-bootstrap.sh` (`PreToolUse[Bash]`) — Ensures env vars (like API keys) are loaded before shell commands
- `doc-convention-guard.sh` (`UserPromptSubmit`) — Enforces file naming and placement conventions for documentation
- `agent-budget.sh` (`PostToolUse[Agent]`) — Tracks how many subagents have been spawned, warns when approaching budget

`hooks/settings.json.example` has the full lifecycle mapping — merge it into your `~/.claude/settings.json`.

### Memory System (`memory/`)

A dual-system design for persistent cross-session knowledge:

**Auto-memory files** (project-level, `~/.claude/projects/<project>/memory/`) — Always loaded into context. Typed with frontmatter:
- `user` — Who you are, how you work, what you know
- `feedback` — Corrections and confirmed approaches (rule + WHY + how to apply)
- `project` — Ongoing decisions, constraints, deadlines
- `reference` — Pointers to external systems (Linear boards, Grafana dashboards, etc.)

**MCP Memory** (`mcp__memory` tools) — Cross-project entity-observation graph. Only used for recalling patterns from *other* projects.

**Quality rules:** Store WHY, not WHAT. Don't store things you can derive from `git log` or `git blame`. Before saving, ask: "Would a future session be measurably more efficient knowing this?"

`MEMORY.md.template` is the index file. `examples/` has one sample of each type.

### Meta-Skills (`skills/`)

Three autonomous workflows that encode complete engineering processes as one-click skills. Each orchestrates multiple sub-agents with structured review loops.

**`auto-workflow`** — 8-phase autonomous development: Context Gathering → Red Team → Tech Solution → Implementation Plan → Implementation → Code Review → Testing → Conclusion. The Red Team phase is a hard gate — two agents validate your premises before any code is written. In practice this caught 3 out of 5 wrong directions in one sprint.

**`auto-explore`** — 5-phase progressive research: Scope → Investigate → Synthesize → Review → Deliver. Runs at least 3 rounds, each deeper than the last. Deploys parallel sub-agents (web search, code exploration, technical research) and cross-verifies across sources. Stops only after 2 consecutive rounds with no new findings.

**`auto-debug`** — 5-phase hypothesis-driven debugging: Reproduce → Diagnose → Fix → Verify → Conclude. Generates ≥3 competing hypotheses and tries to *falsify* each one — the first explanation that fits symptoms is rarely the root cause. API-related bugs require real call verification, not assumptions.

**Shared infrastructure** (`skills/shared/`):
- `SKILL_BASE.md` — Common skeleton all three skills extend (DRY). Defines lightweight mode, vault integration, planning file management.
- `REVIEWER_CONSTITUTION.md` — Anti-sycophancy constraints injected into every review agent: forced dissent (must find N issues before ACCEPT), category diversity (≥2 categories), evidence requirements (location + failure scenario + fix), "LGTM" banned. Reviewers return structured verdicts (ACCEPT/REJECT + confidence + blocking issues).

> **Note:** The meta-skills orchestrate sub-agents from other Claude Code skill repos — `feature-dev` (code-explorer, code-architect, code-reviewer), `pr-review-toolkit` (pr-test-analyzer), `code-simplifier`, `superpowers` (planning, systematic debugging), and `planning-with-files`. Install these separately if you want the full orchestration; the skills degrade gracefully without them.

### nano-image-gen (`skills/nano-image-gen/`)

Demo skill: generates knowledge card illustrations (知识卡片) via Google Gemini API with an eval-driven feedback loop.

The loop: generate image → multimodal read → score on 8 dimensions (/40, pass ≥32) → diagnose failures via lookup table → fix prompt → regenerate. Human defines the scoring rubric and failure→fix mappings; agent executes the loop autonomously.

Includes:
- `SKILL.md` — Full workflow description with 6 proven visual patterns (labeled metaphor, split comparison, 2×2 grid, building cross-section, ascending staircase, horizontal triptych)
- `scripts/generate.sh` — Gemini API caller with embedded style anchor (Ligne Claire flat editorial)
- `references/eval-criteria.md` — 8-dimension evaluation rubric

Requires `GEMINI_API_KEY` env var.

### CLAUDE.md Template

`CLAUDE.md.template` — Sanitized starter for your own `~/.claude/CLAUDE.md`. Sections: project info, directory structure, quick commands, MUST/NEVER rules, code conventions, common mistakes, memory protocol. Keep it under 200 lines — agent compliance drops after that.

## Install

```bash
git clone https://github.com/zjh08177/agent-harness.git
cd agent-harness
bash install.sh
```

Then merge `hooks/settings.json.example` into `~/.claude/settings.json` and restart Claude Code.

## License

MIT
