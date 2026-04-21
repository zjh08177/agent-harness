---
name: create-mr-ios
description: This skill should be used when creating or updating Merge Requests (MRs) for the TikTok iOS codebase. It uses the codebase MCP to create MRs on code.byted.org with properly formatted summaries following the team template. Triggers on requests like "create MR", "submit MR", "update MR description", or "prepare merge request".
---

# Create MR for TikTok iOS

Create or update Merge Requests for the TikTok iOS repository (`ugc/TikTok`) using the codebase MCP with properly formatted descriptions.

## Prerequisites

Before creating an MR, gather required information from the user:

1. **Meego Ticket URL** (required) - The feature/bug ticket link
   - Format: `https://meego.larkoffice.com/tiktok/story/detail/{TICKET_ID}`
   - Extract the ticket ID for `WorkItemIds` parameter

2. **Tech Solution Document** (required) - Either:
   - Lark doc URL: `https://bytedance.larkoffice.com/docx/{DOC_ID}`
   - Local markdown file path

If user doesn't provide these, ask explicitly:
> To create the MR, please provide:
> 1. **Meego ticket URL** (e.g., https://meego.larkoffice.com/tiktok/story/detail/123456)
> 2. **Tech solution document** - either a Lark doc URL or local .md file path

## Workflow

### Step 1: Gather Context

1. Get current branch name:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```

2. Get commit history unique to branch:
   ```bash
   git log origin/develop..HEAD --pretty=format:"%s%n%b"
   ```

3. Get diff stats for changed files:
   ```bash
   git diff origin/develop..HEAD --stat
   ```

4. If tech solution is a Lark doc, fetch content:
   ```
   Use mcp__lark_docs__get_lark_doc_content with doc_url parameter
   ```

5. If tech solution is a local file, read it directly.

### Step 2: Load MCP Tools

Search and load required codebase MCP tools:
```
ToolSearch: "+codebase merge request"
```

Required tools:
- `mcp__codebase__CreateMergeRequest` - Create new MR
- `mcp__codebase__UpdateMergeRequest` - Update existing MR
- `mcp__codebase__ListMergeRequests` - Check for existing MR

### Step 3: Check for Existing MR

Before creating, check if MR already exists for the branch:
```
mcp__codebase__ListMergeRequests
  RepoId: "ugc/TikTok"
  SourceBranch: {current_branch}
  State: "open"
```

If MR exists, proceed to update flow. Otherwise, create new MR.

### Step 4: Generate MR Description

Use the template from `references/mr_template.md` and fill in based on:
- Commit messages and their bodies
- Diff stats showing affected files/modules
- Tech solution document content
- Meego ticket information

**Description Guidelines:**
- Core change points: List 3-6 key changes, start with module path and risk assessment
- Impact scope: List affected components and their functionality changes
- Risk assessment: Document backward compatibility, AB gating, breaking changes
- Test suggestions: Recommend specific test scenarios in Chinese

### Step 5: Create or Update MR

**To Create:**
```
mcp__codebase__CreateMergeRequest
  RepoId: "ugc/TikTok"
  SourceBranch: {branch_name}
  TargetBranch: "develop"
  Title: "[{MR_TYPE}] {Brief description}"
  Description: {generated_description}
  Draft: false
  WorkItemIds: ["{meego_ticket_id}"]
```

**MR Title Format:**
- `[Feature]` - New functionality
- `[Bug Fix]` - Bug fixes
- `[Optimize]` - Performance/code improvements
- `[Refactor]` - Code restructuring

**To Update:**
```
mcp__codebase__UpdateMergeRequest
  RepoId: "ugc/TikTok"
  Number: {mr_number}  // Must be integer
  Title: {new_title}
  Description: {new_description}
  WorkItemIds: ["{meego_ticket_id}"]
```

### Step 6: Report Result

After successful creation/update, report:
- MR number and URL: `https://code.byted.org/ugc/TikTok/merge_requests/{NUMBER}`
- Status and linked ticket
- Summary of description sections

## Example MR Description

```markdown
# Core change points / 核心改动点

1. **涉及模块**: TikTokStudio/BasicBiz/AIGC - 不涉及高危模块，仅影响内部实现
2. **Decompose monolithic Config** into focused classes for better maintainability
3. **New dual-format resolution** - Try new format first, fallback to legacy for compatibility
4. **Centralized accessors** added to reduce scattered config access patterns

# Impact scope assessment / 影响面评估

1. **Core Tasks** (BaseTask, ServerTask) - updated config resolution pattern
2. **EventTracker** - now uses centralized accessors
3. **PersistenceManager** - migrated to use scheduler accessors

# Risk assessment / 风险点说明

1. **Backward compatibility**: Dual-format fallback ensures existing data works
2. **AB-gated**: Controlled by feature flag, turning off reverts to legacy behavior
3. **No breaking changes**: Old code paths remain functional

# Test scope suggestion / 测试建议

1. 重点回归核心流程创建、恢复、完成全流程
2. 重点关注从草稿箱恢复旧数据的兼容性
3. 验证 AB flag 关闭后功能完全回退

---
**ERD/Tech Solution**: https://bytedance.larkoffice.com/docx/xxx
**Feature**: https://meego.larkoffice.com/tiktok/story/detail/123456
```

## Common Issues

### "already exists" Error
MR already exists for this branch. Use `ListMergeRequests` to find it, then `UpdateMergeRequest`.

### "repository not found" Error
Use repo path `ugc/TikTok` instead of numeric ID.

### Number Type Error
The `Number` parameter in `UpdateMergeRequest` must be an integer, not a string.

## Resources

### references/
Contains the MR description template (`mr_template.md`) that defines the standard format for MR summaries.
