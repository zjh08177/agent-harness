#!/bin/bash
# work-log-gate.sh — UserPromptSubmit hook (soft reminder)
# If previous session ended without auto-capturing work to today.md,
# gently remind the AI to log meaningful work. Not a hard block.

FLAG="/tmp/.claude-work-pending"

if [ -f "$FLAG" ]; then
  # Auto-expire after 12 hours
  if [ "$(uname)" = "Darwin" ]; then
    FLAG_AGE=$(( $(date +%s) - $(stat -f %m "$FLAG") ))
  else
    FLAG_AGE=$(( $(date +%s) - $(stat -c %Y "$FLAG") ))
  fi
  if [ "$FLAG_AGE" -gt 43200 ]; then
    rm -f "$FLAG"
    exit 0
  fi

  cat <<'REMINDER'
Your last session may have had unlogged work. If it was meaningful (research, debugging, discussion), append a timestamped line to Areas/Career/work-log/today.md. Skip if the session was trivial.
REMINDER
  rm -f "$FLAG"
fi

exit 0
