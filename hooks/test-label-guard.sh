#!/usr/bin/env bash
# test-label-guard.sh — PostToolUse hook
# Flags mismatches between test file name and test character.
#
# Wire in settings.json:
#   "PostToolUse": [{
#     "matcher": "Edit|Write",
#     "hooks": [{"type": "command", "command": "~/.claude/hooks/test-label-guard.sh"}]
#   }]
#
# Non-blocking warning (stderr). Surfaces to Claude in next tool result.
# Claude can suppress per-file with `# label-guard: ignore` comment.

set -u
file="${CLAUDE_TOOL_INPUT_file_path:-}"
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# Opt-out comment anywhere in file
grep -q 'label-guard: ignore' "$file" 2>/dev/null && exit 0

case "$(basename "$file")" in
  *e2e*|*end_to_end*|*end-to-end*)
    if grep -qE '(^|[^a-zA-Z_])(mock|MagicMock|@patch|requests_mock|monkeypatch|jest\.mock|vi\.mock|sinon\.stub)' "$file" 2>/dev/null; then
      echo "⚠️  test-label-guard: '$file' labeled e2e but contains mocks — re-label 'integration' or remove mocks." >&2
    fi
    ;;
  *integration*)
    if ! grep -qE '(real_db|testcontainer|docker|fixture.*real|requests\.|urllib|http\.|fetch\(|axios|playwright|puppeteer|localhost:)' "$file" 2>/dev/null; then
      echo "⚠️  test-label-guard: '$file' labeled integration but no external I/O detected — possibly a unit test mislabeled." >&2
    fi
    ;;
  *unit*)
    if grep -qE '(requests\.get|urllib|http\.client|subprocess\.run|subprocess\.Popen|fetch\(|axios\.|fs\.writeFile)' "$file" 2>/dev/null; then
      echo "⚠️  test-label-guard: '$file' labeled unit but makes network/subprocess/disk I/O — re-label 'integration'." >&2
    fi
    ;;
esac

exit 0
