# 知识卡片插图 Eval Criteria

Score each dimension 1-5. Image PASSES if total >= 32/40 (80%) with no dimension below 3.

## 8 Dimensions

### 1. Self-Explanatory (自解释性) — Weight: HIGH
Can a viewer understand 90% of the concept WITHOUT reading surrounding article text?
- 5: Viewer gets the full idea from the image alone — title states the concept, labels explain each element, bottom insight synthesizes the takeaway
- 4: Viewer gets ~80% — one element is ambiguous without context
- 3: Viewer gets the general topic but misses key distinctions
- 2: Image suggests a topic but is mostly decorative
- 1: Image is decorative; requires article text to understand anything

**Common failure**: Image looks nice but has no text → automatic score 1-2. Text IS the explanation.

### 2. Text Integration (文字融合) — Weight: HIGH
Does the image contain embedded Chinese/English text labels, headings, and annotations as integral parts of the composition?
- 5: Title + numbered/labeled elements + callout descriptions + bottom insight banner — text IS the structural backbone
- 4: Title and main labels present; one section could use more annotation
- 3: Some labels but key concepts unlabeled
- 2: Only a title, no other text
- 1: No text at all (pure illustration)

**Minimum for score 4**: Title (top) + at least 3 labeled elements (middle) + insight text (bottom)

### 3. Information Density (信息密度) — Weight: HIGH
How much conceptual content is packed into the image?
- 5: Multiple concepts (3+), their relationships, and data points all visible. Equivalent to a full paragraph of text.
- 4: 2-3 concepts with supporting detail
- 3: One main concept with limited supporting detail
- 2: One concept, minimal detail
- 1: Single simple metaphor with no supporting structure

**Reference**: Post2/slide_06 (七层架构 building) = score 5. Post2/slide_08 (brain + hexagon + comparison) = score 5.

### 4. Visual Metaphor Clarity (视觉隐喻清晰度) — Weight: MEDIUM
Is the core metaphor immediately recognizable and apt?
- 5: Metaphor is intuitive AND reinforced by labels (building=layers + floor labels, horse=control + zone labels)
- 4: Metaphor is intuitive without labels
- 3: Metaphor requires a moment of interpretation
- 2: Metaphor is unclear
- 1: Metaphor is confusing or absent

### 5. Structural Layout (结构布局) — Weight: MEDIUM
Does the image have clear visual hierarchy and organized spatial structure?
- 5: Clear 三段式 structure (title → labeled diagram → insight banner), clean reading flow
- 4: Clear structure with minor layout issues
- 3: Somewhat organized but messy areas
- 2: Unclear reading order
- 1: Chaotic, no structure

**What works**: Top-to-bottom flow, consistent panel sizing, callout boxes with leader lines, color-coded sections.

### 6. Style Consistency (风格一致性) — Weight: MEDIUM
Does it match the 科普插图 flat editorial style with bold outlines and muted palette?
- 5: Perfect Ligne Claire, flat fills, warm muted tones, consistent with series
- 4: Mostly flat, minor deviations
- 3: Mostly flat but some photorealistic elements bleed in
- 2: Mixed styles
- 1: Photorealistic or inconsistent style

### 7. Color Palette (配色方案) — Weight: LOW
Is the palette limited, warm, and muted as specified?
- 5: Strictly limited palette — terracotta, sage, slate, cream, charcoal + one accent
- 4: Mostly correct, one off-palette color
- 3: Palette is warm but too many colors
- 2: Some garish or cold colors
- 1: Random or garish colors

### 8. Legibility at Presentation Size (演示尺寸可读性) — Weight: LOW
Will text and details be legible when displayed in a long-form document or projected?
- 5: All text and icons clear at 50% zoom
- 4: Main text and labels legible; smallest annotations slightly tight
- 3: Main text legible, small labels hard to read
- 2: Some text blurry or overlapping
- 1: Text is blurry or too small to read

**Practical limit**: Max ~8 distinct text blocks per image. More than that and legibility suffers.

## MANDATORY: LLM Image Reading Before Scoring

**NEVER score an image without reading it first.** Use the Read tool on the generated .png file and visually inspect EVERY text element in the image. Specifically:

1. **Read every text block** — title, every label, every callout, every badge, every banner line
2. **Check for duplicates** — same text appearing on two different elements (Gemini sometimes copies labels)
3. **Check for typos** — common: "Aontext" instead of "Context", garbled characters
4. **Check for missing elements** — count the expected elements vs what actually rendered
5. **Cross-reference against the prompt** — did every explicitly requested text element appear?

A "generation succeeded" message from the script is NOT evidence that the image is correct. The script only checks that bytes were returned — it cannot validate content.

**Failure example (Image 5 English v1)**: Script reported success, but the image had duplicate symptom text on two steps, missing symptoms on two other steps, and a typo "Aontext". These would have been caught by reading the image.

## Pass/Fail Decision

- **PASS**: Total >= 32/40, no dimension below 3, AND all text verified by visual inspection
- **REDO**: Any dimension below 3, OR total < 32, OR any text duplication/typo/missing element
- **Action on REDO**: Identify the lowest-scoring dimensions, diagnose root cause from the table below, modify prompt, regenerate

## Common Failures and Fixes

| Failure Pattern | Typical Score | Root Cause | Prompt Fix |
|---|---|---|---|
| Beautiful but empty | 24/40 | Prompt said "no text/labels" | Remove anti-text instructions; add explicit Chinese title, labels, callouts |
| Generic illustration | 26/40 | Prompt was keyword-list style | Rewrite as narrative prose with 三段式 layout (TOP/MIDDLE/BOTTOM) |
| Right content, wrong layout | 30/40 | No structural instructions | Add explicit section descriptions: "TOP SECTION — TITLE: ...", "MIDDLE SECTION — ..." |
| Text illegible | 33/40 | Too many text blocks crammed in | Reduce to max 8 text blocks; specify "large bold" for title |
| Style drift | 34/40 | Scene description overrides anchor | Remove "realistic", "detailed", "3D" from scene; let style anchor do its job |
| Duplicate/wrong text | 35/40 | Gemini copied label from one element to another, or hallucinated text | Read the actual image; if text is wrong, regenerate with more explicit/unique text per element |
| Missing elements | 34/40 | Too many text items requested; Gemini dropped some | Reduce total text blocks or make each more distinctive in the prompt |
| Typo in rendered text | 37/40 | Gemini misspelled a word | Regenerate; add the word in ALL CAPS or quotes for emphasis |

## Validated Scores (Reference)

These images were generated and evaluated during the first production run:

| Image | Pattern | v1 Score | v2 Score | Key Fix |
|---|---|---|---|---|
| Horse/rider paradigm | Labeled Metaphor | 24/40 FAIL | 38/40 PASS | Added Chinese title, zone labels, insight banner |
| Same model comparison | Split Comparison | 40/40 PASS | — | First-try perfect |
| Four failure modes | 2×2 Grid | 39/40 PASS | — | First-try pass |
| Six-layer architecture | Building Cross-Section | 38/40 PASS | — | First-try pass |
| Maturity ladder | Ascending Staircase | 39/40 PASS | — | First-try pass |
| Steering evolution | Horizontal Triptych | 39/40 PASS | — | First-try pass |

**Key learning**: Once the 知识卡片 format (三段式 + explicit text) was established, all subsequent images passed on first attempt. The v1 failure was from treating images as decorative art instead of infographics.
