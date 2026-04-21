# Kepuhua Preset Styles

Named style presets for the kepuhua-image-gen skill. Each style is a complete style anchor that replaces the default in generate.sh. To use a preset, set `KEPUHUA_STYLE` env var before calling generate.sh.

```bash
export KEPUHUA_STYLE=rick-morty
~/.claude/skills/kepuhua-image-gen/scripts/generate.sh output.png "scene..." "3:4" "2K"
```

---

## kepu-classic (Default)

**Name**: 科普经典 / Kepu Classic
**Mood**: Warm, professional, educational
**Best for**: Chinese-language presentations, articles, documentation, serious infographics
**Reference image**: `img5-maturity-ladder.png` (Chinese maturity ladder)

**Visual DNA**:
- Bold uniform black outlines (~2-3px), equal weight on all elements
- Solid flat color fills, zero gradients or shadows
- Warm muted earth-tone palette: terracotta (#C1603A), sage green (#7A9E7E), slate blue (#4A6FA5), warm cream background (#F5EFE0), charcoal (#1A1A1A), warm yellow accent (#E8C96A)
- Cute simplified robots: round head, cylindrical body, single circular eye, small antenna, light metallic gray-blue body. Professional but friendly.
- Rounded-corner speech bubble callouts for annotations
- Dark charcoal insight banner at bottom with bold white text + accent color highlight
- Chinese text integration: large bold title, bilingual labels, diagnostic badges
- 3D isometric-lite staircase/buildings acceptable but fills remain flat (no shading)
- Mid-century educational diagram × Franco-Belgian Ligne Claire tradition

**Style anchor**:
```
A knowledge card illustration (知识卡片) in flat editorial Ligne Claire style for a popular science magazine.

This is an INFOGRAPHIC, not decorative art. It must contain embedded text (Chinese and/or English) as integral structural elements: titles, numbered labels, callout badges, annotation text, and insight banners. A viewer should understand 90% of the concept from the image alone.

Visual rules (apply strictly):
- Bold uniform black outlines of equal weight around ALL elements, approximately 2-3px equivalent thickness. No variation in line weight between foreground and background.
- Solid flat color fills ONLY. Absolutely no gradients, no soft shadows, no ambient occlusion, no 3D shading of any kind.
- Strictly limited warm muted color palette: dusty terracotta orange (#C1603A), sage green (#7A9E7E), slate blue (#4A6FA5), warm cream (#F5EFE0), dark charcoal (#1A1A1A) for outlines, and one accent of soft warm yellow (#E8C96A). No other colors permitted.
- Simplified proportions for all objects and figures. Human figures are 4-5 heads tall with minimal facial detail (dot eyes, simple smile). Expressive gestures over facial complexity.
- Clean warm cream background (#F5EFE0), not pure white.
- Flat 2D composition. No perspective vanishing points, no depth of field, no atmospheric perspective. Slight overlap for layering is acceptable.
- Mid-century educational diagram aesthetic crossed with Franco-Belgian comic clear-line tradition.
- No photorealism, no 3D rendering, no photography style, no watermarks, no signatures.
- All text rendered in clean sans-serif style. Titles are large and bold. Labels are clear and legible.
- The overall feel should be warm, approachable, and pedagogical — like opening a well-designed popular science magazine for curious adults.
- The image MUST have a structured layout: title section at top, main diagram in center, and an insight/summary bar at the bottom on a dark charcoal background with white text.
```

---

## rick-morty

**Name**: Rick & Morty Knowledge Card
**Mood**: Playful, irreverent, humorous but still informative
**Best for**: English-language presentations, tech talks with humor, social media, engagement-first content
**Reference images**: `img1-en-paradigm-shift.png` through `img6-en-steering-evolution.png`

**Visual DNA**:
- Everything from kepu-classic PLUS:
- Wobbly, slightly uneven outlines (not perfectly uniform — hand-drawn feeling)
- Exaggerated expressions: spiral eyes for confusion, sparkle eyes for confidence, tongue-out for effort
- Characters are goofier: robots do finger-guns, scientists have crazy hair, DevOps engineers have dark circles and energy drink cans
- Visual humor embedded in the scenes (robot tangled in cables drooling, victory flag on clearly broken building)
- Same knowledge card structure (title → diagram → insight banner) but with comedic energy
- Same warm cream background and muted palette base, but slightly more vivid fills
- The humor never undermines the information — the joke reinforces the concept

**Style anchor**:
```
A knowledge card illustration in a playful Rick-and-Morty-inspired cartoon style — exaggerated expressions, wobbly outlines, slightly irreverent humor, but still structured as an informative infographic. Bold outlines, flat vivid fills, warm cream background.

This is an INFOGRAPHIC with humor, not just a cartoon. It must contain embedded text as integral structural elements: titles, numbered labels, callout badges, annotation text, and insight banners. A viewer should understand 90% of the concept from the image alone. The humor reinforces the message, never obscures it.

Visual rules (apply strictly):
- Bold but slightly wobbly hand-drawn outlines around all elements, giving a lively imperfect energy.
- Solid flat color fills with slightly more vivid saturation than traditional 科普. No gradients, no shadows.
- Warm muted palette base: terracotta orange, sage green, slate blue, warm cream background, charcoal outlines. Slightly more vivid than kepu-classic.
- Characters have exaggerated expressions: spiral eyes for confusion, sparkle/star eyes for confidence, wide grins, tongue-out effort faces. Rick-and-Morty proportions: slightly oversized heads, expressive limbs.
- Robots are goofier versions: same round head + single eye + antenna base design, but with personality — sunglasses for cool poses, hard hats for work, drooling when confused.
- Visual humor in every scene: cables as spaghetti, victory flags on clearly broken structures, energy drink cans on desks, comically oversized megaphones.
- Clean warm cream background (#F5EFE0).
- Same 三段式 structure: title at top, labeled diagram in center, dark charcoal insight banner at bottom.
- All text rendered in clean sans-serif, slightly bolder/larger than kepu-classic for the cartoon context.
- The overall feel should be like a well-designed science poster that makes you laugh AND learn.
```

---

## Adding New Styles

To add a new preset:

1. Generate 2-3 reference images with the new style to validate it
2. Document the **Visual DNA** (what makes it distinct from existing presets)
3. Write the complete **style anchor** text
4. Add the entry to this file
5. Update generate.sh to support `KEPUHUA_STYLE` env var for preset selection
