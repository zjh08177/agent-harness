---
name: auto-explore
description: Fully autonomous progressive research workflow with 5 phases — Scope, Investigate, Synthesize, Review, Deliver. Meta-judge terminated rounds of proactive, progressive research — each round deepens understanding, explores new angles, challenges prior findings. Deploys parallel diverse sub-agents for multi-source investigation. Outputs structured research report with citations and confidence levels. This skill should be used when the user invokes "auto-explore", requests deep research, comprehensive analysis, technology comparison, or needs autonomous multi-round investigation on any topic.
---

# Auto Research

**Research is proactive and progressive. Each round goes deeper than the last. Challenge your own conclusions.**

## Configuration

| Param | Alias | Default | Syntax | Effect |
|---|---|---|---|---|
| `agents` | `a` | 4 | `auto-explore a=8` | Minimum sub-agents per round |
| `rounds` | `r` | 3 | `auto-explore r=5` | Minimum progressive rounds |
| `max_rounds` | `mr` | 3 | `auto-explore mr=5` | Hard cap |
| `codex` | `cx` | off | `auto-explore cx=on` | Replace Claude subagents (investigate + review) with parallel `codex exec` |

Combine: `auto-explore a=6 r=4 cx=on`

**Lightweight** (`light`): narrow well-defined question — skip TeamCreate, planning files, vault routing. Inline investigation (lead does web searches). Skip Phase 4 review. Concise in-conversation answer, not vault doc.

## Prerequisites

Read at session start:
- `~/.claude/skills/shared/SKILL_BASE.md` — Team Setup, Branch Safety, Autonomous Decisions, Scope Lock, Research Gate, Fault Tolerance, Self-Review, Team Cleanup
- `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` — Review prompts, Reviewer Diversity, Round-Phase Rules, convergence
- `~/.claude/skills/shared/META_JUDGE.md` — Round-boundary terminator
- `~/.claude/skills/shared/CODEX_REVIEW.md` — **read only if `cx=on`**

## Codex review mode (`codex=on`)

Every Claude subagent in Phase 2 (Investigate, each round) + Phase 4 (Synthesis review) replaced 1:1 by parallel `codex exec`. N, source-types, progressive-deepening, Constitution, rounds unchanged.

- Codex `--enable web_search_cached` covers `search-specialist` + `technical-researcher` natively
- Codebase agents: `-C "$_REPO_ROOT" -s read-only` for grep/read
- Internal-docs (Lark) not Codex-reachable — fallback to Claude `general-purpose` for that slot, tag `[codex-bypass: lark-mcp]`

Preflight from `CODEX_REVIEW.md` before any phase. Codex unavailable → degrade to `codex=off`, tell user.

Per affected phase:
1. Build `_CX_ROLE_NAMES` + `_CX_ROLE_PROMPTS` from phase's source-type table
2. Launch via parallel block in `CODEX_REVIEW.md`
3. Apply degradation matrix
4. Merge findings, apply convergence + progressive-deepening rules

Artifact handoff:
- Phase 2 (per round) — research question + axes + prior-round findings → temp file in repo
- Phase 4 (review) — synthesis doc copied into repo as temp file (vault paths outside `$_REPO_ROOT` not reachable under read-only)

**Skills:**
- `deep-research` for multi-source web research with citation tracking
- `codebase-exploration` for code-level investigation
- `WebSearch`, `WebFetch` for external sources
- `github-explorer` / `github-kb` for open-source analysis
- Lark docs MCP for internal docs
- Proactively search for best existing skill for other work

### Doc Output Routing

Save final report to **second-brain vault** per Project Folder Convention. `obsidian-cli` + `research-template`. Set `doc_type: research`, `phase`, `product`.

## Phase 1 — Scope

Define what to research and why.

- Read research question. Identify core + sub-questions.
- **Dedup check (MANDATORY)**: Search MCP memory + vault `Resources/` for prior research. If found, start from existing findings — gaps only. State NEW ground this session covers.
- Identify what's known (existing code, docs, prior decisions, MCP memory)
- Break into research axes — technical feasibility, alternatives, trade-offs, prior art, community adoption
- Define success criteria — what does a complete answer look like?
- **Declare scope** per `SKILL_BASE.md §Scope Lock` (in / out / owner). Lock before Phase 2.

## Phase 2 — Investigate

Progressive, multi-round. Each round goes deeper.

**Round structure (min R rounds, max `max_rounds`):**

1. Deploy ≥N sub-agents using specialized types by source:

| Source Type | `subagent_type` | `model` | Focus |
|---|---|---|---|
| Web search (docs, blogs, Stack Overflow) | `search-specialist` | `sonnet` | Query formulation, multi-source cross-ref, fact verification |
| Codebase (grep, trace paths) | `feature-dev:code-explorer` | `sonnet` | Execution path, architecture mapping, pattern ID |
| Open-source repos & tech eval | `technical-researcher` | `sonnet` | GitHub analysis, code quality, community adoption, alternatives |
| Internal docs (Lark, wikis) | `general-purpose` | `sonnet` | Lark MCP, internal wiki search |

Distribute across source types. **Diversity floor**: ≥2 different agent types per round (per Constitution §Reviewer Diversity).

2. Collect findings. Identify gaps, contradictions, unverified claims.

3. **Progressive deepening** — each subsequent round MUST:
   - Follow up on prior-round gaps
   - Challenge or verify prior claims
   - Explore new angles
   - Go deeper into promising leads
   - Cross-reference findings across sources

4. No repeated searches. Each round explores new ground.

5. **End-of-round meta-judge** (`META_JUDGE.md`): compute terminator signals. If any fires → early exit to Phase 3.

**Scope guard**: 2 rounds with no new findings (same sources, same conclusions) → escalate to Phase 3 early (rather than pad rounds).

## Phase 3 — Synthesize

Consolidate findings into coherent analysis.

- Organize by theme, not by source
- Identify consensus vs conflicting evidence
- Rate confidence (High / Medium / Low) with justification
- Identify remaining unknowns + impact
- State recommendation if research supports one — with trade-offs

## Phase 4 — Review

Deploy ≥N specialized review agents:

| Agent Type | `subagent_type` | `model` | Focus |
|---|---|---|---|
| Technical Researcher (⌊N/2⌋) | `technical-researcher` | `sonnet` | Depth & gaps — blind spots, missing perspectives, trade-off fairness |
| Report Generator (⌈N/2⌉, remainders) | `report-generator` | `sonnet` | Synthesis quality — evidence chains, confidence calibration, coherence, actionability |

Diversity floor applies.

**Reviewer Constitution (MANDATORY):** Include full content in each prompt. Pass synthesis ONLY — not investigation reasoning. Design doc → reviewers evaluate stated reasoning per Constitution.

Collect verdicts. Address feedback. End-of-round meta-judge. Repeat per Constitution rules.

**Loop-back**: Reviewers identify missing research axes (not just synthesis issues) → re-enter Phase 2 for 1 targeted round before re-synthesizing.

## Phase 5 — Deliver

Follow SKILL_BASE.md Self-Review + Promote Findings.

### Final Output

- Structured report: question, methodology, findings (by theme), confidence, recommendations, open questions
- Citations/sources for all key claims
- Save to vault per Project Folder Convention (see Doc Output Routing above)
- Store key findings + self-review answers via `mcp__memory__add_observations`

Multiple research questions → summary table:

| Question | Finding | Confidence | Recommendation |
|---|---|---|---|
| ... | ... | H/M/L | ... |

### Actionable Requirements (MANDATORY)

Every report ends with:
- 3-5 concrete implementable requirements from findings
- Priority (P0/P1/P2)
- File/function pointers for impl
- Complexity estimate (S/M/L)

Non-actionable research → explicitly state why + what additional research is needed.

Follow SKILL_BASE.md Team Cleanup.
