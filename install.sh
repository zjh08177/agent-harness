#!/bin/bash
# agent-harness installer — copy hooks, skills, and memory template to ~/.claude/
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "📦 Installing agent-harness to ${CLAUDE_DIR}/"

# Hooks
mkdir -p "${CLAUDE_DIR}/hooks"
cp "${SCRIPT_DIR}/hooks/"*.sh "${CLAUDE_DIR}/hooks/"
chmod +x "${CLAUDE_DIR}/hooks/"*.sh
echo "  ✓ 8 hooks → ${CLAUDE_DIR}/hooks/"

# Skills
for skill in auto-workflow auto-explore auto-debug nano-image-gen shared; do
  mkdir -p "${CLAUDE_DIR}/skills/${skill}"
  cp -r "${SCRIPT_DIR}/skills/${skill}/"* "${CLAUDE_DIR}/skills/${skill}/"
done
echo "  ✓ 5 skills → ${CLAUDE_DIR}/skills/"

# Memory template (only if no memory dir exists for current project)
echo "  ℹ Memory template available at: memory/MEMORY.md.template"
echo "    Copy it to ~/.claude/projects/<your-project>/memory/MEMORY.md"

# Settings.json reminder
echo ""
echo "⚠️  One manual step: merge hooks config into your settings.json"
echo "    See: ${SCRIPT_DIR}/hooks/settings.json.example"
echo "    Target: ${CLAUDE_DIR}/settings.json"
echo ""
echo "✅ Done. Restart Claude Code to activate hooks."
