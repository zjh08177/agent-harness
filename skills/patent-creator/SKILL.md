---
name: patent-creator
description: This skill should be used when preparing patent application documentation for the "Universal AIGC Workflow Protocol and Cross-Platform Workflow Engine" invention. Guides through prior art search, invention disclosure drafting, and USPTO-compliant documentation preparation.
---

# Patent Creator: Universal AIGC Workflow Protocol

## Purpose

To prepare complete patent application documentation for the invention:
**"Universal AIGC Workflow Protocol and its Cross-Platform Workflow Engine"**

## Triggers

Activate this skill when:
- Drafting patent disclosure documents for the AIGC workflow invention
- Conducting prior art search for workflow/AIGC technologies
- Preparing claims for the workflow protocol patent
- Reviewing technical designs for patentable features

## Resource Links

### Technical Documentation (Lark)

| Document | URL | Fallback |
|----------|-----|----------|
| **Patent Template** | https://bytedance.us.larkoffice.com/docx/AGcOdirmCoGUZMxVwNTuer2as5d | `assets/patent-template.md` |
| **Tech Proposal** | https://bytedance.larkoffice.com/wiki/HLuDw00GIiSy2bkcEfnctRfonGb | Local: `Tech-proposal.pdf` |
| **ERD** | https://bytedance.us.larkoffice.com/docx/KeIFdcUmooNUhAxMy3GuMUpVsLY | - |
| **Server Tech Design** | https://bytedance.larkoffice.com/wiki/Aw37wFB2ci30ljkH4G2cffUTnyd | - |
| **iOS Tech Design** | https://bytedance.us.larkoffice.com/docx/Qr9ndrHDqoUElyxHXDMuHabxsRf | - |
| **Android Tech Design** | Similar to iOS design | - |
| **Architecture Overview** | https://bytedance.larkoffice.com/wiki/IMfWw0b9MiahuokLTJ0cXXxYnAe | - |

### Local Assets
- `assets/patent-template.md` - ByteDance IES invention disclosure form template

### Reference Files
- `references/uspto-guidelines.md` - USPTO requirements and software patent best practices
- `references/prior-art-search.md` - Prior art search workflow and tools

## Workflow

### Phase 1: Prior Art Search

**Objective**: Establish novelty and identify differentiation points.

1. Read `references/prior-art-search.md` for search methodology
2. Search patent databases for related technologies:
   - AIGC workflow systems
   - Cross-platform workflow engines
   - AI content generation protocols
   - Workflow orchestration architectures
3. Document findings in a prior art summary table
4. Identify gaps in existing solutions that this invention addresses

### Phase 2: Technical Analysis

**Objective**: Extract patentable features from technical documentation.

1. Fetch technical documents using `lark_docs` MCP:
   ```
   mcp__lark_docs__get_lark_doc_content(documentUrl)
   ```
2. If Lark access fails, use local fallback: `Tech-proposal.pdf`
3. Analyze each document for:
   - Novel technical approaches
   - Unique architectural decisions
   - Specific implementation innovations
   - Technical problems solved

### Phase 3: Draft Invention Disclosure

**Objective**: Complete the patent disclosure form.

1. Load template from `assets/patent-template.md`
2. Complete each section:

   **Section 1 - Title**: Concise, descriptive invention name

   **Section 2 - Background** (Critical):
   - Current state of AIGC workflow technologies
   - Problems with existing solutions
   - Reference prior art search findings

   **Section 3 - Summary**:
   - Technical problem addressed
   - High-level solution approach
   - Key beneficial effects

   **Section 4 - Detailed Description** (Critical):
   - System architecture diagrams
   - Method flowcharts
   - Multiple embodiments (method + system)
   - Technical implementation details

   **Section 5 - Claims**:
   - List key innovation points for protection
   - Consider both method and system claims
   - Include variations and dependent features

   **Section 6 - Related Documents**:
   - Link to technical design docs

### Phase 4: USPTO Compliance Review

**Objective**: Ensure documentation meets USPTO requirements.

1. Read `references/uspto-guidelines.md`
2. Verify:
   - [ ] Technical effect is demonstrated (not abstract idea)
   - [ ] Sufficient detail for skilled person to implement
   - [ ] Claims assign all steps to single entity
   - [ ] Both method and system embodiments included
   - [ ] All inventors identified (humans only)

### Phase 5: Output Generation

**Objective**: Produce final documentation.

1. Generate markdown patent disclosure document
2. Save to `/Users/bytedance/Work/comment/Docs/` folder
3. Include:
   - Prior art search summary
   - Complete invention disclosure form
   - Supporting diagrams descriptions
   - Claims outline

## Key Innovation Points to Emphasize

Based on the invention title, highlight these aspects:

1. **Universal Protocol**: Cross-platform workflow definition format
2. **Cross-Platform Engine**: Unified execution across iOS/Android/Server
3. **AIGC-Specific**: Optimizations for generative AI workloads
4. **Workflow Orchestration**: Task dependency and execution management

## Output Format

All generated documents should be in markdown format and saved to:
`/Users/bytedance/Work/comment/Docs/patent-[topic]-[date].md`

## Notes

- Always use `lark_docs` MCP to fetch ByteDance Lark documents
- For git operations, execute in `/TikTok` folder
- Follow AIGC-specific guidance in `TikTok/Modules/TikTokStudio/BasicBiz/AIGC/CLAUDE.md`
