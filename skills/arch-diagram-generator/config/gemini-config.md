# Gemini API Configuration Guide

## Overview

This skill uses Google Gemini API for image generation.

## Active Configuration

```bash
# Set this environment variable before using the skill
export GEMINI_API_KEY="AIzaSyBN3_CqrfTUAS6VBoDXyNvPTgF_-32fV4w"
```

## Primary Method: Gemini API Direct

### API Endpoint
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent
```

### cURL Example
```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{
        "text": "Generate a minimalist style and professional building block diagram.\n\n```json\n{YOUR_ARCHITECTURE_JSON}\n```\n\n--aspect_ratio 3:4"
      }]
    }],
    "generationConfig": {
      "responseModalities": ["TEXT", "IMAGE"]
    }
  }'
```

### Response Handling
The response contains base64-encoded image data in `candidates[0].content.parts[].inlineData.data`

---

## Alternative: Crate (TikTok Internal)

**Crate** is TikTok's internal creative generation tool with built-in access to:
- Nano Banana Pro (Gemini 3 Pro Image)
- Seedream 4.5 (ByteDance's latest model)

### Access
URL: https://crate.tiktok-row.net

### Usage
1. Open Crate in browser
2. Select "Nano Banana Pro" or "Seedream 4.5" model
3. Paste the generation prompt
4. Adjust aspect ratio as needed
5. Generate and download

## Option 2: Google AI Studio

### Setup
1. Go to https://aistudio.google.com
2. Sign in with Google account
3. Navigate to "Image generation" section
4. Use Imagen 3 or Gemini with image generation

### API Key (for programmatic access)
1. Go to https://aistudio.google.com/apikey
2. Create new API key
3. Store securely (never commit to code)

## Option 3: Gemini API Direct

### Models for Image Generation
- `gemini-3-pro-image-preview` - Fast, supports image generation
- `imagen-3.0-generate-002` - High quality images

### API Endpoint
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent
```

### Request Format
```json
{
  "contents": [{
    "parts": [{
      "text": "Generate a minimalist style architecture diagram...\n\n```json\n{...}\n```"
    }]
  }],
  "generationConfig": {
    "responseModalities": ["TEXT", "IMAGE"]
  }
}
```

### Headers
```
Content-Type: application/json
x-goog-api-key: YOUR_API_KEY
```

## Option 4: Vertex AI (Enterprise)

For production/enterprise use:
1. Set up Google Cloud project
2. Enable Vertex AI API
3. Use Imagen 3 via Vertex AI

## Environment Variables

If using API directly, set:
```bash
export GEMINI_API_KEY="your-api-key"
```

## Rate Limits

| Tier | Requests/min | Images/day |
|------|--------------|------------|
| Free | 15 | 50 |
| Pay-as-you-go | 60 | 1000 |
| Enterprise | Custom | Custom |

## Troubleshooting

### "Image generation not supported"
- Ensure you're using a model that supports image generation
- Check if your region supports image generation

### "Rate limit exceeded"
- Wait and retry
- Consider upgrading tier

### "Content blocked"
- Review prompt for policy violations
- Architecture diagrams are generally safe

## Best Practices

1. **Use Crate for quick iterations** - No API setup needed
2. **Save successful prompts** - Store in style presets
3. **Batch generations** - Generate multiple styles at once
4. **4K resolution** - Request high resolution for presentations

## Security Notes

- Never commit API keys to version control
- Use environment variables or secure vaults
- Rotate keys periodically
- Monitor usage for anomalies
