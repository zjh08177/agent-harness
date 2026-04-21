#!/bin/bash
# Auto-commit hook for Claude Code
# Only commits when history.md has been updated (ensuring fresh commit message)

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

# Check if there are any changes to commit
if [ -z "$(git status --porcelain)" ]; then
  exit 0
fi

HISTORY_FILE=".claude/memory/history.md"

# Stage all changes first
git add -A

# CRITICAL: Only commit if history.md is in staged changes
# This ensures the workflow was followed (MEMORY step before COMMIT)
if ! git diff --cached --name-only | grep -q "^\.claude/memory/history\.md$"; then
  echo "[auto_commit] Skipping: history.md not updated. Follow workflow: MEMORY → COMMIT"
  git reset HEAD >/dev/null 2>&1  # Unstage changes
  exit 0
fi

# Extract commit message from history.md
TITLE=""
BODY=""

if [ -f "$HISTORY_FILE" ]; then
  # Get the title from first ## heading (format: ## YYYY-MM-DD - T#: Title)
  TITLE=$(grep -m1 "^## [0-9]" "$HISTORY_FILE" | sed 's/^## [0-9-]* - //')

  # Get the body: lines between first ## heading and first ---
  FIRST_HEADING=$(grep -n "^## [0-9]" "$HISTORY_FILE" | head -1 | cut -d: -f1)
  FIRST_SEP=$(grep -n "^---$" "$HISTORY_FILE" | head -1 | cut -d: -f1)

  if [ -n "$FIRST_HEADING" ] && [ -n "$FIRST_SEP" ] && [ "$FIRST_SEP" -gt "$FIRST_HEADING" ]; then
    START=$((FIRST_HEADING + 1))
    END=$((FIRST_SEP - 1))
    BODY=$(sed -n "${START},${END}p" "$HISTORY_FILE" | head -20)
  fi
fi

# Fallback title if none found (shouldn't happen if workflow followed)
if [ -z "$TITLE" ]; then
  echo "[auto_commit] Warning: No task title found in history.md"
  TOTAL=$(git diff --cached --name-only | wc -l | tr -d ' ')
  TITLE="Update ($TOTAL files)"
fi

# Truncate title if too long
if [ ${#TITLE} -gt 72 ]; then
  TITLE="${TITLE:0:69}..."
fi

# Build commit message with Co-Authored-By
COMMIT_MSG="$TITLE"
if [ -n "$BODY" ]; then
  COMMIT_MSG="$TITLE

$BODY

Co-Authored-By: Claude <noreply@anthropic.com>"
else
  COMMIT_MSG="$TITLE

Co-Authored-By: Claude <noreply@anthropic.com>"
fi

# Commit
git commit -m "$COMMIT_MSG" >/dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "[auto_commit] Committed: $TITLE"
  # Push to remote
  git push >/dev/null 2>&1 && echo "[auto_commit] Pushed to remote" || true
else
  echo "[auto_commit] Commit failed"
  exit 1
fi
