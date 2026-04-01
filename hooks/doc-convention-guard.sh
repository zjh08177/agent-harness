#!/bin/bash
# Doc Convention Guard — fires on every user prompt
# Lightweight check: only prints reminder when vault doc work is likely

# Check signals that vault doc creation might happen this session
PDIR=$(cat .planning-dir 2>/dev/null || echo ".")
HAS_PLAN=$([ -f "$PDIR/task-plan.md" ] && echo 1 || echo 0)
HAS_SKILL=$(echo "${CLAUDE_SKILL:-}" | grep -qiE "auto-(workflow|research|debug)" && echo 1 || echo 0)

if [ "$HAS_PLAN" = "1" ] || [ "$HAS_SKILL" = "1" ]; then
  echo "[doc-convention] Active planning session detected. Vault docs:"
  echo "  • Use obsidian-cli + vault templates (never Write directly)"
  echo "  • Route: direction/product/<project>/ (flat, prefix-organized)"
  echo "  • Mandatory trio: erd-, tech-solution-, impl-plan-"
  echo "  • Working files (task-plan.md, findings.md, progress.md) in same vault folder"
  echo "  • .planning-dir in CWD points to vault path"
fi
