#!/usr/bin/env bash
# install.sh — Agent harness bootstrap for a fresh machine
#
# Idempotent. Safe to re-run.

set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "==> Agent harness install (root: $ROOT)"

# 1. Re-install third-party skills from .skill-lock.json if present
if [ -f .skill-lock.json ] && command -v npx >/dev/null 2>&1; then
  echo "==> Reinstalling third-party skills from .skill-lock.json..."
  python3 - <<'PY'
import json, subprocess, sys
try:
    with open('.skill-lock.json') as f:
        lock = json.load(f)
except FileNotFoundError:
    sys.exit(0)
for name, meta in lock.get('skills', {}).items():
    source = meta.get('source')
    if not source:
        continue
    print(f"  - {name} (from {source})")
    subprocess.run(['npx', 'skills', 'add', source, '-g'], check=False)
PY
else
  echo "==> No .skill-lock.json — skipping third-party reinstall"
fi

# 2. Deploy skill symlinks via existing sync script
if [ -x sync-skills.sh ]; then
  echo "==> Running sync-skills.sh..."
  ./sync-skills.sh --quiet || ./sync-skills.sh
fi

# 3. Deploy CLAUDE.md as symlink (backup existing first)
mkdir -p ~/.claude
if [ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
  backup=~/.claude/CLAUDE.md.bak.$(date +%s)
  mv ~/.claude/CLAUDE.md "$backup"
  echo "==> Backed up existing CLAUDE.md → $backup"
fi
ln -sf "$ROOT/settings/CLAUDE.md" ~/.claude/CLAUDE.md
echo "==> Linked ~/.claude/CLAUDE.md → $ROOT/settings/CLAUDE.md"

# 4. Deploy hooks as symlinked directory (backup existing)
if [ -d ~/.claude/hooks ] && [ ! -L ~/.claude/hooks ]; then
  backup=~/.claude/hooks.bak.$(date +%s)
  mv ~/.claude/hooks "$backup"
  echo "==> Backed up existing hooks dir → $backup"
fi
ln -sf "$ROOT/hooks" ~/.claude/hooks
echo "==> Linked ~/.claude/hooks → $ROOT/hooks"

# 5. Remind about settings.json
if [ ! -f ~/.claude/settings.json ]; then
  cp settings/settings.json.example ~/.claude/settings.json
  echo "==> Seeded ~/.claude/settings.json from example"
else
  echo ""
  echo "⚠️  Existing ~/.claude/settings.json NOT touched."
  echo "    Review settings/settings.json.example and merge hook wiring manually."
fi

echo ""
echo "✓ Install complete."
echo "  - Skills:   ~/.claude/skills/  (symlinked from $ROOT/skills/)"
echo "  - Hooks:    ~/.claude/hooks    (symlinked from $ROOT/hooks/)"
echo "  - CLAUDE.md: ~/.claude/CLAUDE.md (symlinked from $ROOT/settings/CLAUDE.md)"
