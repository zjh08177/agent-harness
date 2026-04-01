# Hooks

8 shell scripts that enforce behaviors Claude Code's CLAUDE.md can only suggest.

## Lifecycle Mapping

| Event | Hook | What it does |
|-------|------|-------------|
| `UserPromptSubmit` | `deliverable-gate.sh` | Forces agent to declare deliverable before exploring |
| `UserPromptSubmit` | `memory-gate.sh` | Blocks agent if post-commit memory update is pending |
| `UserPromptSubmit` | `doc-convention-guard.sh` | Enforces documentation naming/placement conventions |
| `PreToolUse[Bash]` | `env-bootstrap.sh` | Ensures environment variables are loaded |
| `PostToolUse[Bash]` | `memory-commit-flag.sh` | Detects git commits, creates memory-update flag |
| `PostToolUse[Write,mcp__memory]` | `memory-clear-flag.sh` | Clears flag after memory is stored |
| `PostToolUse[Agent]` | `agent-budget.sh` | Tracks subagent spawning budget |
| `Stop` | `memory-update-check.sh` | Final check before session ends |

## The Memory Chain

The four memory hooks form a chain that makes "learn from experience" mechanical:

```
Agent commits code
  → memory-commit-flag.sh detects git commit, creates /tmp flag
  → Next prompt triggers memory-gate.sh, finds flag, injects:
    ╔══════════════════════════════════════════╗
    ║  BLOCKED — MEMORY UPDATE REQUIRED       ║
    ╚══════════════════════════════════════════╝
  → Agent is forced to store a learning
  → memory-clear-flag.sh clears flag, agent resumes
```

## Installation

1. Copy all `.sh` files to `~/.claude/hooks/`
2. Make executable: `chmod +x ~/.claude/hooks/*.sh`
3. Merge `settings.json.example` hooks section into your `~/.claude/settings.json`

## Design Principle

Hook error messages tell the agent **what's wrong AND how to fix it** — closing the feedback loop in a single message.
