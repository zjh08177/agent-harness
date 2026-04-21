---
name: kepuhua-image-gen
description: "Generate 知识卡片 (knowledge card) style illustrations for presentations and articles via Gemini API. Produces self-explanatory infographic images with embedded Chinese text labels, titled sections, and insight banners in a flat 科普插图 editorial style. Triggers on: '生成插图', '知识卡片', '科普风格', 'generate illustration', 'kepuhua', or when presentation/article images are needed. IMPORTANT: These are knowledge cards, not decorative art — every image must be self-explanatory without surrounding text."
---

# 知识卡片 Image Generator (Kepuhua)

Generate self-explanatory knowledge card illustrations (知识卡片) in Chinese popular science magazine style via Google Gemini API. Every image is an **infographic** — dense with embedded text, labels, and structured layouts — not decorative art.

**Core principle**: A viewer should understand 90% of the concept from the image ALONE, without reading any surrounding article text.

## Prerequisites

- `GEMINI_API_KEY` environment variable
- `curl`, `python3` available in PATH

## Workflow: Generate → Eval → Iterate

This skill follows a mandatory eval loop. Never ship an image without evaluating it.

### Step 1: Write a Knowledge Card Prompt

Every prompt MUST follow the **三段式 layout** (three-section structure):

```
TOP SECTION — TITLE:
Large bold Chinese title: '[主标题]'
Below in smaller text: '[英文副标题或来源]'

MIDDLE SECTION — [DIAGRAM TYPE]:
[Detailed description of the visual content, labels, callout boxes,
 Chinese annotation text, numbered items, etc.]

BOTTOM SECTION — INSIGHT BAR:
Dark charcoal banner with white Chinese text: '[核心洞察/金句]'
Second line in mint-colored text: '[数据来源或英文引用]'
```

Write in **narrative prose** — Gemini responds much better to "A scene showing..." than comma-separated keywords.

**CRITICAL**: Specify ALL text content explicitly in the prompt. Every label, every title, every annotation, every callout — if you want text in the image, write the exact Chinese/English words in the prompt. Gemini renders Chinese text well when explicitly instructed.

### Step 2: Generate

```bash
~/.claude/skills/kepuhua-image-gen/scripts/generate.sh \
  /path/to/output.png \
  "Your knowledge card prompt here" \
  "3:4" \
  "2K"
```

| Parameter | Options | Default | When to use |
|-----------|---------|---------|-------------|
| Aspect ratio | `3:4`, `16:9`, `4:3` | `3:4` | `3:4` vertical cards (most common), `16:9` horizontal triptychs/comparisons |
| Image size | `1K`, `2K`, `4K` | `2K` | `2K` for presentations, `4K` for print |
| Model | via `KEPUHUA_MODEL` env | `gemini-3-pro-image-preview` | Best quality; use `gemini-3.1-flash-image-preview` for speed |

### Step 3: Eval the Image

Read the generated image and evaluate against the 8-dimension criteria in `references/eval-criteria.md`:

| Dimension | Weight | What to check |
|-----------|--------|---------------|
| Self-Explanatory | HIGH | Can viewer get 90% of the concept from image alone? |
| Text Integration | HIGH | Title, labels, annotations, callouts all present and legible? |
| Information Density | HIGH | Multiple concepts, relationships, data points visible? |
| Visual Metaphor | MEDIUM | Core metaphor immediately recognizable? |
| Structural Layout | MEDIUM | Clear visual hierarchy and reading flow? |
| Style Consistency | MEDIUM | Ligne Claire flat style with muted palette? |
| Color Palette | LOW | Limited warm muted tones as specified? |
| Legibility | LOW | Text readable at presentation zoom? |

**PASS**: Total >= 32/40, no dimension below 3.
**REDO**: Any dimension below 3 → identify the failing dimension → modify prompt → regenerate.

### Step 4: Iterate if Needed

When an image fails eval, diagnose the root cause and fix the prompt:

| Failure | Root Cause | Prompt Fix |
|---------|------------|------------|
| Not self-explanatory | Missing text/labels | Add explicit Chinese title, numbered labels, callout text |
| Low information density | Too few concepts | Add more labeled elements, data points, comparison structure |
| Poor layout | No structure instructions | Add explicit TOP/MIDDLE/BOTTOM section descriptions |
| Style drift | Scene description overrides anchor | Remove any "realistic", "photo", "3D" words from scene |
| Illegible text | Too much crammed in | Reduce number of text elements, increase font size instructions |

## Proven Knowledge Card Patterns

These six patterns were validated in production (38-40/40 eval scores). Use as templates.

### Pattern 1: Labeled Metaphor Diagram
**Use for**: Explaining a conceptual framework via visual analogy
**Layout**: Title → central metaphor illustration with numbered labeled zones → insight banner
**Aspect**: 3:4
**Example**: Three paradigm layers shown as zones around a horse and rider, each zone numbered and labeled in Chinese with callout badges
**Key instruction**: "Three clearly separated conceptual zones are marked around [subject], each with a numbered label and Chinese description text"

### Pattern 2: Split Comparison (A vs B)
**Use for**: Same entity, different conditions/outcomes
**Layout**: Title → left half (bad) vs right half (good) separated by dashed line → data points → insight banner
**Aspect**: 3:4
**Example**: Same robot in chaotic vs organized environment, with performance percentages (6.7% vs 68.3%)
**Key instruction**: "The center is divided into LEFT and RIGHT halves by a vertical dashed line. Both show the exact same [character] — identical in design to emphasize they are the SAME"

### Pattern 3: 2×2 Grid (Four Items)
**Use for**: Categorizing 4 failure modes, 4 principles, 4 types
**Layout**: Title → four equal panels in 2×2 grid, each with illustration + bold label + description text → insight banner
**Aspect**: 3:4
**Example**: Four Agent failure modes, each panel with a robot in a comical failure situation
**Key instruction**: "Four equal rectangular panels arranged in a 2x2 grid. Each panel contains: [character] illustration plus labeled description. Panel N (top-left, labeled '[title]' in bold at top of panel):"

### Pattern 4: Building Cross-Section (Layered Architecture)
**Use for**: Multi-layer systems, stack architectures, hierarchies
**Layout**: Title → cross-section building with N floors, each floor a distinct color with scene + callout label → insight banner
**Aspect**: 3:4
**Example**: Six-layer Harness architecture as a six-story building
**Key instruction**: "A cross-section of a [N]-story building viewed from front with front wall removed. Each floor is a distinct color and contains a small scene with icons. Labels placed to the right in speech-bubble callout boxes"

### Pattern 5: Ascending Staircase (Maturity/Progression)
**Use for**: Maturity models, skill progressions, adoption ladders
**Layout**: Title → staircase ascending left-to-right with labeled steps, each with character + description + diagnostic badge → insight banner
**Aspect**: 3:4
**Example**: Five-step Harness maturity ladder from L0 to L5
**Key instruction**: "A staircase with [N] wide platform steps ascending from lower-left to upper-right. Each step is a distinct color with a [character] plus label text. Diagnostic badge: '[symptom text]'"

### Pattern 6: Horizontal Triptych (Timeline/Evolution)
**Use for**: Historical evolution, three-stage progressions, era comparisons
**Layout**: Title → three panels left-to-right with timeline arrow and years → each panel has era label + scene + transition description → insight banner
**Aspect**: 16:9 (landscape)
**Example**: Steam engine era → Kubernetes era → AI Agent era
**Key instruction**: "Three scenes arranged LEFT to CENTER to RIGHT in equal vertical panels, separated by thin dashed vertical lines. A horizontal arrow runs below with years marked. All human figures share the same [pose] — creating a visual rhyme across eras"

## Style Anchor (Embedded in Script)

The generate.sh script auto-prepends this style anchor. **Do not duplicate** these visual rules in scene descriptions.

**Visual identity** (frozen — never modify):
- Ligne Claire: bold uniform black outlines of equal weight (~2-3px)
- Solid flat color fills ONLY — no gradients, no shadows, no 3D
- Palette: terracotta (#C1603A), sage green (#7A9E7E), slate blue (#4A6FA5), cream (#F5EFE0), charcoal (#1A1A1A), warm yellow (#E8C96A)
- Simplified figures: 4-5 heads tall, minimal facial detail, expressive gestures
- Warm cream background, flat 2D composition
- Knowledge card aesthetic: text-integrated, labeled, information-dense, self-explanatory

## Series Consistency Rules

When generating multiple images for a single presentation/article:

1. **Freeze the style anchor** — never modify between images
2. **Use exact phrases** — "thick black outline" stays "thick black outline", never "bold border"
3. **Lock recurring characters** — add identity block to EVERY prompt:
   ```
   Recurring character: a friendly robot with round head, cylindrical body,
   single circular eye/lens, small antenna, light metallic gray-blue body,
   simple articulated arms and legs. Same proportions and color in every image.
   ```
4. **Consistent structural pattern** — all images use the 三段式 (title → diagram → insight banner)
5. **Re-paste full prompt** each generation — do not rely on conversation memory

## Anti-Patterns (Learned from Failures)

| Anti-Pattern | Why It Fails | What To Do Instead |
|---|---|---|
| "No text, no labels" in prompt | Produces decorative art that communicates nothing | Always include explicit Chinese title, labels, annotations |
| Keyword-list prompts | Gemini ignores most keywords, produces generic results | Write narrative prose with spatial layout instructions |
| Vague layout ("show a diagram") | Gemini guesses layout, usually poorly | Specify TOP/MIDDLE/BOTTOM with exact content for each section |
| Relying on the image to "speak for itself" | Images without text labels are ambiguous — same visual can mean many things | Text IS the structure. Labels make the metaphor unambiguous. |
| Skipping eval | First attempt often scores 24/40 (decorative) vs 38+/40 (knowledge card) | Always eval. The difference between v1 and v2 is dramatic. |
| Asking for too many text elements | Text becomes illegible if crammed | Max ~8 distinct text blocks per image. Prioritize title + labels + one insight. |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `GEMINI_API_KEY not set` | `export GEMINI_API_KEY=your_key` |
| `No candidates` | Safety filter or quota — check prompt content and API quota |
| Chinese text garbled | Gemini Pro handles Chinese well; ensure prompt specifies exact Chinese text |
| Too photorealistic | Check scene description for words like "realistic", "photo", "detailed texture" |
| Text illegible | Reduce number of text blocks; specify "large bold" for key titles |
| Style inconsistent | Re-paste full style anchor; do not abbreviate between generations |

## Resources

- `scripts/generate.sh` — Generation script with embedded style anchor
- `references/eval-criteria.md` — 8-dimension evaluation rubric (32/40 pass threshold)
