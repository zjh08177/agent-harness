#!/bin/bash
# Post-memory-update — clears the pending commit flag.
# Fires on PostToolUse for both mcp__memory__add_observations AND Write.
# For Write: only clears if the written file is in a memory directory.

FLAG="/tmp/.claude-memory-pending"

# For Write tool: check if the file path contains /memory/
if [ -n "$CLAUDE_TOOL_INPUT" ]; then
  # Only clear flag for writes to memory directories
  if echo "$CLAUDE_TOOL_INPUT" | grep -q "/memory/"; then
    rm -f "$FLAG"
  fi
else
  # For mcp__memory__add_observations (no TOOL_INPUT check needed)
  rm -f "$FLAG"
fi
