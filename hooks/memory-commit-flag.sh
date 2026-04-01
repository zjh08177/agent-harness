#!/bin/bash
# Post-commit flag — PostToolUse hook on Bash
# Creates flag file when a git commit is detected.
# The flag blocks further processing until memory is updated.

FLAG="/tmp/.claude-memory-pending"

# Check if the Bash command was a git commit
# CLAUDE_TOOL_INPUT contains the command that was run
if echo "$CLAUDE_TOOL_INPUT" | grep -q "git commit"; then
  # Extract short commit info
  COMMIT_HASH=$(git log --oneline -1 2>/dev/null | head -c 50)
  echo "$COMMIT_HASH" > "$FLAG"
fi
