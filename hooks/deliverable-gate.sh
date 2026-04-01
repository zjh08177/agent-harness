#!/bin/bash
# UserPromptSubmit — remind to declare deliverables on first turn
TURN_FILE="/tmp/.claude-session-started"

if [ ! -f "$TURN_FILE" ]; then
  touch "$TURN_FILE"
  cat <<'MSG'
SESSION RULE: Before exploring, declare your deliverable in one line:
"Deliverable: [file path | commit | doc | answer to user]"
If after 10 minutes of exploration you haven't produced output, pause and narrow scope.
MSG
fi
