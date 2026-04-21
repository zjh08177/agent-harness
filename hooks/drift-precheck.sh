#!/usr/bin/env bash
# drift-precheck.sh — PreToolUse hook for Agent dispatches containing "REVIEW ROUND"
#
# Blocks review dispatch when cross-doc drift is detected in the artifact:
# - Unresolved wiki-links
# - Decision-table revision-history / body mismatch
# - Inline revision-marker accumulation (>3 tags in body)
# - Risk-register numbering gaps
#
# Wire in settings.json:
#   "PreToolUse": [{
#     "matcher": "Agent",
#     "hooks": [{"type": "command", "command": "~/.claude/hooks/drift-precheck.sh"}]
#   }]
#
# Initial mode: WARN (exit 0 with stderr msg). Flip to FAIL-CLOSED (exit 2) after
# 2-week baseline. Change `DRIFT_MODE` env var or edit below.

set -u
DRIFT_MODE="${DRIFT_MODE:-warn}"   # warn | block
prompt="${CLAUDE_TOOL_INPUT_prompt:-}"

# Only fire for review-round dispatches
echo "$prompt" | grep -qE 'REVIEW ROUND [0-9]+ OF' || exit 0

# Extract artifact path from prompt (best-effort; look for .md file refs)
artifact=$(echo "$prompt" | grep -oE '[[:alnum:]_/.-]+\.md' | head -1)
[ -z "$artifact" ] && exit 0

# Resolve to absolute path if in vault
VAULT="/Users/bytedance/Library/Mobile Documents/iCloud~md~obsidian/Documents/second-brain"
if [ ! -f "$artifact" ] && [ -f "$VAULT/$artifact" ]; then
  artifact="$VAULT/$artifact"
fi
[ -f "$artifact" ] || exit 0

# Delegate to the drift-check script if present
DRIFT_SCRIPT="$VAULT/scripts/drift-check.py"
if [ -x "$DRIFT_SCRIPT" ] || [ -f "$DRIFT_SCRIPT" ]; then
  if ! python3 "$DRIFT_SCRIPT" "$artifact" >&2; then
    if [ "$DRIFT_MODE" = "block" ]; then
      echo "⛔ drift-precheck: blocking review dispatch. Fix drift in $artifact then retry." >&2
      exit 2
    else
      echo "⚠️  drift-precheck: drift detected in $artifact. Review may surface cross-doc mismatches." >&2
    fi
  fi
  exit 0
fi

# Fallback inline checks if drift-check.py not installed
issues=0

# 1. Revision-marker accumulation in body (>3 inline r1-r99 tags)
marker_count=$(grep -cE '\(r[0-9]+[[:space:]]' "$artifact" 2>/dev/null || echo 0)
if [ "$marker_count" -gt 3 ]; then
  echo "⚠️  drift-precheck: $marker_count inline revision markers in body of $artifact (threshold 3). Surgical top-edits may not have propagated." >&2
  issues=$((issues + 1))
fi

# 2. Dangling wiki-links (references [[foo]] where foo doesn't resolve)
# Simplified: just count wikilinks, don't resolve
wikilink_count=$(grep -oE '\[\[[^]]+\]\]' "$artifact" 2>/dev/null | wc -l | tr -d ' ')
if [ "$wikilink_count" -gt 30 ]; then
  echo "ℹ️  drift-precheck: $wikilink_count wiki-links in $artifact — verify resolution manually." >&2
fi

[ "$DRIFT_MODE" = "block" ] && [ "$issues" -gt 0 ] && exit 2
exit 0
