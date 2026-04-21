#!/bin/bash
# work-capture.sh — PostToolUse hook on Bash|Write|Edit
# Detects work artifacts and appends timestamped lines to today.md
# Signals: git commit, vault doc write, lark doc creation

VAULT="/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain"
TODAY_FILE="$VAULT/Areas/Career/work-log/today.md"
SESSION_MARKER="/tmp/.claude-work-captured"
INPUT="$CLAUDE_TOOL_INPUT"

# Skip writes to today.md itself (avoid recursion)
if echo "$INPUT" | grep -q "work-log/today\.md"; then
  exit 0
fi

# Skip writes to work-log/weeks/ (skill-managed files)
if echo "$INPUT" | grep -q "work-log/weeks/"; then
  exit 0
fi

LINE=""

# 1. Git commit detected in Bash command
if echo "$INPUT" | grep -q "git commit"; then
  # Wait briefly for git to finish
  sleep 0.2
  HASH=$(git log --oneline -1 2>/dev/null | cut -c1-7)
  MSG=$(git log --oneline -1 2>/dev/null | cut -c9-80)
  if [ -n "$HASH" ]; then
    LINE="- $(date +%H:%M) Commit ${HASH}: ${MSG}"
  fi
fi

# 2. Lark doc creation in Bash command
if [ -z "$LINE" ]; then
  if echo "$INPUT" | grep -q "lark-cli docs +create"; then
    LINE="- $(date +%H:%M) Created Lark document"
  fi
fi

# 3. Vault doc write (Write/Edit to Projects/ or Areas/, excluding work-log/)
if [ -z "$LINE" ]; then
  if echo "$INPUT" | grep -q "second-brain/Projects\|second-brain/Areas"; then
    FPATH=$(echo "$INPUT" | grep -oE '"file_path"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
    if [ -n "$FPATH" ]; then
      BASENAME=$(basename "$FPATH" .md)
      LINE="- $(date +%H:%M) Wrote [[${BASENAME}]]"
    fi
  fi
fi

# Nothing detected — exit silently
if [ -z "$LINE" ]; then
  exit 0
fi

# Ensure today.md exists
if [ ! -f "$TODAY_FILE" ]; then
  mkdir -p "$(dirname "$TODAY_FILE")"
  cat > "$TODAY_FILE" <<'TEMPLATE'
---
type: work-log
title: "Daily Scratch"
tags: [work-log, daily]
---

# Daily Scratch

> Append daily checklist items here. Cleared each Friday by `/work-log`.
TEMPLATE
fi

# Add today's date header if missing
TODAY=$(date +%Y-%m-%d)
DAY=$(date +%a)
HEADER="### ${TODAY} ${DAY}"

if ! grep -qF "$HEADER" "$TODAY_FILE"; then
  printf '\n%s\n' "$HEADER" >> "$TODAY_FILE"
fi

# Append the line
echo "$LINE" >> "$TODAY_FILE"

# Mark that work was captured this session
touch "$SESSION_MARKER"
