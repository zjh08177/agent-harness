#!/usr/bin/env bash
# harness-auto-commit.sh — auto-commit changes to ~/.agents/ at session end
#
# Fires on Stop event. Batches all edits to skills, hooks, CLAUDE.md, etc.
# into one commit per session (less noisy than per-edit commits).
#
# Wire in settings.json:
#   "Stop": [{
#     "hooks": [{"type": "command", "command": "~/.claude/hooks/harness-auto-commit.sh"}]
#   }]
#
# Environment variables:
#   HARNESS_AUTO_PUSH=1      → also push to origin (default: commit only)
#   HARNESS_AUTO_COMMIT_OFF=1 → disable entirely (emergency brake)

set -u
[ "${HARNESS_AUTO_COMMIT_OFF:-0}" = "1" ] && exit 0

HARNESS_ROOT="$HOME/.agents"

# Repo gate
[ -d "$HARNESS_ROOT/.git" ] || exit 0
cd "$HARNESS_ROOT" || exit 0

# Nothing to commit?
if [ -z "$(git status --porcelain)" ]; then
  exit 0
fi

# Summary of what changed (file list, truncated)
changed_files=$(git status --porcelain | awk '{print $2}')
file_count=$(echo "$changed_files" | wc -l | tr -d ' ')
first_files=$(echo "$changed_files" | head -5 | tr '\n' ' ' | sed 's/ $//')

# Classify by prefix for a human-readable title
classify() {
  local paths="$1"
  if echo "$paths" | grep -q '^skills/shared/'; then echo "shared"; return; fi
  if echo "$paths" | grep -q '^skills/auto-'; then echo "auto-skills"; return; fi
  if echo "$paths" | grep -q '^skills/'; then echo "skills"; return; fi
  if echo "$paths" | grep -q '^hooks/'; then echo "hooks"; return; fi
  if echo "$paths" | grep -q '^settings/CLAUDE.md'; then echo "CLAUDE.md"; return; fi
  if echo "$paths" | grep -q '^settings/'; then echo "settings"; return; fi
  echo "misc"
}

scope=$(classify "$changed_files")
title="chore($scope): auto-sync $file_count file(s)"
if [ "$file_count" -le 3 ]; then
  title="chore($scope): update $(basename "$(echo "$changed_files" | head -1)")"
fi

# Short body: file list + diff stats
body=$(git diff --stat 2>/dev/null | tail -6)

# Stage + commit
git add -A
if ! git commit -m "$title" -m "$body" -m "Auto-committed by harness-auto-commit hook at session end." \
  -m "Co-Authored-By: Claude <noreply@anthropic.com>" >/dev/null 2>&1; then
  echo "[harness-auto-commit] Commit failed" >&2
  exit 0
fi

commit_sha=$(git rev-parse --short HEAD)
echo "[harness-auto-commit] $commit_sha $title" >&2

# Optional push
if [ "${HARNESS_AUTO_PUSH:-0}" = "1" ]; then
  if git push >/dev/null 2>&1; then
    echo "[harness-auto-commit] Pushed to origin" >&2
  else
    echo "[harness-auto-commit] Push failed (local commit remains)" >&2
  fi
fi

exit 0
