#!/usr/bin/env bash
# Called by the optional Stop hook. Safe to run repeatedly.
# Only archives if report.html was modified in the last 5 minutes (hook mode).
# Pass --force to archive regardless of age (manual mode).
set -uo pipefail

REPORT="$HOME/.claude/usage-data/report.html"
ROOT="$HOME/.claude/usage-data/archive"
FORCE="${1:-}"

[ -f "$REPORT" ] || { echo "No report.html at $REPORT"; exit 0; }
AGE=$(( $(date +%s) - $(stat -f %m "$REPORT") ))
if [ "$FORCE" != "--force" ] && [ "$AGE" -ge 300 ]; then
  exit 0
fi

TS=$(date +%Y-%m-%d-%H%M%S)
DEST="$ROOT/$TS"
mkdir -p "$DEST"

cp "$REPORT" "$DEST/report.html"
rsync -a "$HOME/.claude/usage-data/facets/" "$DEST/facets/" 2>/dev/null || cp -R "$HOME/.claude/usage-data/facets" "$DEST/"
rsync -a "$HOME/.claude/usage-data/session-meta/" "$DEST/session-meta/" 2>/dev/null || cp -R "$HOME/.claude/usage-data/session-meta" "$DEST/"

cat > "$DEST/meta.json" <<EOF
{
  "archived_at": "$(date -Iseconds)",
  "source": "hook",
  "report_age_seconds_at_archive": $AGE
}
EOF

INDEX="$ROOT/index.md"
[ -f "$INDEX" ] || echo "# Insights Archive Index" > "$INDEX"
echo "- [$TS](./${TS}/report.html) — auto (hook), report was ${AGE}s old" >> "$INDEX"
