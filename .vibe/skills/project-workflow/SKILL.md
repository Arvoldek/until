---
name: project-workflow
description: Load this skill when the user asks to work on an issue, create a task, manage the project board, create a PR, or follow the Until Development workflow. Covers all flows: picking up work, creating issues, status changes, PR creation, and edge cases.
---

# Project Workflow — Until Development

Use this skill to manage work on the Until Flutter app through the GitHub Project board.

## Project Reference

| Resource | Value |
|----------|-------|
| Project | Until Development |
| Project URL | https://github.com/users/Arvoldek/projects/3 |
| Project ID | `PVT_kwHOAfdJeM4BnX_0` |
| Repo | `Arvoldek/until` |
| Kanban Board | https://github.com/users/Arvoldek/projects/3/views/2 |

### Status Flow

```
Backlog → In Progress → Review → Merge → Done
```

Status changes are **automated** by project workflows. Do not set Status manually unless the automation doesn't cover the case.

### Field IDs

| Field | ID | Options (name → ID) |
|-------|-----|---------------------|
| Status | `PVTSSF_lAHOAfdJeM4BnX_0zhl864c` | Backlog `d8dbc968`, In Progress `5c2fd214`, Review `78ca2799`, Merge `ff8e3aff`, Done `a1cce8a7` |
| Priority | `PVTSSF_lAHOAfdJeM4BnX_0zhl87AM` | High `6db3435a`, Medium `76cf6b7a`, Low `355caf77` |
| Work Type | `PVTSSF_lAHOAfdJeM4BnX_0zhl87I0` | Bug `9b1750a6`, Feature `c6318716`, Task `8a2bd203`, Epic `f871d241` |

### Automation (what happens automatically)

| Event | Result |
|-------|--------|
| Issue created in repo | Auto-added to project, Status → Backlog |
| PR linked to issue (via `Closes #N`) | Status → Review |
| Review approved | Status → Merge |
| PR merged | Status → Done |
| Issue closed | Status → Done |
| Item reopened | Status → In Progress |
| Code changes requested | Status → In Progress |

### Branch Naming Convention

```
<type>/issue-<N>-<short-description>
```

| Type | Work Type | Example |
|------|-----------|---------|
| `bug/` | Bug | `bug/issue-42-fix-login-crash` |
| `feature/` | Feature | `feature/issue-15-add-dark-mode` |
| `task/` | Task | `task/issue-8-refactor-auth-service` |
| `epic/` | Epic | `epic/issue-3-user-onboarding` |

**Rules:**
- Always include the issue number
- Type must match the **Work Type** field
- Lowercase, hyphens only (no spaces, no underscores)
- Short description: 3–5 words from the issue title
- Branch from `main`

**PR title:** `<Title Case description> (#<N>)` — e.g. `Fix login crash on startup (#42)`

---

## Flows

### Flow 1: "Work on the next task" / "Pick up next Backlog item"

1. **Find the next item:** Query the project for items with Status = Backlog, sorted by Priority (High → Medium → Low).
   ```bash
   gh api graphql -f query='query {
     node(id: "PVT_kwHOAfdJeM4BnX_0") {
       ... on ProjectV2 {
         items(first: 50) {
           nodes {
             id
             content { ... on Issue { number title url } ... on PullRequest { number title url } }
             fieldValueByName(name: "Status") { ... on ProjectV2ItemFieldSingleSelectValue { name } }
             fieldValueByName(name: "Priority") { ... on ProjectV2ItemFieldSingleSelectValue { name } }
           }
         }
       }
     }
   }'
   ```
2. **If no Backlog items:** Tell the user and offer to create one.
3. **Pick the highest-priority item.** If tied, pick the oldest.
4. **Set Status → In Progress** (see [Set Field](#set-field) below).
5. **Ensure Priority and Work Type are set.** If missing, set defaults: Priority = Medium, Work Type = Task. For bug reports, set Work Type = Bug.
6. **Create a branch** following the [naming convention](#branch-naming-convention):
   ```bash
   git checkout main && git pull
   git checkout -b <type>/issue-<N>-<short-description>
   # e.g.: git checkout -b bug/issue-42-fix-login-crash
   ```
7. **Implement, test, commit.** Follow the [Flutter Coding Guidelines](../../../AGENTS.md#flutter-coding-guidelines) in AGENTS.md:
   - Layered architecture (presentation → application → data)
   - Riverpod for state, const constructors, immutable data classes
   - Run `dart format .` && `flutter analyze` && `flutter test` before committing
   - Commit messages: `<type>(<scope>): <description>`
8. **Create PR** with title `<Title> (#<N>)` and body `Closes #<N>`:
   ```bash
   gh pr create --repo Arvoldek/until --title "Fix login crash on startup (#42)" --body "Closes #42\n\n<description>"
   ```
9. **Status auto-moves** to Review → Merge → Done. No manual Status changes needed.
10. **Report:** PR URL, issue number, what was done.

### Flow 2: "Work on issue #N" (specific issue)

1. **Fetch the issue:** `gh issue view N --repo Arvoldek/until`
2. **Check if it's in the project.** If not, add it:
   ```bash
   ISSUE_NODE_ID=$(gh issue view N --repo Arvoldek/until --json node_id -q .node_id)
   gh api graphql -f query="mutation {
     addProjectV2ItemById(input: {projectId: \"PVT_kwHOAfdJeM4BnX_0\", contentId: \"$ISSUE_NODE_ID\"}) {
       item { id }
     }
   }"
   ```
3. **Check current Status.** If already Done, warn the user. If already In Progress, skip to step 6.
4. **Set Status → In Progress.**
5. **Set Priority and Work Type** if missing (defaults: Medium, Task).
6. **Create a branch** following the [naming convention](#branch-naming-convention), then implement, test, commit. Follow the [Flutter Coding Guidelines](../../../AGENTS.md#flutter-coding-guidelines) in AGENTS.md.
7. **Create PR** with title `<Title> (#<N>)` and body `Closes #<N>`.
8. **Report results.**

### Flow 3: "Create an issue for X" (create only, don't work on it)

1. **Create the issue:**
   ```bash
   gh issue create --repo Arvoldek/until --title "<title>" --body "<description>"
   ```
2. **Auto-added to project** with Status = Backlog (via workflow).
3. **Set Work Type** based on the request:
   - Bug report → Work Type = Bug, Priority = High (or ask)
   - Feature request → Work Type = Feature, Priority = Medium
   - General task → Work Type = Task, Priority = Medium
   - Large initiative → Work Type = Epic, Priority = Medium
4. **Do NOT set Status to In Progress.** Leave it in Backlog.
5. **Do NOT create a branch or PR.**
6. **Report:** Issue number, URL, current Status (Backlog), Priority, Work Type.

### Flow 4: "Create a bug/feature/task for X"

Same as Flow 3, but infer the Work Type from the user's wording:
- "bug", "fix", "broken", "crash", "error" → Work Type = Bug
- "feature", "add", "implement", "new" → Work Type = Feature
- "task", "chore", "refactor", "cleanup" → Work Type = Task
- "epic", "initiative", "project" → Work Type = Epic

Set Priority based on urgency words:
- "urgent", "critical", "asap", "blocker" → High
- "soon", "important" → Medium
- "someday", "nice to have", "low priority" → Low

### Flow 5: "Show me the board" / "What's in Backlog?" / "What's the status?"

Read-only. Query the project and present a summary:

```bash
gh api graphql -f query='query {
  node(id: "PVT_kwHOAfdJeM4BnX_0") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          content { ... on Issue { number title url } ... on PullRequest { number title url } }
          fieldValueByName(name: "Status") { ... on ProjectV2ItemFieldSingleSelectValue { name } }
          fieldValueByName(name: "Priority") { ... on ProjectV2ItemFieldSingleSelectValue { name } }
          fieldValueByName(name: "Work Type") { ... on ProjectV2ItemFieldSingleSelectValue { name } }
        }
      }
    }
  }
}'
```

Group by Status and present as a table. Highlight High priority items.

### Flow 6: "Move issue #N to In Progress" (status change only)

1. **Find the project item** for issue #N (see [Find Item](#find-item) below).
2. **Set Status → In Progress.**
3. **Report.**

### Flow 7: "I'm done with #N" / "Finish #N" / "Complete #N"

1. **Check if a PR exists** for issue #N:
   ```bash
   gh pr list --repo Arvoldek/until --search "linked:#N"
   ```
2. **If no PR exists:** Ask the user if they want to create one, or just close the issue.
3. **If PR exists but not merged:** Tell the user the PR needs to be merged first. Provide the PR URL.
4. **If PR is merged:** Status should already be Done (auto). Verify and report.
5. **If the user wants to close without a PR:** `gh issue close N --repo Arvoldek/until` → Status auto-moves to Done.

### Flow 8: "Close issue #N"

```bash
gh issue close N --repo Arvoldek/until --comment "Closing: <reason>"
```

Status auto-moves to Done. Report.

### Flow 9: "Update issue #N" / "Set priority of #N to High"

1. **Find the project item** for issue #N.
2. **Update the requested field(s)** (Priority, Work Type, or Status if automation doesn't cover it).
3. **Report what changed.**

### Flow 10: "Create a PR for #N" (PR only, code is ready)

1. **Check if a branch exists** for this issue (following the [naming convention](#branch-naming-convention)). If not, create one.
2. **Check if a PR already exists.** If yes, report the existing PR URL. Do not create a duplicate.
3. **Create the PR** with title `<Title> (#<N>)` and body `Closes #<N>`:
   ```bash
   gh pr create --repo Arvoldek/until --title "Fix login crash on startup (#42)" --body "Closes #42\n\n<description>"
   ```
4. **Status auto-moves** to Review.
5. **Report PR URL.**

---

## Helper: Generate Branch Name

```bash
# Generate a branch name from issue number, work type, and title
generate_branch() {
  local issue_num="$1"
  local work_type="$2"  # Bug, Feature, Task, Epic
  local title="$3"

  # Map Work Type to branch prefix
  local prefix
  case "$work_type" in
    Bug)     prefix="bug" ;;
    Feature) prefix="feature" ;;
    Task)    prefix="task" ;;
    Epic)    prefix="epic" ;;
    *)       prefix="task" ;;
  esac

  # Convert title to lowercase, replace spaces with hyphens, keep only alphanumeric and hyphens
  local desc=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr ' ' '-' | cut -c1-40 | sed 's/-*$//')

  echo "${prefix}/issue-${issue_num}-${desc}"
}

# Examples:
# generate_branch 42 "Bug" "Fix login crash on startup"     → bug/issue-42-fix-login-crash-on-startup
# generate_branch 15 "Feature" "Add dark mode support"     → feature/issue-15-add-dark-mode-support
# generate_branch 8 "Task" "Refactor auth service"         → task/issue-8-refactor-auth-service
```

## Helper: Set Field

```bash
# Set a single-select field on a project item
set_field() {
  local item_id="$1"
  local field_id="$2"
  local option_id="$3"

  gh api graphql -f query="mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: \"PVT_kwHOAfdJeM4BnX_0\"
      itemId: \"$item_id\"
      fieldId: \"$field_id\"
      value: { singleSelectOptionId: \"$option_id\" }
    }) { projectV2Item { id } }
  }"
}

# Examples:
# set_field "PVTI_xxx" "PVTSSF_lAHOAfdJeM4BnX_0zhl864c" "5c2fd214"  # Status → In Progress
# set_field "PVTI_xxx" "PVTSSF_lAHOAfdJeM4BnX_0zhl87AM" "6db3435a"  # Priority → High
# set_field "PVTI_xxx" "PVTSSF_lAHOAfdJeM4BnX_0zhl87I0" "9b1750a6"  # Work Type → Bug
```

## Helper: Find Item

Find the project item ID for a given issue/PR number:

```bash
find_item() {
  local issue_num="$1"

  gh api graphql -f query="query {
    node(id: \"PVT_kwHOAfdJeM4BnX_0\") {
      ... on ProjectV2 {
        items(first: 100) {
          nodes {
            id
            content {
              ... on Issue { number }
              ... on PullRequest { number }
            }
          }
        }
      }
    }
  }" | jq -r --arg n "$issue_num" '.data.node.items.nodes[] | select(.content.number == ($n | tonumber)) | .id'
}

# Usage:
# ITEM_ID=$(find_item 42)
# set_field "$ITEM_ID" "PVTSSF_lAHOAfdJeM4BnX_0zhl864c" "5c2fd214"  # → In Progress
```

---

## Edge Cases

| Situation | Handling |
|-----------|----------|
| Issue not in project | Add it first with `addProjectV2ItemById`, then proceed |
| Issue already Done | Warn the user before doing anything |
| Issue already In Progress | Skip the Status change, go straight to implementation |
| PR already exists for issue | Do not create a duplicate. Report the existing PR |
| No Backlog items | Tell the user, offer to create a new issue |
| Missing Priority | Default to Medium |
| Missing Work Type | Default to Task (or Bug if it's a bug report) |
| Branch already exists | Reuse it, or ask the user |
| Branch name doesn't match convention | Rename it: `git branch -m <old> <new>` using `generate_branch` |
| Work Type changed after branch creation | Rename branch to match new Work Type prefix |
| Working on main directly | Stop. Create a branch first following the convention |
| User says "create but don't work on it" | Create issue, set fields, leave in Backlog. No branch, no PR |
| User says "just move to In Progress" | Only change Status. No code changes |
| Token missing `project` scope | Run `gh auth refresh -s project` |
| PR merged but issue still open | Close the issue: `gh issue close N` |
| Issue closed but PR still open | Check if PR should be merged or closed |

## Token Setup

```bash
# Required for project operations
gh auth refresh -s project

# Verify
gh auth status
```
