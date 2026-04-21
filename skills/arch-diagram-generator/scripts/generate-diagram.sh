#!/bin/bash
# AI Architecture Diagram Generator
# Usage: ./generate-diagram.sh <json_file> <style> [output_file]

set -e

GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyCDXy8c31MDaL-q8c4Z05bvmuXF1NSnTJs}"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent"

# Parse arguments
JSON_FILE="${1:-}"
STYLE="${2:-minimalist style and professional}"
OUTPUT_FILE="${3:-architecture-diagram-$(date +%Y%m%d-%H%M%S).png}"
ASPECT_RATIO="${4:-3:4}"

# Validate input
if [ -z "$JSON_FILE" ]; then
    echo "Usage: $0 <json_file> [style] [output_file] [aspect_ratio]"
    echo ""
    echo "Styles:"
    echo "  minimalist style and professional (default)"
    echo "  modern and colorful"
    echo "  dark mode with neon accents"
    echo "  blueprint technical drawing"
    echo "  corporate presentation style"
    echo "  hand-drawn sketch style"
    exit 1
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found: $JSON_FILE"
    exit 1
fi

# Read JSON content
JSON_CONTENT=$(cat "$JSON_FILE")

# Build the prompt
PROMPT="Generate a ${STYLE} building block diagram.

\`\`\`json
${JSON_CONTENT}
\`\`\`

--aspect_ratio ${ASPECT_RATIO}"

# Escape for JSON
ESCAPED_PROMPT=$(echo "$PROMPT" | jq -Rs .)

# Make API request
echo "Generating diagram with style: $STYLE"
echo "Output file: $OUTPUT_FILE"

RESPONSE=$(curl -s -X POST "${API_URL}?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{
        \"contents\": [{
            \"parts\": [{
                \"text\": ${ESCAPED_PROMPT}
            }]
        }],
        \"generationConfig\": {
            \"responseModalities\": [\"TEXT\", \"IMAGE\"]
        }
    }")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    echo "Error from API:"
    echo "$RESPONSE" | jq '.error'
    exit 1
fi

# Extract and save image
IMAGE_DATA=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[] | select(.inlineData) | .inlineData.data' 2>/dev/null)

if [ -z "$IMAGE_DATA" ] || [ "$IMAGE_DATA" = "null" ]; then
    echo "No image generated. API response:"
    echo "$RESPONSE" | jq '.candidates[0].content.parts[].text' 2>/dev/null || echo "$RESPONSE"
    exit 1
fi

# Decode and save
echo "$IMAGE_DATA" | base64 -d > "$OUTPUT_FILE"

echo "Diagram saved to: $OUTPUT_FILE"
echo ""
echo "Text response from AI:"
echo "$RESPONSE" | jq -r '.candidates[0].content.parts[] | select(.text) | .text' 2>/dev/null || true
