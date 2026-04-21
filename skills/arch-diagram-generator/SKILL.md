---
name: arch-diagram-generator
description: Generate professional architecture diagrams using AI. Multi-step workflow that extracts architecture from code/docs, generates structured JSON, and creates diagrams via Gemini API with customizable styles.
---

# Architecture Diagram Generator

## Purpose

Transform code repositories or documentation into professional architecture diagrams using a structured multi-step workflow with human review at each stage.

## Triggers

Activate this skill when:
- User wants to generate architecture diagrams from code
- User wants to visualize system architecture from documentation
- User asks for "architecture diagram", "system diagram", or "draw architecture"
- User references this workflow or the ByteTech article method

## Prerequisites

### Gemini API Access
API key is pre-configured. Set environment variable if needed:
```bash
export GEMINI_API_KEY="AIzaSyBN3_CqrfTUAS6VBoDXyNvPTgF_-32fV4w"
```

### Helper Script
Use the included script for easy generation:
```bash
~/.agents/skills/arch-diagram-generator/scripts/generate-diagram.sh <json_file> [style] [output_file]
```

### Input Sources
- **Code Repository**: Claude Code can analyze the codebase directly
- **Documentation**: Lark docs, markdown files, or PRD documents

## Workflow

### Step 1: Extract Architecture JSON

**Objective**: Generate structured JSON representation of the architecture.

#### For Code Repositories or Documentation:
Use the following prompt to analyze the codebase:

```markdown
# Task: Extract Architecture Diagram to JSON

Please carefully analyze the current project. Based on your deep research, generate a detailed architecture diagram.

## Expected JSON Structure
```json
{
  "diagram": {
    "title": "string",
    "layers": [
      {
        "id": "string",
        "name": "string",
        "level": number,
        "components": [
          {
            "id": "string",
            "name": "string",
            "type": "string",
            "module": "string (optional)",
            "provider": "string (optional)",
            "dependencies": ["string array (optional)"],
            "contains": [/* nested components - MAX 3-4 LEVELS */]
          }
        ]
      }
    ],
    "relationships": [
      {
        "from": "component-id",
        "to": "component-id",
        "type": "calls | uses | depends-on | integrates-with | supports"
      }
    ]
  }
}
```

## Extraction Rules

1. **Identify Layers (Horizontal Sections)**
   - Look for dashed boxes that group components horizontally
   - Each layer has a name (usually on the left with an icon)
   - Assign level: 1 (top) → 2 (middle) → 3 (bottom)

2. **Extract Components**
   - Component name: Bold text inside boxes
   - Component type: Text in parentheses below name (e.g., "ui-module", "framework")
   - For nested components (like Tools containing multiple tools), use the `contains` array
   - **IMPORTANT: Maximum nesting depth is 3-4 levels**
   - Generate kebab-case IDs from component names

3. **Nesting Structure Guidelines**
   - Level 1: Layer (e.g., "Console UI", "Agentic System")
   - Level 2: Major component (e.g., "Components", "Tools")
   - Level 3: Sub-component (e.g., "File System Toolset", "Text Editor Tool")
   - Level 4 (if needed): Detailed sub-item (e.g., specific tool functions)
   - **Stop at level 4 - do not nest deeper**

4. **Identify Relationships**
   - Arrows between components indicate relationships
   - Bidirectional arrows (↔) = "integrates-with"
   - Downward arrows (↓) = "depends-on"
   - Arrows pointing to specific components = "calls" or "uses"

5. **Special Cases**
   - If a component contains a list of items (like "Tools" containing "File System Toolset", "Text Editor Tool", etc.), put them in the `contains` array
   - Keep the exact naming from the diagram
   - For module names in parentheses, add them as a `module` field
   - If you encounter deeper nesting in the diagram, flatten it to maximum 4 levels

## Example Nesting
```json
{
  "layers": [                           // Level 1
    {
      "components": [                   // Level 2
        {
          "id": "tools",
          "name": "Tools",
          "contains": [                 // Level 3
            {
              "id": "filesystem-tool",
              "name": "File System Toolset",
              "contains": [             // Level 4 (MAX)
                {
                  "id": "read-file",
                  "name": "Read File"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## Output

Please provide:
1. The complete JSON structure (respecting max 3-4 level nesting)
2. Reference documents are under `doc` folder and README.md if exists
3. A brief summary of:
   - Layer count
   - Component count
   - Maximum nesting depth used
   - Relationship count
4. If you had to flatten any structure, mention what was simplified
```

#### For Lark Documentation:
Use `lark_docs` MCP to fetch Lark documents, then apply the same extraction prompt above.

#### Output Architecture File (MANDATORY)

**Always save the generated JSON to a markdown file for user review and editing:**

```bash
# Save to project's Docs/architecture/ folder
/path/to/project/Docs/architecture/{project-name}-arch.md
```

**File format:**
```markdown
# {Project Name} Architecture

## Summary
- **Layers**: {count}
- **Components**: {count}
- **Relationships**: {count}

## Architecture JSON

```json
{
  "diagram": {
    ...
  }
}
```

## Notes
- [Any simplifications or decisions made during extraction]
```

Tell the user:
1. Markdown file location
2. They can open and edit the file directly in their editor
3. The JSON block inside can be modified
4. After editing, ask Claude to reload and continue

#### Human Review Point (MANDATORY)

**STOP HERE. Do NOT proceed to Step 2 until user explicitly approves the JSON.**

Present the generated JSON to the user with a visual summary, then guide review using the templates below.

---

#### 常见的优化场景 (Common Optimization Scenarios)

**场景 1：语言混用问题**
```
修改要求：
- 将所有非专有名词（如 layer, component）改为中文
- 保留技术栈名称为英文（如 Next.js, FastAPI）
- 组件类型保持英文（frontend-app, backend-api）便于后续处理
```

**场景 2：层级过深或过浅**
```
修改要求：
- 当前有 4 层，太多了，将"工具层"合并到"基础设施层"
- 或：当前只有 2 层，太粗糙，将"业务层"拆分为"编排层"和"执行层"
```

**场景 3：遗漏关键组件**
```
修改要求：
- 添加 `src/middleware/` 目录中的"认证中间件"组件
- 补充"消息队列"组件，它连接"API 层"和"Worker 层"
- 添加"监控告警"模块到"基础设施层"
```

**场景 4：关系不准确**
```
修改要求：
- "Web UI" 和 "API Server" 应该是双向集成关系（integrates-with），不是单向调用
- "研究员 Agent" 应该依赖（depends-on）"搜索工具"，而不是调用（calls）
- 补充"LLM Gateway"与所有 Agent 的关系
```

---

#### 迭代技巧 (Iteration Tips)

**一次性列出所有修改（推荐方式）：**
```
请按照以下要求修改 JSON：

1. 语言规范：
   - 层级名称改为中文："Access Layer" → "访问层"
   - 组件名称改为中文："Coordinator" → "协调器"
   - 保留技术栈英文：Next.js, FastAPI 等

2. 结构调整：
   - 合并"搜索工具"和"数据工具"到统一的"工具集"组件
   - 将"监控模块"从"业务层"移到"基础设施层"

3. 补充内容：
   - 在"基础设施层"添加"Redis 缓存"组件（module: src/cache/）
   - 添加"配置中心"组件（provider: Consul）

4. 关系修正：
   - "API Server" → "Coordinator" 改为 depends-on
   - 补充"所有 Agent" → "LLM Gateway" 的 uses 关系
```

**渐进式修改（如果改动较大）：**
```
第一轮：先调整层级结构
第二轮：优化组件命名和类型
第三轮：补充遗漏的组件
第四轮：修正关系
```

---

**Wait for explicit "approved" or "go" before proceeding.**

### Step 2: Select Diagram Style

**Objective**: Choose a visual style for the diagram.

Present available style presets from `references/style-presets.json`:

```
Available styles:
1. minimalist - Clean, professional building blocks (Recommended)
2. modern-colorful - Vibrant, modern aesthetic
3. dark-neon - Dark mode with neon accents
4. blueprint - Technical blueprint drawing
5. corporate - Formal presentation style
6. hand-drawn - Sketch-like appearance
7. [Custom] - Describe your own style
```

Ask user to select a style or describe a custom one.

### Step 3: Review Generation Prompt (MANDATORY)

**Objective**: Review and approve the prompt before sending to Nano Banana Pro (Gemini).

**STOP HERE. Do NOT proceed to Step 4 until user explicitly approves the prompt.**

#### Generation Prompt Template

**CRITICAL: The prompt MUST include the raw JSON. This is essential for accurate diagram generation.**

```
Generate a [STYLE] building block diagram.

```json
[RAW_ARCHITECTURE_JSON - MUST BE INCLUDED IN FULL]
```

--aspect_ratio 3:4
```

#### Style Options

| Style | Prompt Text |
|-------|-------------|
| minimalist | `minimalist style and professional building block diagram` |
| modern-colorful | `modern and colorful architecture diagram with gradient backgrounds` |
| dark-neon | `dark mode with neon accents technical architecture diagram` |
| blueprint | `blueprint technical drawing style architecture diagram with grid lines` |
| corporate | `corporate presentation style architecture diagram, clean and formal` |
| hand-drawn | `hand-drawn sketch style architecture diagram with pencil texture` |

#### Constructed Prompt Preview

Present the FULL prompt to the user, including:
1. Style description
2. Complete raw JSON (not summarized)
3. Aspect ratio

Example:
```
Generate a minimalist style and professional building block diagram.

```json
{
  "diagram": {
    "title": "AIGC Workflow Engine Architecture",
    "layers": [
      ...FULL JSON HERE...
    ],
    "relationships": [
      ...FULL RELATIONSHIPS HERE...
    ]
  }
}
```

--aspect_ratio 3:4
```

#### Human Review Point (MANDATORY)

Present the constructed prompt to the user and ask:
1. Is the full JSON included? (CRITICAL)
2. Is the style correct?
3. Any modifications to the prompt?

**Wait for explicit "approved" or "go" before proceeding to Step 4.**

### Step 4: Generate Diagram

**Objective**: Create the architecture diagram using Gemini API.

#### API Call via Gemini

Execute the following command to generate the diagram:

```bash
# Ensure API key is set
export GEMINI_API_KEY="${GEMINI_API_KEY:-AIzaSyBN3_CqrfTUAS6VBoDXyNvPTgF_-32fV4w}"

# Generate diagram (prompt saved to temp file for readability)
~/.agents/skills/arch-diagram-generator/scripts/generate-diagram.sh <json_file> "<style>" <output_file>
```

#### Alternative: Crate (TikTok Internal)
1. Open https://crate.tiktok-row.net
2. Paste the generation prompt from Step 3
3. Select Nano Banana Pro / Seedream 4.5 model

#### Human Review Point
Present the generated diagram and ask:
- Does this match your expectations?
- Would you like to try a different style?
- Any specific elements to adjust?

Options:
- **Regenerate**: Try again with same settings
- **Change Style**: Go back to Step 2
- **Modify Prompt**: Go back to Step 3
- **Iterate**: Provide specific feedback for refinement
- **Accept**: Cleanup and proceed to optional Step 5

#### Cleanup on Accept

When user accepts the final diagram:
1. Delete the temporary markdown file created in Step 1
2. Confirm final output location of the diagram
3. Optionally proceed to Step 5 (Save Style Preset)

```bash
# Cleanup command
rm /path/to/project/Docs/architecture/{project-name}-arch.md
```

### Step 5: Save Style Preset (Optional)

**Objective**: Store successful styles for future use.

If user created a custom style or modified an existing one:

```
Would you like to save this style as a preset?
- Style name: [user input]
- Style prompt: [the prompt used]
```

Update `references/style-presets.json` with the new preset.

## Style Transfer (Bonus)

If user provides a reference image:

```
Generate architecture diagram, try your best to keep the style consistency of [image 1]:

```json
[ARCHITECTURE JSON]
```
```

## Output Locations

- **Architecture markdown (temporary)**: `/Docs/architecture/{project-name}-arch.md` - Deleted after user accepts final diagram
- **Final diagram**: `/Docs/architecture/{project-name}-arch-final.png` - Kept permanently
- **Style presets**: `references/style-presets.json`

## Tips for Best Results

1. **JSON Quality Matters**: Spend time refining the JSON structure
2. **Keep Layers 3-4 Max**: Too many layers create cluttered diagrams
3. **Iterate Styles**: Don't settle on the first generation
4. **Use Reference Images**: Style transfer produces consistent results
5. **Chinese + English**: Mix languages for professional CN diagrams

## Example Output

```json
{
  "diagram": {
    "title": "DeerFlow Multi-Agent Research System Architecture",
    "layers": [
      {
        "id": "interface-layer",
        "name": "Access & Interface Layer",
        "level": 1,
        "components": [
          {
            "id": "web-ui",
            "name": "Web UI",
            "type": "frontend-app",
            "module": "web/"
          }
        ]
      }
    ]
  }
}
```

## Related Resources

- [ByteTech Article](https://bytetech.info/articles/7585160219522105395) - Original workflow guide
- [Crate](https://crate.tiktok-row.net) - TikTok's creative generation tool
- `assets/json-schema.md` - Full JSON schema reference
- `config/gemini-config.md` - API setup guide
