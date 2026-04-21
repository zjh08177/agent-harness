#!/bin/bash
# work-session-end.sh — Stop hook
# Checks if auto-capture happened this session.
# If not, sets a soft reminder for next session's UserPromptSubmit.

CAPTURED="/tmp/.claude-work-captured"
PENDING="/tmp/.claude-work-pending"

if [ -f "$CAPTURED" ]; then
  # Work was auto-captured — no reminder needed
  rm -f "$CAPTURED"
else
  # No auto-capture — maybe the session had unlogged work
  echo "no-capture" > "$PENDING"
fi

exit 0
