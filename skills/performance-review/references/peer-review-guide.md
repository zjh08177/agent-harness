# Peer Review (360°) Writing Guide

## Core Principle

Provide honest feedback from your perspective based on actual interaction with the reviewee. The goal is to collect information from multiple perspectives—Leaders will consider all reviewers' opinions.

## Workflow

**User provides:**
1. Peer's Key Outputs (copy-paste their submitted key outputs)
2. Draft observations for accomplishments (mixed Chinese/English OK)
3. Draft observations for areas of improvement (mixed Chinese/English OK)

**Skill returns:**
- **Output Section**: Accomplishments + Areas of Improvement
- **ByteStyle Section**: Specific feedback for relevant ByteStyle principles

## Output Format

Peer review has **two separate sections**:

```
---BEGIN SUBMITTABLE CONTENT---

## Output Section

### Accomplishments

[Overall assessment of their output quality and impact]

Specific observations:
- [Project-specific observation with concrete example]
- [Another observation from actual collaboration]

### Areas of Improvement

[Theme]: [Specific observation with concrete example]

[Theme]: [Specific observation with concrete example]

---

## ByteStyle Section

### [ByteStyle Principle 1]

[Specific feedback with concrete example]

### [ByteStyle Principle 2]

[Specific feedback with concrete example]

---END SUBMITTABLE CONTENT---
```

## Output Section Guidelines

### Accomplishments

**Important:** Content should **focus on user's draft observations**. Use peer's Key Outputs only to add supporting details—do not rewrite or expand beyond what the user observed.

**Structure:**
1. Opening statement based on user's draft
2. "Specific observations:" with bullet points (from user's draft)
3. Add Key Output details only to support user's observations

### Areas of Improvement

**Structure:**
1. Theme label (e.g., Ownership, Communication, Availability)
2. Specific observation with example
3. Impact or suggestion

**Common themes for Output section:**
| Theme | What to Look For |
|-------|-----------------|
| **Ownership** | Full lifecycle follow-through, driving projects independently |
| **Communication** | Timely updates, proactive status sharing |
| **Availability** | Responsiveness, accessibility for urgent issues |
| **Scope handling** | Ability to drive ambiguous or exploratory projects |

## ByteStyle Section Guidelines

ByteStyle is a **separate section** where you select relevant principles and write specific feedback for each.

### Available ByteStyle Principles

| Principle | What to Evaluate |
|-----------|-----------------|
| **Always Day 1** | Efficiency, agility, avoiding complacency |
| **Champion Diversity and Inclusion** | Valuing differences, global thinking, trust |
| **Be Candid and Clear** | Exposing problems, avoiding "managing up", transparency |
| **Seek Truth and Be Pragmatic** | Independent thinking, fact-based, real impact focus |
| **Be Courageous and Aim for the Highest** | High standards, excellence, calculated risks |
| **Grow Together** | Mission-driven, resilience, continuous learning |

### How to Write ByteStyle Feedback

For each selected principle:
1. State the specific behavior gap or strength
2. Provide concrete example(s) from collaboration
3. Include impact or suggestion

**Example:**
```
### Be Candid and Clear

Kris does not raise risks proactively when they occur. When asked about progress, the response is typically "on track," but on the last day before deadlines, issues surface that the work is not finished and has significant problems. This pattern of obscuring progress until the last moment is concerning. Earlier risk identification and transparent status updates would help the team plan and respond appropriately.
```

### Mapping Observations to ByteStyle

| Observation | Maps to ByteStyle |
|-------------|------------------|
| Development velocity, efficiency issues | Always Day 1 |
| Hiding progress, not exposing problems | Be Candid and Clear |
| Code quality, not meeting high standards | Be Courageous and Aim for the Highest |
| Not fact-based, avoiding root cause | Seek Truth and Be Pragmatic |
| Not learning from mistakes | Grow Together |

## Good Example

**Input (User's Draft):**
```
Peer: Kris
Key Outputs: AIGC offline processing, E2E dashboard, debug tool
Accomplishment: Delivered major business projects
Improvement:
- code quality差，多个项目crash和性能问题
- ownership不足，需要push才能推进
- 4点后找不到人
- debug tool用了3周，iOS只用1天
- 隐瞒进度，最后一天才说有问题
```

**Output (Formal Review):**

```
## Output Section

### Accomplishments

Kris served as the Android developer for AIGC infrastructure, delivering multiple features including AIGC offline processing, post-processing framework, wait time exposure, and E2E monitoring capabilities.

Specific observations:
- On the AIGC offline processing project, Kris implemented the Android client-side architecture enabling background generation for i2v effects
- The E2E monitoring dashboard provided visibility into generation time, latency, and success rates

### Areas of Improvement

Ownership and communication: Kris struggles to drive mid-to-large scale projects independently. There is a lack of proactive communication with stakeholders, and progress often requires pushing.

Availability: Kris is rarely available after 4pm, making it difficult to reach him for urgent issues in the evening.

---

## ByteStyle Section

### Always Day 1

Development velocity is a concern. The debug tool took nearly three weeks for development and bug fixing, while iOS completed equivalent functionality in one day.

### Be Candid and Clear

Kris does not raise risks proactively when they occur. When asked about progress, the response is typically "on track," but on the last day before deadlines, issues surface that the work is not finished. Earlier risk identification and transparent status updates would help.

### Be Courageous and Aim for the Highest

Kris's code quality is a significant concern. Multiple projects experienced crashes and performance issues that caused delays. The offline processing and result-url optimization projects were delayed due to feature bugs and performance problems.
```

## Reviewing Managers/People Leaders

**If the peer is a manager**, also evaluate against Leadership Principles. See `references/leadership-principles-guide.md` for full details.

**Additional Section for Managers:**
```
---

## Leadership Principles Section

### [Section Name] - [Principle]

[Specific feedback with concrete example]
```

**The 4 Leadership Sections:**
| Section | Key Principles |
|---------|---------------|
| **1. Sound Judgment** | Be mission-driven, Understand fundamentals, Focus on actual impact |
| **2. Collaborative Environment** | Small ego big picture, Leverage collective wisdom, Lead by example |
| **3. Build Great Teams** | Lead by qualities, Foster growth, Manage with firm principles |
| **4. Achieve Results** | Set ambitious goals, Be resilient |

**Mapping Observations to Leadership Principles:**
| Observation | Maps to Leadership Principle |
|-------------|------------------------------|
| Good prioritization, resource allocation | Understand the fundamentals |
| Gets firsthand info, knows frontline reality | Focus on actual impact |
| Takes ownership beyond scope | Small ego, big picture |
| Listens before deciding, seeks different views | Leverage collective wisdom |
| Gives feedback, mentors, delegates | Foster growth of team members |
| Manages low performers, rewards high performers | Manage with firm principles |
| Clear goals, good communication | Set ambitious and clear goals |

---

## Quality Checklist

Before outputting, verify:
- [ ] Output Section: Accomplishments grounded in peer's actual Key Outputs
- [ ] Output Section: Areas of Improvement have concrete examples
- [ ] ByteStyle Section: Each principle has specific feedback with examples
- [ ] ByteStyle Section: Observations correctly mapped to principles
- [ ] **For Managers**: Leadership Principles Section with relevant feedback
- [ ] Tone is professional and constructive
