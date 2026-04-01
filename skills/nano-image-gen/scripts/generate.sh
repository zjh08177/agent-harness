#!/bin/bash
# kepuhua-image-gen — Generate 知识卡片 style images via Gemini API
# Usage: generate.sh <output_path> <scene_description> [aspect_ratio] [image_size]
#
# Requires: GEMINI_API_KEY environment variable
# Style presets: KEPUHUA_STYLE=kepu-classic (default) | rick-morty
# Aspect ratios: 1:1, 16:9, 9:16, 4:3, 3:4, 3:2, 2:3 (default: 3:4)
# Image sizes: 512, 1K, 2K, 4K (default: 2K)

set -euo pipefail

OUTPUT_PATH="${1:?Usage: generate.sh <output_path> <scene_description> [aspect_ratio] [image_size]}"
SCENE="${2:?Missing scene description}"
ASPECT_RATIO="${3:-3:4}"
IMAGE_SIZE="${4:-2K}"
MODEL="${KEPUHUA_MODEL:-gemini-3-pro-image-preview}"
STYLE="${KEPUHUA_STYLE:-kepu-classic}"

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "❌ GEMINI_API_KEY not set. Export it first: export GEMINI_API_KEY=your_key" >&2
  exit 1
fi

# ──────────────────────────────────────────────
# Style Presets — select via KEPUHUA_STYLE env
# See references/styles.md for full documentation
# ──────────────────────────────────────────────

STYLE_KEPU_CLASSIC="A knowledge card illustration (知识卡片) in flat editorial Ligne Claire style for a popular science magazine.

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
- The image MUST have a structured layout: title section at top, main diagram in center, and an insight/summary bar at the bottom on a dark charcoal background with white text."

STYLE_RICK_MORTY="A knowledge card illustration in a playful Rick-and-Morty-inspired cartoon style — exaggerated expressions, wobbly outlines, slightly irreverent humor, but still structured as an informative infographic. Bold outlines, flat vivid fills, warm cream background.

This is an INFOGRAPHIC with humor, not just a cartoon. It must contain embedded text as integral structural elements: titles, numbered labels, callout badges, annotation text, and insight banners. A viewer should understand 90% of the concept from the image alone. The humor reinforces the message, never obscures it.

Visual rules (apply strictly):
- Bold but slightly wobbly hand-drawn outlines around all elements, giving a lively imperfect energy.
- Solid flat color fills with slightly more vivid saturation than traditional kepu. No gradients, no shadows.
- Warm muted palette base: terracotta orange, sage green, slate blue, warm cream background, charcoal outlines. Slightly more vivid than kepu-classic.
- Characters have exaggerated expressions: spiral eyes for confusion, sparkle eyes for confidence, wide grins, tongue-out effort faces. Slightly oversized heads, expressive limbs.
- Robots are goofier: same round head + single eye + antenna base design, but with personality — sunglasses for cool, hard hats for work, drooling when confused.
- Visual humor in every scene: cables as spaghetti, victory flags on broken structures, energy drink cans, comically oversized megaphones.
- Clean warm cream background (#F5EFE0).
- Same structured layout: title at top, labeled diagram in center, dark charcoal insight banner at bottom.
- All text rendered in clean sans-serif, slightly bolder than kepu-classic.
- The overall feel should be like a well-designed science poster that makes you laugh AND learn."

# Select style
case "${STYLE}" in
  kepu-classic|classic|default)
    STYLE_ANCHOR="${STYLE_KEPU_CLASSIC}"
    ;;
  rick-morty|rickmorty|rm)
    STYLE_ANCHOR="${STYLE_RICK_MORTY}"
    ;;
  *)
    echo "❌ Unknown style: ${STYLE}. Available: kepu-classic, rick-morty" >&2
    exit 1
    ;;
esac

FULL_PROMPT="${STYLE_ANCHOR}

Scene to illustrate:
${SCENE}"

# ──────────────────────────────────────────────
# API call
# ──────────────────────────────────────────────
ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent"

REQUEST_BODY=$(cat <<ENDJSON
{
  "contents": [{
    "parts": [{"text": $(echo "$FULL_PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")}]
  }],
  "generationConfig": {
    "responseModalities": ["IMAGE"],
    "imageConfig": {
      "aspectRatio": "${ASPECT_RATIO}",
      "imageSize": "${IMAGE_SIZE}"
    }
  }
}
ENDJSON
)

echo "🎨 Generating 知识卡片..." >&2
echo "   Style: ${STYLE}" >&2
echo "   Model: ${MODEL}" >&2
echo "   Aspect: ${ASPECT_RATIO}" >&2
echo "   Size: ${IMAGE_SIZE}" >&2
echo "   Output: ${OUTPUT_PATH}" >&2

RESPONSE=$(curl -s -X POST "${ENDPOINT}" \
  -H "x-goog-api-key: ${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "${REQUEST_BODY}" \
  --max-time 120)

# ──────────────────────────────────────────────
# Extract image
# ──────────────────────────────────────────────
ERROR_MSG=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'error' in data:
        print(data['error'].get('message', 'Unknown API error'))
    elif 'candidates' not in data:
        print('No candidates in response. Possible safety filter or quota issue.')
    else:
        # Check for image data
        found = False
        for part in data.get('candidates', [{}])[0].get('content', {}).get('parts', []):
            if 'inlineData' in part:
                found = True
                break
        if not found:
            print('No image data in response. Model may have returned text only.')
except json.JSONDecodeError:
    print('Invalid JSON response from API')
" 2>/dev/null)

if [ -n "$ERROR_MSG" ]; then
  echo "❌ API Error: ${ERROR_MSG}" >&2
  echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | head -30 >&2
  exit 1
fi

# Decode base64 image and save
echo "$RESPONSE" | python3 -c "
import sys, json, base64
data = json.load(sys.stdin)
for part in data['candidates'][0]['content']['parts']:
    if 'inlineData' in part:
        img_bytes = base64.b64decode(part['inlineData']['data'])
        with open('${OUTPUT_PATH}', 'wb') as f:
            f.write(img_bytes)
        size_kb = len(img_bytes) / 1024
        unit = 'KB' if size_kb < 1024 else 'MB'
        size_val = size_kb if size_kb < 1024 else size_kb / 1024
        print(f'✅ Saved: ${OUTPUT_PATH} ({size_val:.0f} {unit})')
        break
"
