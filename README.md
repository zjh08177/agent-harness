# Agent Harness: Hooks, Memory & Meta-Skills for Claude Code

> **The model is what thinks. The harness is what it thinks about.**

A production-tested harness system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that turns suggestions into laws, gives agents persistent memory, and encodes complete workflows as one-click skills.

## What's in the box

| Layer | What | Why |
|-------|------|-----|
| **Hooks** | 8 shell scripts + settings.json config | Turn CLAUDE.md rules into mechanically enforced constraints |
| **Memory** | Dual-system template (auto-memory + MCP Memory) | Agent remembers decisions, corrections, and patterns across sessions |
| **Meta-Skills** | 3 autonomous workflows + shared base + reviewer constitution | One-click research, debugging, and development with anti-sycophancy |
| **nano-image-gen** | Knowledge card illustration generator | Demo skill: eval-driven image generation loop via Gemini API |

## Quick Start

```bash
git clone https://github.com/zjh08177/agent-harness.git
cd agent-harness
bash install.sh
```

Then merge `hooks/settings.json.example` into your `~/.claude/settings.json` and restart Claude Code.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  Meta-Skills (auto-workflow, auto-explore, auto-debug)│
│  ┌──────────────────────────────────────────────────┐│
│  │  Memory System (auto-memory + MCP Memory)        ││
│  │  ┌──────────────────────────────────────────────┐││
│  │  │  Hooks (deliverable-gate, memory-chain, ...)│││
│  │  │  ┌──────────────────────────────────────────┐│││
│  │  │  │  CLAUDE.md (your project rules)          ││││
│  │  │  └──────────────────────────────────────────┘│││
│  │  └──────────────────────────────────────────────┘││
│  └──────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
Each layer solves what the inner layer cannot.
```

## Hooks: Turning Suggestions into Laws

The hook system has two key chains:

**Deliverable Gate** — Forces the agent to declare what it will produce before exploring:
```
UserPromptSubmit → deliverable-gate.sh
→ "Before exploring, declare your deliverable in one line."
```

**Memory Chain** — Forces the agent to store learnings after every commit:
```
git commit detected
→ memory-commit-flag.sh (creates flag)
→ memory-gate.sh (blocks agent until memory is stored)
→ memory-clear-flag.sh (clears flag after storage)
```

See [`hooks/README.md`](hooks/README.md) for details on all 8 hooks.

## Memory: What to Store, What Not to Store

**Store**: Decisions (and WHY), corrections, validated patterns, surprising findings.

**Don't store**: Session logs, git history (use `git log`), debugging recipes, file paths that change.

**Quality rule**: Before saving, ask — "Would a future session be measurably more efficient knowing this?" Store WHY, not WHAT.

See [`memory/README.md`](memory/README.md) for the dual-system design.

## Meta-Skills: Anti-Sycophancy by Design

LLMs have a structural sycophancy problem (Anthropic ICLR 2024). "Please be strict" doesn't work — Snorkel AI found self-review accuracy drops from 98% to 57%.

The solution is **Reviewer Constitution** — structural constraints injected into every review agent:
- Forced dissent (must find N issues before ACCEPT)
- Category diversity (issues must span ≥2 categories)
- Evidence required (location + failure scenario + fix)
- "Looks good" / "LGTM" banned

All three meta-skills share this constitution via `skills/shared/`.

| Skill | Solves | Key mechanism |
|-------|--------|---------------|
| `auto-explore` | "Agent searched once and stopped" | 5 phases, ≥3 rounds, cross-source verification |
| `auto-debug` | "Agent grabbed first hypothesis" | ≥3 competing hypotheses, falsification-first |
| `auto-workflow` | "Agent skipped thinking, went straight to coding" | 8 phases, Red Team gate before implementation |

## nano-image-gen: Demo Skill

Generates knowledge card illustrations (知识卡片) via Gemini API with an eval-driven feedback loop:

```
Generate → Read image → Score (8 dimensions, /40) → Diagnose → Fix prompt → Regenerate
```

Requires `GEMINI_API_KEY`. See [`skills/nano-image-gen/SKILL.md`](skills/nano-image-gen/SKILL.md).

## Maturity Ladder: Where Are You?

| Level | Name | Diagnostic Signal |
|-------|------|-------------------|
| L0→L1 | Instructions | You repeat the same setup every session |
| L1→L2 | Constraints | Rules exist but agent violates 30% of them |
| L2→L3 | Workflows | You keep giving the same instruction sequence |
| L3→L4 | Delegation | Context polluted by mixed tasks |
| L4→L5 | Governance | Platform-level agent infra |

You don't need L5 on day one. Find your level, go up one step.

## License

MIT
