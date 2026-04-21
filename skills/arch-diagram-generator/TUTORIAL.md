# Architecture Diagram Generator Tutorial

A step-by-step guide to generating professional architecture diagrams from code or documentation using AI.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Detailed Workflow](#detailed-workflow)
4. [Tips & Best Practices](#tips--best-practices)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### 1. Install the Skill

```bash
# Unzip and move to Claude skills directory
unzip arch-diagram-generator.zip
mv arch-diagram-generator-export ~/.claude/skills/arch-diagram-generator
```

### 2. Set Up Gemini API Key

Get your API key from [Google AI Studio](https://aistudio.google.com/app/apikey), then:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Or add to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence.

### 3. Alternative: Use Crate (TikTok Internal)

If you don't have a Gemini API key, you can use [Crate](https://crate.tiktok-row.net) with the Nano Banana Pro model.

---

## Quick Start

In Claude Code, simply type:

```
Generate an architecture diagram for this project
```

Claude will activate the skill and guide you through the 5-step workflow.

---

## Detailed Workflow

### Step 1: Extract Architecture JSON

Claude analyzes your codebase or documentation and generates a structured JSON representation.

**Input Sources:**
- Code repository (Claude reads the code directly)
- Documentation files (markdown, Lark docs)
- Architecture diagrams or ERD documents

**Output:**
A markdown file saved to `/Docs/architecture/{project-name}-arch.md` containing:
- Summary (layer count, component count, relationships)
- Architecture JSON block
- Notes about any simplifications made

**Example Output Structure:**
```markdown
# Project Architecture

## Summary
- **Layers**: 4
- **Components**: 22
- **Relationships**: 11

## Architecture JSON
\`\`\`json
{
  "diagram": {
    "title": "...",
    "layers": [...],
    "relationships": [...]
  }
}
\`\`\`

## Notes
- Merged X into Y for clarity
```

#### Review & Iterate

**IMPORTANT:** Claude will stop and ask for your approval before proceeding.

Common feedback scenarios:

| Issue | Example Feedback |
|-------|------------------|
| Wrong language mix | "Change layer names to Chinese, keep tech terms in English" |
| Too many/few layers | "Merge Tool Layer into Infrastructure Layer" |
| Missing components | "Add Redis Cache to Infrastructure Layer" |
| Wrong relationships | "Change A→B from 'calls' to 'depends-on'" |

**Batch feedback example:**
```
Please modify:
1. Rename "Access Layer" → "访问层"
2. Move TaskScheduler to Foundation Layer
3. Add relationship: All Agents → LLM Gateway (uses)
4. Remove NetworkWrapper component
```

Say **"approved"** or **"go"** when satisfied.

---

### Step 2: Select Diagram Style

Choose from 8 preset styles:

| Style | Description |
|-------|-------------|
| `minimalist` | Clean, professional building blocks (Recommended) |
| `modern-colorful` | Vibrant gradients and modern aesthetic |
| `dark-neon` | Dark mode with neon accents |
| `blueprint` | Technical blueprint with grid lines |
| `corporate` | Formal presentation style |
| `hand-drawn` | Sketch-like pencil texture |
| `isometric` | 3D isometric view |
| `glassmorphism` | Frosted glass effect |

Or describe a custom style: *"Use soft pastel colors with rounded corners"*

---

### Step 3: Review Generation Prompt

Claude shows you the exact prompt that will be sent to Gemini.

**Critical:** The prompt MUST include the raw JSON, not a text summary.

**Correct prompt format:**
```
Generate a minimalist style and professional building block diagram.

\`\`\`json
{
  "diagram": {
    "title": "...",
    "layers": [/* FULL JSON HERE */],
    "relationships": [/* FULL RELATIONSHIPS */]
  }
}
\`\`\`

--aspect_ratio 3:4
```

Review and say **"approved"** or **"go"** to proceed.

---

### Step 4: Generate Diagram

Claude calls the Gemini API to generate the diagram.

**Output:** PNG image saved to `/Docs/architecture/{project-name}-arch-final.png`

#### Review Options

| Option | Action |
|--------|--------|
| **Regenerate** | Try again with same settings |
| **Change Style** | Go back to Step 2 |
| **Modify Prompt** | Go back to Step 3 |
| **Iterate** | Provide specific feedback for refinement |
| **Accept** | Finalize and cleanup |

When you accept, the temporary markdown file is deleted, keeping only the final diagram.

---

### Step 5: Save Style Preset (Optional)

If you created a custom style you like, save it for future use:

```
Save this style as "team-standard" preset
```

---

## Tips & Best Practices

### JSON Quality

1. **Keep layers to 3-4 max** - Too many layers create cluttered diagrams
2. **Limit nesting to 4 levels** - Deeper nesting gets hard to visualize
3. **5-8 components per layer** - Maintains visual clarity

### Naming Conventions

- **Chinese diagrams:** Use Chinese for display names, English for tech terms
  - ✅ "访问层" with "Next.js"
  - ❌ "Access Layer" mixed with "前端框架"
- **IDs:** Always use kebab-case (`task-scheduler`, `workflow-parser`)

### Iteration Strategy

**For small changes:** List all modifications in one message
```
1. Rename X to Y
2. Add component Z
3. Fix relationship A→B
```

**For major restructuring:** Iterate progressively
```
Round 1: Adjust layer structure
Round 2: Optimize component naming
Round 3: Add missing components
Round 4: Fix relationships
```

### Style Transfer

If you have a reference image with a style you like:
```
Generate architecture diagram matching the style of [attached image]:
[JSON here]
```

---

## Troubleshooting

### "API key not set"

```bash
# Check if key is set
echo $GEMINI_API_KEY

# Set it
export GEMINI_API_KEY="your-key-here"
```

### "Model not found"

The skill uses `gemini-2.0-flash-exp-image-generation`. Ensure your API key has access to this model.

### Generated diagram is wrong

1. **JSON issue:** The prompt might have summarized text instead of raw JSON
   - Solution: Ask Claude to show the full prompt, verify JSON is included

2. **Structure too complex:** Too many layers or deep nesting
   - Solution: Simplify to 3-4 layers, max 4 nesting levels

3. **Style mismatch:** Wrong style selected
   - Solution: Try a different preset or describe custom style

### Diagram generation fails

Try the alternative method:
1. Copy the generation prompt from Step 3
2. Go to [Crate](https://crate.tiktok-row.net)
3. Paste prompt and select Nano Banana Pro model
4. Generate manually

---

## Example Session

```
User: Generate architecture diagram for the AIGC workflow engine

Claude: [Analyzes codebase, generates JSON]
        Here's the architecture with 4 layers, 22 components...

        Saved to: /Docs/architecture/aigc-arch.md

        Please review. Any changes needed?

User: Move TaskScheduler to Foundation Layer, remove NetworkWrapper

Claude: [Updates JSON]
        Updated! Ready to proceed?

User: approved

Claude: Select a style:
        1. minimalist (Recommended)
        2. modern-colorful
        ...

User: minimalist

Claude: Here's the generation prompt:
        [Shows full prompt with JSON]

        Approve to generate?

User: go

Claude: [Generates diagram]

        Saved to: /Docs/architecture/aigc-arch-final.png

        Does this look good?

User: yes, accept

Claude: Done! Cleaned up temporary files.
        Final diagram: /Docs/architecture/aigc-arch-final.png
```

---

## Reference

- [SKILL.md](./SKILL.md) - Full skill specification
- [json-schema.md](./assets/json-schema.md) - JSON schema reference
- [style-presets.json](./references/style-presets.json) - Style definitions
- [ByteTech Article](https://bytetech.info/articles/7585160219522105395) - Original workflow guide
