#!/bin/bash
# Check if planning files exist with content worth promoting
if [ -f findings.md ] && [ -s findings.md ]; then
  LINES=$(wc -l < findings.md | tr -d ' ')
  if [ "$LINES" -gt 5 ]; then
    echo "[findings-promote] findings.md has ${LINES} lines. Promote valuable discoveries to vault before ending session."
  fi
fi
