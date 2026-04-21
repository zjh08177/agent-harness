#!/bin/bash
# obsidian-cli-guard — blocks `obsidian-cli create --content` (silent truncation bug)
#
# Root cause: obsidian-cli embeds --content in obsidian://new?...&content=... URI
# without URL-encoding, so any unescaped & # ? % = + in the content terminates it.
# Exit 0, no warning. Reproduced 2026-04-14.
#
# Safe alternative: use the Write tool for vault doc content; use obsidian-cli
# only for `fm` / `move` / `open` (metadata + navigation).

set -eo pipefail

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

# Match: obsidian-cli [...] (create|c) [...] (-c|--content)[ =]
# - allow obsidian-cli fm/move/open (no match)
# - allow obsidian-cli create <path> (no --content) for empty-note creation
# - block obsidian-cli create --content "..." and short-form -c
if printf '%s' "$command" | grep -Eq 'obsidian-cli[[:space:]]+(create|c)[[:space:]]'; then
  if printf '%s' "$command" | grep -Eq '(^|[[:space:]])(-c|--content)([[:space:]]|=)'; then
    cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"⛔ obsidian-cli --content silently truncates at & # ? % = + (unescaped obsidian:// URI embedding, reproduced 2026-04-14). Use the Write tool for vault doc content: read template from 99-System/Templates/, substitute tokens, write full doc. Use obsidian-cli only for fm/move/open. Full rule: ~/.claude/CLAUDE.md § Vault Doc Creation"}}
EOF
    exit 0
  fi
fi

exit 0
