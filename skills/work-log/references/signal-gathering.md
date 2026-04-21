# Signal Gathering Reference

Detailed instructions for each data source the `/work-log` skill pulls from.

## 1. Git Commits

For each repo in config `repos` list:

```bash
git -C <repo_path> log --author="<author_email>" --since="last monday" --until="next saturday" --pretty=format:"%h %s (%ai)" --no-merges
```

Group commits by repo. Extract commit messages for categorization.

## 2. Merged MRs (Codebase MCP)

Use `mcp__codebase__ListMergeRequests` with filters:
- `state`: "merged"
- `author`: current user (get via `mcp__codebase__GetMe`)
- `updated_after`: Monday of current week (ISO 8601)

For each MR, extract: title, description, URL. Map to **Shipped**.

## 3. MR Reviews Given (Codebase MCP)

Use `mcp__codebase__ListMergeRequests` with filters:
- `reviewer`: current user
- `updated_after`: Monday of current week

Count reviews. List MR titles + authors reviewed. Map to **Invisible Work**.

## 4. Vault Artifacts Created

```bash
cd <vault_path>
git log --since="last monday" --name-only --pretty=format:"" -- "Projects/" "Areas/" "Resources/" | grep -E "^(tech-solution-|impl-plan-|research-|erd-|finding-)" | sort -u
```

If vault has no git, fall back to `find` by mtime:

```bash
find <vault_path>/Projects <vault_path>/Areas -name "tech-solution-*" -o -name "impl-plan-*" -o -name "research-*" -o -name "erd-*" -o -name "finding-*" -newer <monday_marker_file> 2>/dev/null
```

## 5. Auto-Memory Entries

For each directory in config `memory_dirs`:

```bash
find <memory_dir> -name "*.md" -newer <monday_marker_file> ! -name "MEMORY.md" 2>/dev/null
```

Read each new file's `name` and `description` from frontmatter.

## 6. Daily Scratch (`today.md`)

Read `<vault>/Areas/Career/work-log/today.md`. Parse each dated section.
- Checked items (`- [x]`) → completed work
- Unchecked items (`- [ ]`) → candidates for carry-forward

## 7. Previous Week Carry-Forward

Read previous week file. Extract `## Carry-forward` section items.
