---
name: obsidian-daily
description: AI-assisted daily journaling with CBT reframing — 写/镜/做
user_invocable: true
---

# /obsidian-daily — Daily Journal

**Purpose**: AI-assisted daily journaling using the 写/镜/做 (Write/Mirror/Do) framework.

## Usage

- `/obsidian-daily <your thoughts>` — Create/append to today's note with AI reflection
- `/obsidian-daily` — Open today's note, review and reflect
- `/obsidian-daily morning` — Morning intention setting
- `/obsidian-daily reframe` — Force CBT reframe on today's entry

## File Location

`Self/YYYY-MM-DD-daily.md` in the vault at:
`/Users/bytedance/Library/Mobile Documents/com~apple~CloudDocs/second-brain-docs/`

## The 写/镜/做 Framework

### 写 (Write) — Human voice, unstructured
- Stream of consciousness. No rules, no structure.
- Mixed Chinese/English is natural and expected.
- AI does light grammar/typo cleanup only. Never rewrites meaning or voice.

### 镜 (Mirror) — AI voice, always in *italics*
- Reflects patterns, links to past entries, asks Socratic questions.
- **Trigger-based CBT reframe**: When 写 section contains strong negative emotions (anxiety, anger, self-blame, shame, despair), automatically include a CBT reframe block.
- On lighter days, just do pattern-linking and one question.

### 做 (Do) — Action items
- Carry forward from yesterday's incomplete tasks.
- Add new items surfaced during reflection.
- Keep to 1-3 items max. Less is more.

## Template

```markdown
---
type: reflection
status: seed
src: original
topic: [daily]
date: "{{date}}"
mood: /5
energy: /5
---

# {{date}}

## 写 (Write)


## 镜 (Mirror)


## 做 (Do)
- [ ]
```

## AI Behavior

### 1. Light touch-up on 写 section (always)
- Fix obvious grammar, typos, and punctuation
- Clean up sentence flow without changing meaning or voice
- Preserve the user's original language (Chinese, English, or mixed)
- **Never** rewrite emotional content. If they wrote it raw, keep it raw.

### 2. Generate 镜 section (always)

**All text in 镜 MUST be italic** (`*text*`).

**Default mode** (neutral/positive day):
```markdown
## 镜 (Mirror)
*连续第三天提到"全栈"——看起来这个方向的pull越来越强了。[[2026-01-12]] 里你写过类似的想法。*
*今天的能量比昨天高，有什么不同？*
```

**CBT reframe mode** (triggered by strong negative emotions):
```markdown
## 镜 (Mirror)
*触发: [what happened — extracted from 写]*
*自动思维: [the automatic negative thought]*
*认知偏差: [which distortion — e.g., 全有全无, 灾难化, 读心术, 应该思维]*
*换个角度: [reframed perspective — brief, concrete, not dismissive]*
*问自己: [one Socratic question, link to relevant past entry if applicable]*
```

**CBT distortion detection keywords**:
- 全有全无 (all-or-nothing): "总是", "永远", "从来", "always", "never", "又回到了"
- 灾难化 (catastrophizing): "完了", "毁了", "不可能", "panic", "the worst"
- 读心术 (mind-reading): "他们觉得", "别人肯定", "老板一定", "they think"
- 应该思维 (should statements): "我应该", "我该", "should", "must", "凭什么"
- 贴标签 (labeling): "我就是个", "我太", "I'm such a", "I'm so"

### 3. Populate 做 section
- Check yesterday's note for incomplete `- [ ]` items → carry forward
- Add 1-2 concrete items from the reflection (if applicable)
- Never more than 3 items total

### 4. Mood/Energy estimation
- If user doesn't specify, estimate from content and note in frontmatter
- Use the 写 section's emotional tone as signal

## Workflow

### When user provides content:
1. Read today's note (create if missing, using template from `99-System/Templates/daily-template.md`)
2. Read yesterday's note for carry-forward tasks and pattern continuity
3. Read any `[[wikilinked]]` past entries referenced in user's content
4. Write 写 section (user's words, lightly cleaned)
5. Generate 镜 section (detect emotion level → choose default or CBT mode)
6. Populate 做 section
7. Set mood/energy in frontmatter

### When user runs `/obsidian-daily` with no content:
1. Open today's note
2. If 写 is empty, ask: "今天怎么样？" (keep it simple)
3. If 写 has content but no 镜, generate the Mirror section

### Morning mode (`/obsidian-daily morning`):
1. Read yesterday's note → summarize in 1 italic line
2. Carry forward incomplete tasks to 做
3. Ask: "今天最重要的一件事是什么？"

## Obsidian CLI / MCP Integration (when available)

If the Obsidian MCP server or CLI is configured:
- Use `obsidian_read_note` / `obsidian_update_note` instead of file Read/Write
- Use `obsidian_global_search` to find related past entries (better than grep)
- Use `obsidian_manage_frontmatter` to update mood/energy metadata
- Append to live notes instead of overwriting

If MCP is not available, fall back to direct file Read/Write (always works).

## Rules

- One daily note per day — append if exists, don't overwrite
- **Human text = normal**, **AI text = italics** — strict separation
- Link to past entries with `[[wikilinks]]` when patterns recur
- Tone: warm, non-judgmental, curious. Never preachy or therapist-y.
- CBT reframes should validate the feeling first, then offer perspective
- Keep 镜 short — 3-5 italic lines max. Less is more.
- Respect the user's language choice — if they write in Chinese, reflect in Chinese
