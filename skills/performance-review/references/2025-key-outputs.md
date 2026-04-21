# 2025 Key Outputs

This reference contains the user's 2025 Key Outputs for performance review. Use this as the foundation when writing Self-Review and connecting accomplishments to specific deliverables.

**Writing Style Reference:** See manager's example at the end for how to emphasize impact and personal contribution.

---

## Key Output 1: Effect Client Infrastructure & AIGC Offline Processing

**Role:** Tech lead for Effect client infrastructure and AIGC team

**What I Directly Owned & Delivered:**
Designed and delivered the complete offline processing pipeline for AI-generated video effects. Led cross-team integration with Server, TTEH (TikTok Effect House), AME, and Camera teams to enable TikTok's first i2v (image-to-video) features, supporting 70% of new effect production and delivering dozens of global-level popular effects.

**Business Impact:**
- Overall AI effect publish rate: 0.04% → 0.53% (13x improvement)
- AIGC publish rate peak: 0.2% (June), cumulative submissions ~100M
- In-house AIGC effects: 30 effects launched, achieving Global S×1, B×5, C×13, D×6
- IH AI effects: Global S×1, B×7; US SS×1, A×1, B×8; EU SSS×1, S×1, A×3, B×13
- EH AI effects: B+×38, C+×762

**Key Deliverables (with my role):**

| Project | My Role | Status | Impact |
|---------|---------|--------|--------|
| i2v Effect Offline Processing (Q1) | **Tech owner** | Fully Launched | TikTok's first i2v feature, 100 QPS peak capacity |
| i2v Effect Performance Optimization (Q3) | **Tech owner** | Fully Launched | AIGC publish days +2.9%, shortened waiting time |
| i2v Post Processing (Q2) | Tech lead support | Fully Launched | Client post-generation auto video editing |
| EH fl2v Effect (Q2) | Tech lead support | Fully Launched | Multi-asset input protocols for community creators |
| EH Lip-sync & Body-sync i2v (Q3) | **Client owner & Consultation** | Fully Launched | Server-driven AI preview |
| Cloud Editing M1 (Q3) | **Client owner & Consultation** | Fully Launched | First cloud effect "AI Punktoon II", 7 D+ and 2 C+ effects |
| Cloud Editing M2 (Q4) | **Client owner & Consultation** | Fully Launched | "2026 Happy New Year" (Global C), free node composition |
| Task Manager Progress (Q3) | Tech lead support | Fully Launched | Record-to-publish +8% |
| i2i Effect Offline Processing (Q4) | Tech lead support | Fully Launched | AIGC publish rate +1.3%, record-to-publish +7.8% |
| AIGC Path Redesign (Q1) | Tech lead support | Fully Launched | Generation success rate +27%, submission penetration +22% |
| Effect UX Optimizations (Q1) | Tech lead support | Fully Launched | Submission penetration +0.1%–0.18% |

**Showcase Milestones:**
- **AI Mermaid**: First Global S-level AIGC effect in 2 years, drove 430K reactivations (top 2% of effects), L45 submission ratio +19% vs effect baseline
- **AI Sway Dance**: First US A-level AIGC effect in 2 years
- **AI High Roller**: First EU S-level AIGC effect in 2 years
- **AI Food Lotto**: First regional SSS-level effect (JP), lifted JP effect submission baseline +45.7% WoW, overall submission +13.4% WoW

---

## Key Output 2: AIGC Architecture Foundation & Cross-Team Technical Leadership

**Role:** Tech lead for AIGC Arch Tiger team

**What I Directly Owned & Delivered:**
Set the vision, roadmap, and engineering standards that now guide all major AIGC initiatives across TikTok IC and influence other VCs such as Social. Drove both client and server key projects as the POC for all business integrations, leading cross-functional discussions and technical decisions.

**Business Impact:**
- Reduced AI generation flow development time from 8 days to 2 days (75% reduction)
- Integrated 7 major AI projects under unified AIGC architecture in 2025
- Established monitoring infrastructure adopted by all AIGC business lines
- Significantly improved bug resolution efficiency by eliminating reliance on reproduction for root-cause analysis

**Key Deliverables (with my role):**

| Project | My Role | Impact |
|---------|---------|--------|
| Universal AIGC Workflow Protocol | **Tech owner** | Foundation for client/server workflow managers, adopted across Creation and Social |
| Client Workflow Manager Development | **Tech owner** | Unblocked all AIGC business integrations |
| Client Workflow Manager Integration (7 projects) | **Tech owner** | Dev time reduced from 8 days to 2 days per project |
| Monitoring Dashboards | **Tech owner (client), Support (server)** | Real-time health checks, unified event tracking |
| Client Task History Retrieval Tool | **Tech owner** | Adopted by all integrated businesses |
| TT IC AIGC Trace System | Tech lead support | Auto-reported client/server logs searchable by task-id |
| AI Playground | Tech lead support | Internal tool for AI model result experience |
| Prompt Editor 1.0 | **Tech owner** | POC for multi-modal input AIGC generation |
| Multimodal Prompt as Reusable Asset | **Tech owner** | Foundation for ID reuse adopted in AI Theater |
| Agentic Workflow Exploration | Tech lead support | Validated LLM-generated workflow JSON execution |
| AI Theater × AIGC Arch Integration | **Tech support, AIGC Arch tech lead** | Architecture design, ID recording, prompt reuse |

**Integrated Projects Under AIGC Architecture:**
1. Shooting Effects
2. AME AI Makeup
3. AME AIGC Effects
4. AI Self
5. AI Theater
6. Social Avatar
7. Photo & Text

---

## Key Output 3: Team Leadership & Engineering Culture

**Role:** Tech lead for Effect Client Infrastructure (Q1) and AIGC Arch (Q2–Q4)

**Key Contributions:**

**① Technical Mentorship**
- Conducted regular 1:1s with team members for constructive feedback, career path discussions, and project alignment

**② Engineering Quality Standards**
- Promoted small MR practices and established standard MR guidelines
- Introduced AI-assisted code review to improve code quality and review efficiency

**③ Team Building**
- Organized 2 team offsites
- Hosted 3 team lunches in SJ and SEA offices

**④ Knowledge Sharing**
- Hosted 7 sharing sessions advocating AI technologies and AIGC Arch adoption across teams

---

## Manager's Writing Style Reference

Use this as a reference for how to write impactful key outputs that emphasize personal contribution:

> **Scaling AIGC Products and Infra From Breakthroughs to Production-ready Infrastructure**
>
> I led AIGC product delivery alongside infrastructure build-out, achieving both viral impact and measurable business uplift:
>
> **AIGC Product Impact** – Drove step-change growth in AIGC creation, primarily powered by I2V viral effects and foundational AIGC infrastructure.
> - Increased AIGC effect publish rate from 0.04% → 0.16%, reaching the theoretical ceiling under current resource constraints; overall AI effect publish rate from 1.21% → 1.51%. Hold-out experiments confirmed up to +0.87% uplift in overall publish days.
> - Delivered a major I2V breakthrough, with flagship AI Mermaid becoming an industry-level blockbuster and global showcase.
>
> **Scaled AIGC Infrastructure Through Multiple Strategic Initiatives**
> - Built the AIGC infrastructure work force from scratch in a full-stack model...
> - Delivered a unified AIGC client integration layer with full debuggability and observability...
> - Designed and built the workflow-centric AIGC development tool, Workflow Editor, from the ground up...

**Key techniques:**
- Lead with "I led..." / "I drove..." / "I delivered..."
- Quantify impact with before/after metrics
- Use strong verbs: "achieved", "drove", "established", "built from scratch"
- Connect technical work to business outcomes
- Highlight industry-level milestones and firsts
