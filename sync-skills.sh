#!/bin/bash
# ~/.agents/sync-skills.sh
# Single source of truth: ~/.agents/skills/
# Syncs skills across Claude Code, OpenClaw, and Cursor.
#
# Usage:
#   ~/.agents/sync-skills.sh          # interactive
#   ~/.agents/sync-skills.sh --quiet  # cron-friendly (only prints if changes found)

set -e

SOT="$HOME/.agents/skills"
CLAUDE="$HOME/.claude/skills"
OPENCLAW="$HOME/.openclaw/skills"
CURSOR="$HOME/.cursor/skills"
QUIET="${1:-}"

mkdir -p "$SOT" "$OPENCLAW"
[ -d "$CLAUDE" ] || mkdir -p "$CLAUDE"
[ -d "$CURSOR" ] || mkdir -p "$CURSOR"

moved=0
linked=0
cleaned=0

# --- Step 1: Pull new standalone skills from tool dirs into SOT ---
for tool_dir in "$CLAUDE" "$OPENCLAW" "$CURSOR"; do
  tool_name=$(basename "$(dirname "$tool_dir")")
  for skill in "$tool_dir"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    [ -L "${skill%/}" ] && continue
    [ "$name" = "gstack" ] && continue
    [ -d "$SOT/$name" ] && continue

    mv "$skill" "$SOT/$name"
    ln -s "../../.agents/skills/$name" "$tool_dir/$name"
    moved=$((moved + 1))
  done
done

# --- Step 2: Ensure all SOT skills are symlinked into each tool ---
for tool_dir in "$CLAUDE" "$OPENCLAW" "$CURSOR"; do
  for skill in "$SOT"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    [ "$name" = "gstack" ] && continue
    if [ ! -e "$tool_dir/$name" ]; then
      ln -s "../../.agents/skills/$name" "$tool_dir/$name"
      linked=$((linked + 1))
    fi
  done
done

# --- Step 3: Clean broken symlinks ---
for tool_dir in "$CLAUDE" "$OPENCLAW" "$CURSOR"; do
  for link in "$tool_dir"/*; do
    [ -L "$link" ] || continue
    if [ ! -e "$link" ]; then
      rm "$link"
      cleaned=$((cleaned + 1))
    fi
  done
done

# --- Output ---
total=$(ls "$SOT" | wc -l | tr -d ' ')

if [ "$QUIET" = "--quiet" ]; then
  # Only print if something changed
  changes=$((moved + linked + cleaned))
  if [ "$changes" -gt 0 ]; then
    echo "[sync-skills] $(date '+%Y-%m-%d %H:%M') | moved=$moved linked=$linked cleaned=$cleaned total=$total"
  fi
else
  echo "🔄 Skills sync complete"
  echo "   Moved to SOT: $moved"
  echo "   New symlinks: $linked"
  echo "   Broken links cleaned: $cleaned"
  echo "   Total skills: $total"
fi
