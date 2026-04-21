---
name: performance-review
description: |
  This skill should be used when writing ByteDance performance reviews, including Key Outputs, Self-Review, and Peer Review (360°). Accepts mixed Chinese/English drafts and outputs polished, submittable English content following ByteDance review guidelines. Specialized for AIGC Arch domain context.
---

# Performance Review Writing Skill

Transform draft notes and context into polished, submission-ready performance review content for ByteDance's review system.

## Capabilities

| Review Type | Input | Output |
|-------------|-------|--------|
| **Key Outputs** | Draft notes, project context | Structured output summaries (what, role, output, effect) |
| **Self-Review** | Draft accomplishments/improvements | Polished "Accomplishments" and "Areas of Improvement" sections |
| **Peer Review (360°)** | Observations about colleague | Output + ByteStyle dimension reviews with optional direct feedback |

## Input/Output

- **Input**: Mixed Chinese/English drafts, bullet points, raw context
- **Output**: Polished English prose, ready to copy-paste into ByteDance performance system

## Workflow

### 1. Key Outputs

When the user provides draft work items, transform them into structured Key Outputs.

**Process:**
1. Read `references/key-outputs-guide.md` for format and quality criteria
2. Read `references/aigc-arch-context.md` if the work involves AIGC architecture
3. For each draft item, extract:
   - **What work**: The project/initiative
   - **Role assumed**: Responsibility level and scope
   - **Output achieved**: Concrete deliverables
   - **Effect/Impact**: Metrics, efficiency gains, business value
4. Structure into 3-5 focused outputs (no more)
5. Ensure metrics are specific, not vague

**Quality checks:**
- Focused: Only highest-impact items
- Complete: Role + output + impact for each
- Confidential: Flag any sensitive data for user to desensitize

### 2. Self-Review

When the user provides draft accomplishments or areas for improvement, polish into self-review format.

**Process:**
1. **⚠️ TOP PRIORITY: Read `references/manager-3-1-framework.md`** - Manager's direct feedback on what matters for 3-1
2. **Read `references/2025-key-outputs.md`** - Ground in specific Key Outputs
3. **Read `references/calibration-rubric-3-1.md`** - Align with 3-1 competency criteria
4. Read `references/self-review-guide.md` for structure and examples
5. Read `references/aigc-arch-context.md` for domain vocabulary
6. For **Accomplishments** (follow manager's 5 dimensions):
   - **SEPARATE direct impact from indirect impact** - Direct must stand out
   - **Articulate "Your Diff"** - What's different with you vs without you (MOST CRITICAL for 3-1)
   - Show technical judgment and decision-making, not just task completion
   - Demonstrate direction/quality judgment, not just "I finished it"
   - Link to specific Key Outputs (KO1, KO2, or KO3)
   - Map to calibration criteria (Technical, Business, or Team dimension)
7. For **Areas of Improvement**:
   - Be specific about what didn't go well
   - Identify which 3-1 calibration criteria need strengthening
   - Include forward-looking improvement plans aligned to calibration gaps
8. Ensure this evaluates HOW WELL (not repeating WHAT was done)

**Manager's 5 Evaluation Dimensions (3-1 Level):**
1. **Product Ownership & Outcome**: What are you DIRECTLY responsible and accountable for?
2. **Your Diff** ⭐ MOST CRITICAL: What's different with you vs without you?
3. **Complexity & Technical Ownership**: Medium/long-term plans, handling ambiguity, tech-business tradeoffs
4. **Direction & Quality**: Correct direction, mature solution, sustainable quality
5. **Team & Org Impact**: Team capability growth, not just personal achievement

**Calibration Dimensions (3-1 Level):**
- **Technical Competencies**: Architecture understanding, long-term planning, platform expertise
- **Business Competencies**: Product growth awareness, resource management, accountability
- **Team Contributions**: Echelon building, collective skills enhancement, cross-functional sharing

**Rating Dimensions:**
- **Output** (8-point scale): Actual output vs. role expectations
- **ByteStyle** (5-point scale): Working styles and methods

### 3. Peer Review (360°)

When the user provides observations about a colleague, structure into 360° review format.

**User provides:**
1. Peer's Key Outputs (copy-paste their submitted key outputs)
2. Draft observations for accomplishments (mixed Chinese/English OK)
3. Draft observations for areas of improvement (mixed Chinese/English OK)
4. **Whether the peer is a people leader/manager** (if yes, Leadership Principles apply)

**Skill returns two separate sections:**
- **Output Section**: Accomplishments + Areas of Improvement
- **ByteStyle Section**: Specific feedback for relevant ByteStyle principles
- **Leadership Principles Section** (for managers only): Feedback on leadership behaviors

**Process:**
1. Read `references/peer-review-guide.md` for guidelines
2. **If reviewing a manager**: Also read `references/leadership-principles-guide.md`
3. Analyze peer's Key Outputs to understand their deliverables
4. Transform user's draft into **Output Section**:
   - **Accomplishments**: Role + scope + overall assessment, then specific observations with project names
   - **Areas of Improvement**: Theme label + specific observation + concrete example
5. Transform user's draft into **ByteStyle Section**:
   - Map observations to relevant ByteStyle principles
   - Write specific feedback for each selected principle
6. **For managers only**, add **Leadership Principles Section**:
   - Map observations to the 4 leadership sections
   - Write specific feedback for each relevant principle
7. Ensure feedback is specific, not generic

**Output Section - Common Themes:**
| Theme | What to Look For |
|-------|-----------------|
| Ownership | Full lifecycle follow-through, driving projects independently |
| Communication | Timely updates, proactive status sharing |
| Availability | Responsiveness, accessibility for urgent issues |

**ByteStyle Section - Mapping:**
| Observation | Maps to ByteStyle |
|-------------|------------------|
| Efficiency, velocity issues | Always Day 1 |
| Hiding progress, not exposing problems | Be Candid and Clear |
| Code quality, not meeting high standards | Be Courageous and Aim for the Highest |
| Not fact-based, avoiding root cause | Seek Truth and Be Pragmatic |
| Not learning from mistakes | Grow Together |

**Leadership Principles Section (Managers Only) - The 4 Sections:**
| Section | Key Principles | What to Look For |
|---------|---------------|------------------|
| **1. Sound Judgment** | Mission-driven, Understand fundamentals, Focus on impact | Prioritization, resource allocation, firsthand information |
| **2. Collaborative Environment** | Small ego big picture, Leverage collective wisdom, Lead by example | Takes ownership, listens to different views, practices ByteStyle |
| **3. Build Great Teams** | Lead by qualities, Foster growth, Manage with firm principles | Hiring, feedback, delegation, differentiated rewards, succession |
| **4. Achieve Results** | Set ambitious goals, Be resilient | Clear goals, pushes through difficulties, long-term output |

## Reference Materials

| File | When to Load |
|------|--------------|
| `references/manager-3-1-framework.md` | **⚠️ TOP PRIORITY for Self-Review**; manager's direct feedback on 3-1 evaluation |
| `references/2025-key-outputs.md` | **Always for Self-Review**; ground accomplishments in specific deliverables |
| `references/calibration-rubric-3-1.md` | **Always for Self-Review**; align accomplishments with 3-1 level criteria |
| `references/key-outputs-guide.md` | Writing new Key Outputs |
| `references/self-review-guide.md` | Writing Self-Review (includes manager framework + calibration templates) |
| `references/peer-review-guide.md` | Writing Peer Review (IC colleagues) |
| `references/leadership-principles-guide.md` | **Peer Review for Managers/People Leaders**; the 4 leadership sections |
| `references/aigc-arch-context.md` | Any AIGC-related content (vocabulary, technical context) |

## Output Format

**For Peer Reviews:** Always save to file at `/Users/bytedance/Work/comment/Docs/PSC/peer-review/[name].md`

**For all outputs:** Also display in a clearly marked block that can be directly copied:

```
---BEGIN SUBMITTABLE CONTENT---

[Polished review content here]

---END SUBMITTABLE CONTENT---
```

## Quality Standards

Before outputting, verify:
- [ ] English is grammatically correct and professional
- [ ] Content is specific with concrete examples/metrics
- [ ] For self-review: Evaluates performance, not just lists work
- [ ] For peer review: Based on actual observations, not assumptions
- [ ] No sensitive/confidential data exposed (flag for user review)
- [ ] Appropriate length (substantive but not excessive)

**Self-Review Specific (Manager's Checklist):**
- [ ] Are direct impact items clearly separated from indirect impact?
- [ ] For each accomplishment, is "Your Diff" clearly articulated?
- [ ] Have I shown technical judgment and decision-making, not just task completion?
- [ ] Have I demonstrated understanding of overall architecture and business evolution?
- [ ] Is direction/quality judgment visible, not just "I finished it"?
- [ ] Have I shown team/org impact beyond personal achievements?

## Iteration

The user will iterate on the skill by providing additional materials. When new context is provided:
1. Integrate into the appropriate reference file
2. Update this SKILL.md if workflow changes are needed
3. Confirm changes with user
