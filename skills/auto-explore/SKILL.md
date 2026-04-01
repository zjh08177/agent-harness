---
name: auto-explore
description: Fully autonomous progressive research workflow with 5 phases — Scope, Investigate, Synthesize, Review, and Deliver. Runs at least R rounds of proactive, progressive research — each round deepens understanding, explores new angles, and challenges prior findings. Deploys parallel sub-agents for multi-source investigation. Outputs a structured research report with citations and confidence levels. This skill should be used when the user invokes "auto-explore", requests deep research, comprehensive analysis, technology comparison, or needs autonomous multi-round investigation on any topic.
---

# Auto Research

**CRITICAL: Research must be proactive and progressive. Each round must go deeper than the last. Do not stop at surface-level findings. Challenge your own conclusions.**

## Configuration

| Param | Alias | Default | Syntax | Effect |
|-------|-------|---------|--------|--------|
| `agents` | `a` | 4 | `auto-explore a=8` | Minimum sub-agents for parallel investigation |
| `rounds` | `r` | 3 | `auto-explore r=5` | Minimum progressive research rounds |

Both can be combined: `auto-explore a=6 r=4`

**Lightweight mode** (`auto-explore light`): For narrow, well-defined questions — skip TeamCreate, planning files, vault doc routing. Run investigation inline (lead does web searches directly). Skip Phase 4 review. Output a concise answer in conversation, not a vault doc.

## Prerequisites

Read these shared files at session start:
- `~/.claude/skills/shared/SKILL_BASE.md` — Team Setup, Branch Safety, Execution Rules, Planning Files, Self-Review, Team Cleanup, Fault Tolerance
- `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` — Review agent prompts AND convergence/round exit criteria

**Skills to use:**
- `deep-research` for multi-source web research with citation tracking
- `codebase-exploration` for code-level investigation
- `WebSearch` and `WebFetch` for external sources
- `github-explorer` or `github-kb` for open-source project analysis
- Lark docs MCP for internal documentation
- For any other work, proactively search for and use the best existing skill

### Doc Output Routing

Save the final research report to the **second-brain vault** following the Project Folder Convention in user-scope CLAUDE.md. Use `obsidian-cli` with `research-template`. Set `doc_type: research`, plus `phase` and `product` frontmatter fields.

## Phase 1 — Scope

Define what needs to be researched and why.

- Read the research question carefully. Identify the core question and sub-questions.
- **Dedup check (MANDATORY)**: Search MCP memory for prior research on this topic. Check second-brain vault `Resources/` for existing docs. If found, start from existing findings — identify gaps only. State what NEW ground this session covers.
- Identify what is already known (existing code, docs, prior decisions, MCP memory).
- Break the topic into research axes — e.g., technical feasibility, alternatives, trade-offs, prior art, community adoption.
- Define success criteria: what does a complete answer look like?

## Phase 2 — Investigate

Progressive, multi-round research. Each round must go deeper.

**Round structure (repeat at least R rounds):**

1. Deploy at least N sub-agents using **specialized agent types** matched to source type:

| Source Type | `subagent_type` | `model` | Investigation Focus |
|------------|----------------|---------|---------------------|
| Web search (docs, blogs, Stack Overflow) | `search-specialist` | `sonnet` | Advanced query formulation, multi-source cross-referencing, fact verification |
| Codebase exploration (grep, trace paths) | `feature-dev:code-explorer` | `sonnet` | Execution path tracing, architecture mapping, pattern identification |
| Open-source repos & tech evaluation | `technical-researcher` | `sonnet` | GitHub analysis, code quality assessment, community adoption, alternatives comparison |
| Internal docs (Lark, wikis) | general-purpose | `sonnet` | Lark MCP access, internal wiki search |

   Distribute agents across source types each round. At minimum, each round should have at least 2 different agent types.

2. Collect findings. Identify gaps, contradictions, and unverified claims.

3. **Progressive deepening** — each subsequent round MUST:
   - Follow up on gaps from the previous round
   - Challenge or verify claims from earlier rounds
   - Explore new angles not yet covered
   - Go one level deeper into the most promising leads
   - Cross-reference findings across sources

4. Do not repeat the same searches. Each round explores new ground.

**Scope guard**: If after 2 rounds no new findings emerge (same sources, same conclusions), escalate to Phase 3 early rather than padding rounds.

## Phase 3 — Synthesize

Consolidate findings into a coherent analysis.

- Organize findings by theme, not by source.
- Identify consensus vs. conflicting evidence.
- Rate confidence level for each finding (High / Medium / Low) with justification.
- Identify remaining unknowns and their impact.
- If the research supports a recommendation, state it clearly with trade-offs.

## Phase 4 — Review

Deploy at least N **specialized review agents** to review the synthesis:

| Agent Type | `subagent_type` | `model` | Review Focus |
|-----------|----------------|---------|--------------|
| Technical Researcher (⌊N/2⌋) | `technical-researcher` | `sonnet` | Depth & gaps — blind spots, missing perspectives, trade-off fairness |
| Report Generator (⌈N/2⌉, remainders here) | `report-generator` | `sonnet` | Synthesis quality — evidence chains, confidence calibration, coherence, actionability |

**Reviewer Constitution (MANDATORY):** Read `~/.claude/skills/shared/REVIEWER_CONSTITUTION.md` and include its full content in each reviewer's prompt. Pass only the synthesis document — not investigation reasoning. This is a design document, so reviewers SHOULD evaluate stated reasoning per Constitution.

Collect structured verdicts. Address feedback. Repeat per Constitution's convergence/round rules.

**Loop-back**: If reviewers identify missing research axes (not just synthesis quality issues), re-enter Phase 2 for 1 targeted round before re-synthesizing.

## Phase 5 — Deliver

Follow SKILL_BASE.md Self-Review and Promote Findings sections.

### Final Output

- Write a structured research report with: question, methodology, findings (by theme), confidence levels, recommendations, open questions.
- Include citations/sources for all key claims.
- Save to vault following Project Folder Convention (see Doc Output Routing above).
- Store key findings, decisions, and self-review answers via `mcp__memory__add_observations`.

When multiple research questions were given, output a summary table:

| Question | Finding | Confidence | Recommendation |
|----------|---------|------------|----------------|
| ... | ... | High/Med/Low | ... |

### Actionable Requirements (MANDATORY)

Every research report must end with:
- 3-5 concrete, implementable requirements extracted from findings
- Priority ranking (P0/P1/P2)
- File/function pointers for where implementation would happen
- Estimated complexity (S/M/L)

If the research doesn't yield actionable items, explicitly state why and what additional research is needed.

Follow SKILL_BASE.md Team Cleanup section.
