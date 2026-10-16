# AGENTS.md — Until

Instructions for AI agents working on this repository.

## Project

**Until** — a Flutter application. Repo: `Arvoldek/until`.

## GitHub Project Board

All work is tracked on the **"Until Development"** GitHub Project:

- **URL:** https://github.com/users/Arvoldek/projects/3
- **Repo link:** https://github.com/Arvoldek/until/projects
- **Project ID:** `PVT_kwHOAfdJeM4BnX_0`

### Views

| View | Layout | Use |
|------|--------|-----|
| Kanban Board | Board | Drag cards across columns to track progress |
| All Items | Table | Spreadsheet view with all fields |

### Status Workflow

```
Backlog → In Progress → Review → Merge → Done
  gray      blue        yellow   orange  green
```

| Status | Meaning |
|--------|---------|
| **Backlog** | Not yet started. New issues/PRs land here automatically. |
| **In Progress** | Actively being worked on. |
| **Review** | PR is open and linked, awaiting code review. |
| **Merge** | Review approved, ready to merge. |
| **Done** | Merged or closed. |

### Fields

| Field | Type | Options |
|-------|------|---------|
| **Status** | Single Select | Backlog, In Progress, Review, Merge, Done |
| **Priority** | Single Select | High (red), Medium (yellow), Low (green) |
| **Work Type** | Single Select | Bug (red), Feature (blue), Task (gray), Epic (purple) |

Built-in fields (auto-populated): Title, Assignees, Labels, Milestone, Repository, Reviewers, Linked PRs, Created/Updated/Closed dates.

### Automation (enabled workflows)

The project has 9 automated workflows. Status changes happen automatically:

| Event | Status Change |
|-------|--------------|
| Issue/PR created in repo | Auto-added to project → **Backlog** |
| Item reopened | → **In Progress** |
| PR linked to an issue | → **Review** |
| Code review requests changes | → **In Progress** |
| Code review approved | → **Merge** |
| PR merged | → **Done** |
| Issue/PR closed | → **Done** |
| Sub-issues created | Auto-added to project |

**Do not manually set Status to Done on approval** — it goes to Merge first, then Done on merge/close.

## Working with Issues

### Creating an issue

```bash
# Create an issue (auto-added to project via workflow)
gh issue create --repo Arvoldek/until --title "Fix login bug" --body "Description..."

# Create with labels
gh issue create --repo Arvoldek/until --title "Add dark mode" --label "enhancement,feature"
```

After creation, set the **Priority** and **Work Type** fields on the project board, or via API:

```bash
# Get the issue's node ID
ISSUE_ID=$(gh issue view 1 --repo Arvoldek/until --json node_id -q .node_id)

# Add to project (if not auto-added)
gh api graphql -f query="mutation { addProjectV2ItemById(input: {projectId: \"PVT_kwHOAfdJeM4BnX_0\", contentId: \"$ISSUE_ID\"}) { item { id } } }"
```

### Setting fields via API

```bash
# Field IDs
STATUS_FIELD="PVTSSF_lAHOAfdJeM4BnX_0zhl864c"
PRIORITY_FIELD="PVTSSF_lAHOAfdJeM4BnX_0zhl87AM"
WORKTYPE_FIELD="PVTSSF_lAHOAfdJeM4BnX_0zhl87I0"

# Status option IDs
BACKLOG="d8dbc968"; IN_PROGRESS="5c2fd214"; REVIEW="78ca2799"; MERGE="ff8e3aff"; DONE="a1cce8a7"

# Set Status to In Progress
gh api graphql -f query="mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: \"PVT_kwHOAfdJeM4BnX_0\"
    itemId: \"<ITEM_ID>\"
    fieldId: \"$STATUS_FIELD\"
    value: { singleSelectOptionId: \"$IN_PROGRESS\" }
  }) { projectV2Item { id } }
}"
```

### Finding a project item for an issue/PR

```bash
# List project items and find by issue number
gh api graphql -f query='query {
  node(id: "PVT_kwHOAfdJeM4BnX_0") {
    ... on ProjectV2 {
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue { number title }
            ... on PullRequest { number title }
          }
        }
      }
    }
  }
}'
```

## Pull Request Workflow

1. Create a branch and PR: `gh pr create --repo Arvoldek/until --title "..." --body "Closes #123"`
2. PR is auto-added to project → **Review** (when linked to an issue)
3. Request review; reviewer approves → **Merge**
4. Merge the PR → **Done**

Always link PRs to issues with `Closes #123` or `Fixes #123` in the PR body.

## Token Requirements

The `gh` CLI token needs the `project` scope for project operations:

```bash
gh auth refresh -s project
```

## Project Management Commands

```bash
# View project
gh project view 3 --owner Arvoldek --web

# List project items
gh project item-list 3 --owner Arvoldek

# Add issue/PR to project
gh project item-add 3 --owner Arvoldek --url https://github.com/Arvoldek/until/issues/1

# Edit item fields
gh project item-edit 3 --owner Arvoldek --id <ITEM_ID> --field-id Status --single-select-option-id <OPTION_ID>
```
