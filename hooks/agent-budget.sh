#!/bin/bash
# PostToolUse on Agent — track agent spawns per session
COUNTER="/tmp/.claude-agent-count"

COUNT=$(cat "$COUNTER" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER"

if [ "$COUNT" -ge 6 ]; then
  echo "WARNING: $COUNT agents spawned this session. Consider whether all are needed."
fi
