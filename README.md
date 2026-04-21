# Agent Harness

Locally-authored hooks, skills, memory conventions, and CLAUDE.md for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Canonical source-of-truth; deploys to `~/.claude/skills/` via symlinks.

## Layout

```
.agents/
├── .gitignore              # Excludes third-party skills (installed via skill-lock)
├── .skill-lock.json        # Third-party skill source tracking (NOT committed)
├── sync-skills.sh          # Symlink deployer — ~/.agents/skills/ → ~/.claude/skills/, etc.
├── install.sh              # Fresh-machine bootstrap
├── skills/                 # Locally-authored skills (auto-*, shared/, etc.)
│   ├── auto-workflow/      # Full dev cycle — 8 phases with meta-judge
│   ├── auto-explore/       # Progressive research — 5 phases
│   ├── auto-debug/         # Autonomous bug loop — 5 phases
│   ├── shared/             # Constitution, SKILL_BASE, META_JUDGE, CODEX_REVIEW
│   └── ... (88 locally-authored skills total)
├── hooks/                  # Claude Code hooks (symlinked to ~/.claude/hooks/)
└── settings/
    ├── CLAUDE.md           # User-global instructions (symlinked to ~/.claude/CLAUDE.md)
    └── settings.json.example  # Hook wiring + perms template
```

## What's tracked vs. ignored

- **Tracked**: locally-authored skills (auto-*, shared, obsidian-*, plan-*, etc.), all hooks, CLAUDE.md, settings template.
- **Ignored** via `.gitignore`: third-party skills installed via `npx skills add` (have their own `.git` inside). Re-installed via `install.sh` from `.skill-lock.json`.

## Fresh-machine bootstrap

```bash
git clone https://github.com/zjh08177/agent-harness ~/.agents
cd ~/.agents
./install.sh
```

`install.sh` does:
1. Re-install third-party skills from `.skill-lock.json` (if present)
2. Run `sync-skills.sh` to symlink `~/.agents/skills/*` → `~/.claude/skills/*`
3. Symlink `~/.agents/settings/CLAUDE.md` → `~/.claude/CLAUDE.md`
4. Symlink `~/.agents/hooks` → `~/.claude/hooks` (backs up existing)
5. Remind user to review `~/.claude/settings.json` against `settings/settings.json.example`

## Auto-commit on session end

`hooks/harness-auto-commit.sh` fires on Claude Code `Stop` event. Batches all edits to `skills/`, `hooks/`, `settings/` since session start into one commit, with a `chore(<scope>): ...` title derived from changed paths.

- **Commit only** (default): local commit; you push manually when ready.
- **Auto-push**: `export HARNESS_AUTO_PUSH=1` in your shell.
- **Emergency brake**: `export HARNESS_AUTO_COMMIT_OFF=1` disables the hook.

Wire in `~/.claude/settings.json`:
```json
"Stop": [{ "hooks": [{"type": "command", "command": "~/.claude/hooks/harness-auto-commit.sh"}] }]
```

`install.sh` adds this automatically on fresh machines.

## Key conventions

- **Meta-judge terminated review loops** — `skills/shared/META_JUDGE.md` defines 5 boolean terminator signals for multi-agent review cycles. Applied by `auto-workflow` / `auto-explore` / `auto-debug` at each round boundary.
- **Reviewer Constitution with Diversity mandate** — `skills/shared/REVIEWER_CONSTITUTION.md` enforces ≥2 distinct reviewer types per round (NeurIPS-2025 premature-convergence prevention).
- **Scope Lock with round reset** — `skills/shared/SKILL_BASE.md` requires in/out/owner declaration before Round 1; mid-cycle scope expansion triggers counter reset + `scope-delta-<topic>.md`.
- **Research Gate** — if any reviewer raises a scope-level question (not spec-gap), pause reviews and invoke `/auto-explore` before resuming.

See `skills/shared/*.md` for full specs.

## License

See `LICENSE` (copied from upstream snapshot — MIT).

## Provenance

Initially snapshotted as template. Now tracked in-place per `Areas/dev-workflow/003-claude-harness-repo-strategy.md` (personal vault). Built over 2+ months of daily use; shaped by retrospectives on multi-round review cycles (see 2026-04-20 control-flow project retro).
