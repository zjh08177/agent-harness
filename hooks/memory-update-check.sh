#!/bin/bash
# Memory Protocol — Stop hook.
# Only fires a reminder when a commit was made but memory wasn't saved.
# Does NOT fire on every response (prevents alert fatigue).

FLAG="/tmp/.claude-memory-pending"

if [ -f "$FLAG" ]; then
  COMMIT_INFO=$(cat "$FLAG")
  cat <<'MEMORY_REMINDER'
⚠️ MEMORY REMINDER: A commit was made this session without saving memory.
Save a valuable insight as an auto-memory file before finishing.
Only save if there's a non-obvious learning — skip if the commit was routine.
MEMORY_REMINDER
fi
exit 0
