---
name: uml-diagram-generator
description: Generate editable Mermaid UML diagrams from code repositories or documentation. Multi-step workflow that extracts architecture, generates structured JSON, and produces Mermaid diagram code (component, class, sequence, activity, state, package, deployment) that users can modify as plain text. This skill should be used when the user asks for UML diagrams, Mermaid diagrams, editable architecture diagrams, or wants to visualize system structure in a text-based format.
---

# UML Diagram Generator

## Purpose

Transform code repositories or documentation into **editable Mermaid UML diagrams** using a structured multi-step workflow with human review at each stage. Unlike image-based diagram generators, this skill outputs plain-text Mermaid code that users can freely modify, version-control, and render in GitHub, GitLab, VS Code, or any Mermaid-compatible tool.

## Triggers

Activate this skill when:
- User wants to generate UML diagrams from code
- User wants editable/text-based architecture diagrams
- User asks for "UML diagram", "Mermaid diagram", "class diagram", "sequence diagram"
- User wants diagrams they can modify and commit to git
- User references this workflow for generating Mermaid output

## Supported Diagram Types

| Type | Mermaid Syntax | Best For |
|------|---------------|----------|
| **Component** | `flowchart TD` | System architecture overview |
| **Class** | `classDiagram` | Object model, API surface |
| **Sequence** | `sequenceDiagram` | Request flows, interactions |
| **Activity** | `flowchart TD` | Business logic, workflows |
| **State** | `stateDiagram-v2` | Lifecycle management |
| **Package** | `flowchart TD` with subgraphs | Module organization |
| **Deployment** | `flowchart TD` with subgraphs | Infrastructure layout |

## Input Sources

- **Code Repository**: Analyze the codebase directly
- **Documentation**: Lark docs, markdown files, or PRD documents

## Workflow

### Step 1: Extract Architecture JSON

**Objective**: Generate structured JSON representation of the architecture.

Analyze the codebase or documentation and extract architecture into the intermediate JSON format. Refer to `references/json-schema.md` for the full schema.

```markdown
# Task: Extract Architecture to JSON

Analyze the current project. Generate a structured JSON representation of the architecture.

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
            "methods": ["string array (optional) - for class diagrams"],
            "properties": ["string array (optional) - for class diagrams"],
            "contains": [/* nested components - MAX 3-4 LEVELS */]
          }
        ]
      }
    ],
    "relationships": [
      {
        "from": "component-id",
        "to": "component-id",
        "type": "calls | uses | depends-on | integrates-with | supports | implements | extends",
        "label": "string (optional) - edge label"
      }
    ],
    "sequences": [
      {
        "id": "string",
        "title": "string",
        "actors": ["string array"],
        "steps": [
          {
            "from": "string",
            "to": "string",
            "message": "string",
            "type": "sync | async | reply | note",
            "activate": true
          }
        ]
      }
    ],
    "states": [
      {
        "id": "string",
        "title": "string",
        "states": ["string array"],
        "transitions": [
          {
            "from": "string",
            "to": "string",
            "trigger": "string"
          }
        ]
      }
    ]
  }
}
```

## Extraction Rules

1. **Identify Layers** — Group components into horizontal layers (level 1 = top).
2. **Extract Components** — Name, type, module path, dependencies. Max 3-4 nesting levels.
3. **Identify Relationships** — Arrows, data flow, API calls, dependency directions.
4. **Extract Sequences** (optional) — Key request flows through the system.
5. **Extract States** (optional) — Lifecycle states for key entities.
6. **Class Details** (optional) — Methods and properties for class diagrams.
```

#### Output Architecture File (MANDATORY)

Save the generated JSON to a markdown file for user review:

```
Docs/uml/{project-name}-arch.md
```

**File format:**
```markdown
# {Project Name} Architecture

## Summary
- **Layers**: {count}
- **Components**: {count}
- **Relationships**: {count}
- **Sequences**: {count} (if any)
- **States**: {count} (if any)

## Architecture JSON

```json
{ ... }
```

## Notes
- [Any simplifications or decisions made during extraction]
```

Tell the user:
1. Markdown file location
2. They can edit the JSON directly in their editor
3. After editing, ask Claude to reload and continue

#### Human Review Point (MANDATORY)

**STOP HERE. Do NOT proceed to Step 2 until user explicitly approves the JSON.**

Present the JSON with a visual summary. Offer common optimization scenarios:

- **Language**: Standardize naming (Chinese display names, English technical terms)
- **Layers**: Merge or split layers for appropriate granularity
- **Missing components**: Add overlooked modules or services
- **Relationships**: Correct direction, type, or add missing connections
- **Sequences/States**: Add key flows or lifecycle states

**Wait for explicit "approved" or "go" before proceeding.**

### Step 2: Select Diagram Types

**Objective**: Choose which UML diagram types to generate.

Present the available diagram types from `references/diagram-types.md`:

```
Available diagram types:

Structural:
  1. component  - System architecture overview (Recommended)
  2. class      - Object model with methods/properties
  3. package    - Module organization with subgraphs
  4. deployment - Infrastructure and deployment layout

Behavioral:
  5. sequence   - Request flows and interactions
  6. activity   - Business logic and workflow steps
  7. state      - Entity lifecycle states

[a] All structural     - Generate all 4 structural diagrams
[b] All behavioral     - Generate all 3 behavioral diagrams
[c] All                - Generate everything
```

Ask user to select one or more types (comma-separated numbers or letters).

### Step 3: Generate Mermaid Code

**Objective**: Convert the approved JSON into Mermaid diagram code.

For each selected diagram type, generate Mermaid syntax following the conversion rules in `references/mermaid-patterns.md`.

#### Generation Rules

**Component Diagram** (`flowchart TD`):
- Each layer becomes a `subgraph`
- Components become nodes with shape based on type
- Relationships become labeled arrows
- Use consistent styling with `classDef`

**Class Diagram** (`classDiagram`):
- Components with `methods`/`properties` become classes
- Relationship types map to UML arrows (`<|--`, `*--`, `o--`, `-->`, `..>`)
- Group related classes in namespaces when > 10 classes

**Sequence Diagram** (`sequenceDiagram`):
- Each sequence from JSON becomes a separate diagram
- `sync` = solid arrow, `async` = dashed arrow, `reply` = dashed return
- Use `activate`/`deactivate` for long operations

**Activity Diagram** (`flowchart TD`):
- Decision points use `{condition}`
- Parallel activities use `fork`/`join` subgraphs
- Start/end use rounded nodes

**State Diagram** (`stateDiagram-v2`):
- States from JSON become state nodes
- Transitions become arrows with trigger labels
- Use `[*]` for initial/final states

**Package Diagram** (`flowchart TD` with subgraphs):
- Layers become nested subgraphs
- `contains` arrays become nested subgraphs
- Dependency arrows between packages

**Deployment Diagram** (`flowchart TD` with subgraphs):
- Infrastructure layers become subgraphs styled as nodes/servers
- Components placed inside their deployment targets

#### Output File (MANDATORY)

Save each diagram to its own `.mmd` file AND a combined markdown file:

```
Docs/uml/{project-name}-component.mmd
Docs/uml/{project-name}-class.mmd
Docs/uml/{project-name}-sequence.mmd
... (one per selected type)

Docs/uml/{project-name}-diagrams.md    (combined, for easy viewing)
```

**Combined markdown format:**

    # {Project Name} UML Diagrams

    Generated: {date}

    ## Component Diagram

    ```mermaid
    flowchart TD
      subgraph layer1["Access Layer"]
        ...
      end
    ```

    ## Class Diagram

    ```mermaid
    classDiagram
      class MyClass {
        ...
      }
    ```

#### Human Review Point (MANDATORY)

Present all generated diagrams and tell the user:
1. Individual `.mmd` files can be edited with any text editor
2. The combined `.md` file renders in GitHub/GitLab preview
3. VS Code with "Mermaid Preview" extension renders `.mmd` files live

**Options:**
- **Edit**: User modifies `.mmd` files directly, asks Claude to reload
- **Regenerate**: Regenerate specific diagram types
- **Refine**: Provide feedback for Claude to adjust
- **Accept**: Finalize output

### Step 4: Finalize

**Objective**: Clean up and confirm final output.

When user accepts:
1. Delete the temporary architecture JSON markdown file from Step 1
2. Confirm final output locations of all `.mmd` and `.md` files
3. Print rendering instructions

```
Output files:
  Docs/uml/{project-name}-component.mmd
  Docs/uml/{project-name}-class.mmd
  Docs/uml/{project-name}-diagrams.md (combined)

Rendering:
  - GitHub/GitLab: Push the .md file — mermaid blocks render automatically
  - VS Code: Install "Mermaid Preview" extension, open .mmd files
  - CLI: npx @mermaid-js/mermaid-cli mmdc -i file.mmd -o file.svg
  - Online: Paste into https://mermaid.live
```

## Output Locations

- **Architecture JSON (temporary)**: `Docs/uml/{project-name}-arch.md` — Deleted after user accepts
- **Individual diagrams**: `Docs/uml/{project-name}-{type}.mmd` — Kept permanently
- **Combined markdown**: `Docs/uml/{project-name}-diagrams.md` — Kept permanently

## Tips for Best Results

1. **JSON Quality Matters**: Invest time in refining the architecture JSON — it drives all diagrams
2. **Start Structural, Add Behavioral**: Generate component diagram first, then add sequences/states
3. **Edit the `.mmd` Files**: The whole point is editability — modify freely
4. **Keep It Readable**: Limit to 15-20 nodes per diagram; split large systems into sub-diagrams
5. **Use Subgraphs**: Group related components for visual clarity
6. **Version Control**: Commit `.mmd` files alongside code for living documentation

## Resources

- `references/api_reference.md` — Full architecture JSON schema
- `references/diagram-types.md` — Supported diagram types with examples
- `references/mermaid-patterns.md` — Mermaid syntax patterns and conversion rules
