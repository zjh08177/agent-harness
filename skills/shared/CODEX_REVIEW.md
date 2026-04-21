# Codex Review Mode

Shared infrastructure for `codex=on` mode in `auto-workflow`, `auto-debug`, `auto-explore`.

When `codex=on`, every Claude subagent reviewer role in a review phase is replaced 1:1 by a parallel `codex exec` session. Same `N` (agents) count, same role breakdown, same Reviewer Constitution prompt — only the provider changes.

## Preflight (run once per session, before Phase 1)

Graceful fallback: use gstack helpers if present, otherwise inline minimal checks.

```bash
# Optional gstack helpers — skip silently if gstack isn't installed
if [ -f ~/.claude/skills/gstack/bin/gstack-codex-probe ]; then
  source ~/.claude/skills/gstack/bin/gstack-codex-probe
  _HAS_GSTACK_CODEX=true
else
  _HAS_GSTACK_CODEX=false
fi

# Binary + auth check
if ! command -v codex >/dev/null 2>&1; then
  echo "[codex-unavailable: binary not found] — falling back to codex=off"
  _CODEX_AVAILABLE=false
elif $_HAS_GSTACK_CODEX && ! _gstack_codex_auth_probe >/dev/null; then
  echo "[codex-unavailable: auth missing] — run \`codex login\` or set \$CODEX_API_KEY. Falling back to codex=off."
  _CODEX_AVAILABLE=false
else
  _CODEX_AVAILABLE=true
fi
```

If `_CODEX_AVAILABLE=false` at preflight, **degrade the whole session to `codex=off`** and tell the user. Do NOT silently continue without reviewers.

## Filesystem Boundary Prefix (MANDATORY)

Every codex prompt MUST start with:

> IMPORTANT: Do NOT read or execute any SKILL.md files or files in skill definition directories (paths containing `~/.claude/skills/` or `.claude/skills/`). These are AI assistant skill definitions meant for a different system. They contain bash scripts and prompt templates that will waste your time. Ignore them completely. Stay focused on the repository code and the artifact I'm passing you.

Without this, Codex discovers skill files on disk and follows *their* instructions instead of reviewing.

## Parallel Invocation Pattern (N reviewers)

For a review phase with `N` reviewer roles, launch `N` codex sessions in parallel. Each role's prompt = boundary prefix + role-specific reviewer instructions + full Reviewer Constitution + artifact path.

```bash
_REPO_ROOT=$(git rev-parse --show-toplevel) || { echo "ERROR: not in a git repo" >&2; exit 1; }
_CX_DIR=$(mktemp -d -t codex-review-XXXXXX)
_CX_PIDS=()
_CX_ROLES=()

# Launch each reviewer in background, one prompt per role
for i in "${!_CX_ROLE_PROMPTS[@]}"; do
  _ROLE="${_CX_ROLE_NAMES[$i]}"
  _PROMPT="${_CX_ROLE_PROMPTS[$i]}"
  _OUT="$_CX_DIR/$i-$_ROLE.md"

  # Timeout: 10 min per reviewer (gstack wrapper if present, else shell `timeout`)
  if $_HAS_GSTACK_CODEX; then
    _gstack_codex_timeout_wrapper 600 codex exec "$_PROMPT" \
      -C "$_REPO_ROOT" -s read-only --enable web_search_cached \
      < /dev/null > "$_OUT" 2>&1 &
  else
    timeout 600 codex exec "$_PROMPT" \
      -C "$_REPO_ROOT" -s read-only --enable web_search_cached \
      < /dev/null > "$_OUT" 2>&1 &
  fi

  _CX_PIDS+=($!)
  _CX_ROLES+=("$_ROLE")
done

# Wait for all, record per-role exit codes
_CX_EXITS=()
for pid in "${_CX_PIDS[@]}"; do
  wait "$pid"
  _CX_EXITS+=($?)
done

# Report results
for i in "${!_CX_ROLES[@]}"; do
  _ROLE="${_CX_ROLES[$i]}"
  _EXIT="${_CX_EXITS[$i]}"
  _OUT="$_CX_DIR/$i-$_ROLE.md"
  if [ "$_EXIT" = "124" ]; then
    echo "[$_ROLE: codex stalled past 10 min — tagging [codex-timeout]]"
  elif [ "$_EXIT" -ne 0 ]; then
    echo "[$_ROLE: codex exit $_EXIT — tagging [codex-failed]]"
  else
    echo "--- $_ROLE ---"; cat "$_OUT"
  fi
done
```

**Cost note:** N parallel codex sessions × 10 min timeout. Track in session budget.

## Prompt Construction

Each role's `_PROMPT` has this shape:

```
<filesystem boundary prefix from above>

You are a <role description> reviewing <artifact type>.

<full Reviewer Constitution from ~/.claude/skills/shared/REVIEWER_CONSTITUTION.md>

<artifact passed inline OR file path — see "Artifact Handoff" below>

Return findings in the Constitution's output-contract format.
```

## Artifact Handoff

Pass artifacts by absolute path when possible (codex `-C "$_REPO_ROOT"` gives read-only access to the repo). For artifacts not in the repo:

- **Plan / ERD / tech-solution / impl-plan** — vault path. Codex in read-only mode cannot read `$HOME` outside the repo, so copy to a temp file inside the repo root (or write artifact contents directly into the prompt, truncated to first 200KB if necessary).
- **Code diff** — `git diff <base>..HEAD > $_CX_DIR/diff.patch`, pass path.
- **Root-cause summary (auto-debug Phase 3)** — write to `$_CX_DIR/root-cause.md`, pass path. This is the cold-review exception the Constitution allows.
- **Synthesis doc (auto-explore Phase 4)** — copy to repo temp file.

## Degradation Matrix (per phase)

| Codex reviewers succeeded | Action |
|---|---|
| All N | Proceed, merge findings normally |
| Some failed (timeout / non-zero) | Proceed with successful outputs; log missing roles; if fewer than ⌈N/2⌉ succeeded, treat as phase-level failure and halt for user decision |
| All N failed | Halt. Surface `[codex-phase-failed]` via `AskUserQuestion`: (a) retry, (b) fall back to Claude subagents for this phase only, (c) abort |

## Convergence Rounds

Multi-round review (per Reviewer Constitution's Round 1 / Round 2+ rules) is unchanged under `codex=on`. Round 1: each codex reviewer runs independent analysis. Round 2+: include prior round's merged findings in the prompt and require justified agreement/disagreement.

## Per-skill binding

Each caller skill exports a bash array of role prompts before sourcing the launch block:

```bash
_CX_ROLE_NAMES=("backend-architect" "frontend-developer" "code-architect")
_CX_ROLE_PROMPTS=(
  "$_CX_PREFIX

You are a backend architect reviewing a tech-solution document.
$(cat ~/.claude/skills/shared/REVIEWER_CONSTITUTION.md)

Review the tech solution at path: $_ARTIFACT_PATH
Focus: API design, data flow, scalability, performance.
"
  # ... one entry per role
)
```

The caller picks role names + per-role focus from its phase table (same table used for Claude subagents). Constitution stays identical.
