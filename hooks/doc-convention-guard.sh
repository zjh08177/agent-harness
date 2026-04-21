#!/bin/bash
# Doc Convention Guard — fires on every user prompt
# Lightweight check: only prints reminder when vault doc work is likely

# Check signals that vault doc creation might happen this session
PDIR=$(cat .planning-dir 2>/dev/null || echo ".")
HAS_PLAN=$([ -f "$PDIR/task-plan.md" ] && echo 1 || echo 0)
HAS_SKILL=$(echo "${CLAUDE_SKILL:-}" | grep -qiE "auto-(workflow|research|debug)" && echo 1 || echo 0)

if [ "$HAS_PLAN" = "1" ] || [ "$HAS_SKILL" = "1" ]; then
  echo "[doc-convention] Active planning session detected. Vault docs:"
  echo "  • Content → Write tool (templates from 99-System/Templates/, substitute {{title}}/{{date}})"
  echo "  • Metadata → obsidian-cli fm/move/open only. NEVER --content (truncates at &)."
  echo "  • Route: direction/product/<project>/ (flat, prefix-organized)"
  echo "  • Mandatory trio: erd-, tech-solution-, impl-plan-"
  echo "  • Full rule: ~/.claude/CLAUDE.md § Vault Doc Creation"
fi
