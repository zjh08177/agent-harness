#!/bin/bash
# Memory Gate — UserPromptSubmit hook
# Blocks processing if a memory update is pending (flag file exists).
# Flag is created by post-commit hook, removed by post-memory-update hook.

FLAG="/tmp/.claude-memory-pending"

if [ -f "$FLAG" ]; then
  # Auto-expire: if flag is older than 24 hours, clear it silently
  if [ "$(uname)" = "Darwin" ]; then
    FLAG_AGE=$(( $(date +%s) - $(stat -f %m "$FLAG") ))
  else
    FLAG_AGE=$(( $(date +%s) - $(stat -c %Y "$FLAG") ))
  fi
  if [ "$FLAG_AGE" -gt 86400 ]; then
    rm -f "$FLAG"
    exit 0
  fi

  COMMIT_INFO=$(cat "$FLAG")
  cat >&2 <<BLOCK
{"error": "Memory update required. A git commit was made without saving memory: $COMMIT_INFO. You MUST save a memory update BEFORE responding. Either: (1) Write a new auto-memory file to ~/.claude/projects/.../memory/ with a valuable insight, or (2) Call mcp__memory__add_observations. The flag clears automatically after either action. Only save non-obvious learnings — not session logs."}
BLOCK
  exit 2
fi
