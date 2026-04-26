#!/bin/bash
# work-capture.sh — PostToolUse hook on Bash|Write|Edit
# Detects work artifacts and appends timestamped lines to today.md.
# V1.0 (2026-04-25): adds 5-min dedup cache, project-tag derivation, AUTO fence.

VAULT="/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain"
TODAY_FILE="$VAULT/Areas/Career/work-log/today.md"
SESSION_MARKER="/tmp/.claude-work-captured"
DEDUP_FILE="/tmp/.work-capture-dedup-$(date +%Y%m%d)"
DEDUP_WINDOW=300  # seconds; collapse same-artifact writes inside this window

STDIN_PAYLOAD=""
if [ ! -t 0 ]; then
  STDIN_PAYLOAD=$(cat)
fi
PAYLOAD="${STDIN_PAYLOAD:-$CLAUDE_TOOL_INPUT}"

if command -v jq >/dev/null 2>&1 && [ -n "$STDIN_PAYLOAD" ]; then
  TOOL_NAME=$(echo "$PAYLOAD" | jq -r '.tool_name // empty' 2>/dev/null)
  CMD=$(echo "$PAYLOAD" | jq -r '.tool_input.command // empty' 2>/dev/null)
  FPATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
  CWD=$(echo "$PAYLOAD" | jq -r '.cwd // empty' 2>/dev/null)
else
  TOOL_NAME=""
  CMD="$PAYLOAD"
  FPATH=$(echo "$PAYLOAD" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
  CWD=""
fi

# Skip writes to today.md / weeks/ to avoid recursion
case "$FPATH$CMD" in
  *"work-log/today.md"*) exit 0 ;;
  *"work-log/weeks/"*)   exit 0 ;;
esac

# Derive #project/X tag from a vault path or repo cwd. Echoes leading space + tag, or empty.
derive_tag() {
  local p="$1"
  case "$p" in
    *"second-brain/Projects/AIGC"*)                   echo " #project/loki" ;;
    *"second-brain/Projects/personal/hot-stuff"*)     echo " #project/hot-stuff" ;;
    *"second-brain/Projects/personal/polyglot-tutor"*) echo " #project/polyglot-tutor" ;;
    *"second-brain/Projects/personal/ace-buddy"*)     echo " #project/ace-buddy" ;;
    *"second-brain/Areas/dev-workflow"*)              echo " #tooling" ;;
    *"second-brain/Areas/Career"*)                    echo " #project/career-prep" ;;
    *"second-brain/Self"*)                            echo " #personal" ;;
    */loki_web_integrations*)                         echo " #project/loki" ;;
    */TikTok*)                                        echo " #project/tiktok-ios" ;;
    */hot-stuff*)                                     echo " #project/hot-stuff" ;;
    */polyglot-tutor*)                                echo " #project/polyglot-tutor" ;;
    *) echo "" ;;
  esac
}

LINE=""
DEDUP_KEY=""

# 1. Git commit — derive tag from CWD
if [ -n "$CMD" ] && echo "$CMD" | grep -q "git commit"; then
  sleep 0.2
  if [ -n "$CWD" ] && [ -d "$CWD" ]; then
    HASH=$(git -C "$CWD" log --oneline -1 2>/dev/null | cut -c1-7)
    MSG=$(git -C "$CWD" log --oneline -1 2>/dev/null | cut -c9-80)
    TAG=$(derive_tag "$CWD")
  else
    HASH=$(git log --oneline -1 2>/dev/null | cut -c1-7)
    MSG=$(git log --oneline -1 2>/dev/null | cut -c9-80)
    TAG=""
  fi
  if [ -n "$HASH" ]; then
    LINE="- $(date +%H:%M) Commit ${HASH}: ${MSG}${TAG}"
    DEDUP_KEY="commit:${HASH}"
  fi
fi

# 2. Lark doc creation
if [ -z "$LINE" ] && [ -n "$CMD" ]; then
  if echo "$CMD" | grep -q "lark-cli docs +create\|lark-cli docx +create"; then
    LINE="- $(date +%H:%M) Created Lark document"
  fi
fi

# 3. Vault doc Write/Edit
if [ -z "$LINE" ] && [ -n "$FPATH" ]; then
  case "$FPATH" in
    *"second-brain/Projects"*|*"second-brain/Areas"*|*"second-brain/Self"*)
      BASENAME=$(basename "$FPATH" .md)
      TAG=$(derive_tag "$FPATH")
      LINE="- $(date +%H:%M) Wrote [[${BASENAME}]]${TAG}"
      DEDUP_KEY="doc:${BASENAME}"
      ;;
  esac
fi

[ -z "$LINE" ] && exit 0

# Dedup: skip if same key written within window (file-based, day-scoped, auto-rotates)
if [ -n "$DEDUP_KEY" ]; then
  NOW_EPOCH=$(date +%s)
  LAST_EPOCH=$(grep -F "${DEDUP_KEY}=" "$DEDUP_FILE" 2>/dev/null | tail -1 | cut -d= -f2)
  if [ -n "$LAST_EPOCH" ] && [ $((NOW_EPOCH - LAST_EPOCH)) -lt $DEDUP_WINDOW ]; then
    exit 0
  fi
  echo "${DEDUP_KEY}=${NOW_EPOCH}" >> "$DEDUP_FILE"
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

TODAY=$(date +%Y-%m-%d)
DAY=$(date +%a)
HEADER="### ${TODAY} ${DAY}"
END_MARKER="<!-- END AUTO ${TODAY} -->"
BEGIN_MARKER="<!-- AUTO ${TODAY} (managed by work-capture.sh; manual items belong outside this fence) -->"

# Add today's day section (with AUTO fence) if missing
if ! grep -qF "$HEADER" "$TODAY_FILE"; then
  printf '\n%s\n%s\n%s\n' "$HEADER" "$BEGIN_MARKER" "$END_MARKER" >> "$TODAY_FILE"
fi

# Insert LINE inside today's AUTO fence if present, else fall back to plain append
if grep -qF "$END_MARKER" "$TODAY_FILE"; then
  TMP=$(mktemp)
  awk -v end="$END_MARKER" -v line="$LINE" '
    !inserted && index($0, end) {
      print line
      inserted=1
    }
    { print }
  ' "$TODAY_FILE" > "$TMP" && mv "$TMP" "$TODAY_FILE"
else
  echo "$LINE" >> "$TODAY_FILE"
fi

touch "$SESSION_MARKER"
