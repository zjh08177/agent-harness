---
name: insights-archive
version: 1.0.0
description: |
  Wrap /insights with persistent archival. Runs /insights in the current session
  then snapshots report.html + session-meta + facets into a timestamped folder
  under ~/.claude/usage-data/archive/ so every report is preserved (the built-in
  /insights overwrites report.html on each run). Also builds a ~/.claude/usage-data/archive/index.md
  rolling index.
  Use when: "archive insights", "save insights report", "snapshot insights",
  "run insights and keep a copy", or immediately after any /insights run the
  user wants to preserve. Voice triggers: "keep the insights", "save this report".
triggers:
  - archive insights report
  - snapshot insights
  - persist insights html
  - save insights to history
allowed-tools:
  - Bash
  - Read
  - Write
---

# insights-archive

Persists a copy of each `/insights` run. The built-in `/insights` command overwrites `~/.claude/usage-data/report.html` on every invocation, so historical reports are lost unless snapshotted immediately.

## Context (why this exists)

`/insights` is a built-in Claude Code CLI command with **no CLI args** — passing text like `for the past month` decorates the model prompt but does not change data collection. Under the hood it:
1. Lists all sessions in `~/.claude/usage-data/session-meta/`
2. Sorts by `mtime` DESC
3. Caps at **60 most-recent sessions** (constant `I5K=60` in the binary)
4. Renders to the single fixed path `~/.claude/usage-data/report.html`

Consequence: each run clobbers the previous HTML and no history exists by default.

## Workflow

Run these steps **in order**. Do not skip step 1 — a stale report.html would be archived twice.

### Step 1 — Trigger a fresh /insights (if needed)

If the user just ran `/insights` in this session, skip to Step 2.
Otherwise tell the user: "Run `/insights` first, then re-invoke me." Do not proceed — this skill archives; it does not trigger the built-in.

### Step 2 — Verify freshness

```bash
REPORT=~/.claude/usage-data/report.html
[ -f "$REPORT" ] || { echo "No report.html found — run /insights first"; exit 1; }
AGE_SEC=$(( $(date +%s) - $(stat -f %m "$REPORT") ))
(( AGE_SEC > 600 )) && echo "WARN: report.html is $AGE_SEC seconds old — may be stale"
```

If age > 600s, warn the user and ask whether to archive the old one or run `/insights` fresh.

### Step 3 — Snapshot into a timestamped folder

```bash
TS=$(date +%Y-%m-%d-%H%M%S)
ARCHIVE=~/.claude/usage-data/archive/$TS
mkdir -p "$ARCHIVE"

# Primary: the rendered HTML
cp ~/.claude/usage-data/report.html "$ARCHIVE/report.html"

# Snapshot facets so a future custom analyzer could reprocess the same inputs
rsync -a ~/.claude/usage-data/facets/ "$ARCHIVE/facets/" 2>/dev/null || \
    cp -R ~/.claude/usage-data/facets "$ARCHIVE/"

# Capture the session-meta index (small; enables date-range queries later)
rsync -a ~/.claude/usage-data/session-meta/ "$ARCHIVE/session-meta/" 2>/dev/null || \
    cp -R ~/.claude/usage-data/session-meta "$ARCHIVE/"

# Emit a metadata stub
cat > "$ARCHIVE/meta.json" <<EOF
{
  "archived_at": "$(date -Iseconds)",
  "report_mtime_sec": $(stat -f %m ~/.claude/usage-data/report.html),
  "cwd_at_archive": "$(pwd)",
  "facet_count": $(ls ~/.claude/usage-data/facets/ 2>/dev/null | wc -l | tr -d ' '),
  "session_meta_count": $(ls ~/.claude/usage-data/session-meta/ 2>/dev/null | wc -l | tr -d ' ')
}
EOF

echo "Archived to: $ARCHIVE"
du -sh "$ARCHIVE"
```

### Step 4 — Update rolling index

Append a line to `~/.claude/usage-data/archive/index.md`:

```bash
INDEX=~/.claude/usage-data/archive/index.md
[ -f "$INDEX" ] || echo "# Insights Archive Index" > "$INDEX"
echo "- [$TS](./${TS}/report.html) — $(ls "$ARCHIVE/facets" | wc -l | tr -d ' ') facets, $(du -sh "$ARCHIVE" | cut -f1)" >> "$INDEX"
```

### Step 5 — Report to user

State: "Archived to `~/.claude/usage-data/archive/<TS>/report.html` — <N> facets, <size>." Give the absolute `file://` URL so it opens from the terminal.

## Optional — auto-archive via hook

If the user asks "always do this after /insights", wire a `SessionEnd` or `Stop` hook that runs the same archive script conditionally (only if report.html mtime is < 5 min). Hook config belongs in `~/.claude/settings.json` — propose the snippet, do not write it without approval.

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "R=~/.claude/usage-data/report.html; [ -f \"$R\" ] && [ $(( $(date +%s) - $(stat -f %m \"$R\") )) -lt 300 ] && bash ~/.claude/skills/insights-archive/auto-archive.sh 2>/dev/null || true"
      }]
    }]
  }
}
```

## Limitations (surface upfront)

- **Cannot widen the /insights time window.** The 60-session cap is baked into the binary. Archiving frequently is the only way to build month-over-month history. If the user specifically asked for "past month" scope, explain this: their "past month" lives in the archive folder, not in any single `/insights` run.
- **Cannot trigger /insights from inside this skill.** Built-in commands are not callable from skills. User must run `/insights` first.
- **Archive size grows.** Each snapshot duplicates `facets/` and `session-meta/` (typically ~1–5 MB per run). Prune with `find ~/.claude/usage-data/archive -maxdepth 1 -type d -mtime +90 -exec rm -rf {} +` if needed.
