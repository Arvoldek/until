---
name: implement-issue
description: >-
  Multi-agent "implement issue" workflow for the Until Flutter app. Load this
  skill whenever the user asks to implement something, add a feature, fix a bug,
  or work on a GitHub issue in this project (e.g. "implement issue #5", "add
  dark mode", "work on #12"). It orchestrates three subagents defined in
  .vibe/agents/: analyzer (fetches the issue from GitHub, analyzes the app,
  writes a file-level plan; high effort), coder (implements the plan; medium
  effort), reviewer (reviews against acceptance criteria, AGENTS.md and
  docs/design-guidelines.md; high effort; up to 4 fix loops), then commits,
  pushes, and opens the PR.
user-invocable: true
---

# Implement Issue — multi-agent workflow

Repo: `Arvoldek/until`. Project board: "Until Development" (`PVT_kwHOAfdJeM4BnX_0`).
See `.vibe/skills/project-workflow/SKILL.md` for board field IDs and helpers.

## The three agents (`.vibe/agents/`)

| Agent | config_name | Model alias (effort) | Role | Report format |
|-------|-------------|----------------------|------|----------------|
| Analyzer | `analyzer` | `until-analyzer` (high) | Read-only. Fetches issue from GitHub, analyzes app state, produces plan | `ANALYZER REPORT — issue #N` |
| Coder | `coder` | `until-coder` (medium) | Implements the plan, runs format/analyze/test | `CODER DONE — loop <n>` |
| Reviewer | `reviewer` | `until-reviewer` (high) | Read-only. Reviews vs acceptance criteria + guidelines, runs tests | `REVIEW — loop <n>` + `VERDICT: APPROVED \| CHANGES_REQUESTED` |

## Agent communication protocol (critical)

- Spawn with `tools.agents.spawn({ name, message, config_name })`. **Names are unique for the whole session and cannot be reused** — use `analyzer-1`, `coder-1`, `reviewer-1`, `reviewer-2`, ...
- Each agent reports its deliverable by calling `tools.agents.send_message({ agent_path: "/root", message: "..." })`. That message **arrives as your next input**.
- After spawning an agent, **end your turn** (or call `wait`) — do NOT spawn the next agent until the previous agent's report arrives as a new message. One active agent at a time.
- Keep a `todo` list with the pipeline steps so progress is visible.
- If an agent seems stuck, check `tools.agents.list()`; you may `tools.agents.interrupt` a child. If a report never arrives and the child is idle/failed, report the blocker to the user and stop.

## Pipeline

### Step 1 — Parse the request, get an issue
- Extract the issue number if the user gave one (`#5`, `issue 12`). Include the user's original wording in the analyzer's spawn message.
- If there is no issue yet, create one first:
  ```bash
  gh issue create --repo Arvoldek/until --title "<title>" --body "<description from the user's request>"
  ```
  (auto-added to the project board in Backlog). Infer Work Type from the wording (bug/fix → Bug, feature/add/implement → Feature, refactor/chore → Task) and set Work Type + Priority (default Medium) via the project board API.

### Step 2 — Board status + branch prep (you do this, not the agents)
1. Find the project item for the issue and set **Status → In Progress**:
   ```bash
   ITEM_ID=$(gh api graphql -f query='query {
     node(id: "PVT_kwHOAfdJeM4BnX_0") { ... on ProjectV2 {
       items(first: 100) { nodes { id content { ... on Issue { number } ... on PullRequest { number } } } } } } }' \
     | jq -r --arg n "<N>" '.data.node.items.nodes[] | select(.content.number == ($n|tonumber)) | .id')
   gh api graphql -f query="mutation {
     updateProjectV2ItemFieldValue(input: { projectId: \"PVT_kwHOAfdJeM4BnX_0\", itemId: \"$ITEM_ID\",
       fieldId: \"PVTSSF_lAHOAfdJeM4BnX_0zhl864c\", value: { singleSelectOptionId: \"5c2fd214\" } }) { projectV2Item { id } } }"
   ```
   Ensure Priority (`PVTSSF_lAHOAfdJeM4BnX_0zhl87AM`) and Work Type (`PVTSSF_lAHOAfdJeM4BnX_0zhl87I0`) are set.
2. `git checkout main && git pull` (do NOT create the branch yet — the analyzer's report determines the exact name).

### Step 3 — Spawn the analyzer
```ts
await tools.agents.spawn({
  name: "analyzer-1",
  config_name: "analyzer",
  message: "Implement issue #<N> in the Until Flutter app. User request: \"<original wording>\". Fetch the issue from GitHub (gh issue view <N> --repo Arvoldek/until), analyze the current app state, and send back the ANALYZER REPORT as instructed.",
});
```
End your turn. Wait for `ANALYZER REPORT — issue #N`.

### Step 4 — Create the branch from the report
Parse `WORK TYPE` and `BRANCH` from the report. Then:
```bash
git checkout main && git pull
git checkout -b <BRANCH>   # e.g. feature/issue-5-add-dark-mode
```

### Step 5 — Spawn the coder
```ts
await tools.agents.spawn({
  name: "coder-1",
  config_name: "coder",
  message: "Implement the following plan in the Until Flutter app. The branch is already created and checked out; work directly in the repo. Do not commit or push.\n\n<full ANALYZER REPORT text>",
});
```
End your turn. Wait for `CODER DONE — loop 1`.

### Step 6 — Review loop (max 4 iterations)
For `i = 1..4`:
1. Spawn a **fresh** reviewer (names cannot be reused):
   ```ts
   await tools.agents.spawn({
     name: `reviewer-${i}`,
     config_name: "reviewer",
     message: "Review loop <i> of the implementation of issue #<N>. The coder's changes are uncommitted in the working tree.\n\nANALYZER REPORT:\n<full ANALYZER REPORT>\n\nCODER DONE (latest):\n<latest CODER DONE message>",
   });
   ```
   End your turn. Wait for `REVIEW — loop <i>`.
2. If `VERDICT: APPROVED` → go to Step 7.
3. If `VERDICT: CHANGES_REQUESTED` and `i < 4` → send the issues back to the coder:
   ```ts
   await tools.agents.send_message({
     agent_path: "/root/coder-1",
     message: "The reviewer requested changes (loop <i>). Fix ALL issues below, re-run dart format / flutter analyze / flutter test, then send an updated CODER DONE — loop <i+1>.\n\n<full REVIEW message with the ISSUES list>",
   });
   ```
   End your turn. Wait for `CODER DONE — loop <i+1>`, then continue the loop with the next reviewer.
4. If `i == 4` and still `CHANGES_REQUESTED` → **stop**: summarize the remaining issues for the user, do NOT create the PR.

### Step 7 — Commit, push, open the PR
1. Run the pre-commit checklist yourself:
   ```bash
   dart format .
   flutter analyze
   flutter test
   ```
   All must pass. If anything fails, send it back to the coder as a final fix loop (send_message to `/root/coder-1`).
2. Commit on the feature branch:
   ```bash
   git add -A
   git commit -m "<type>(<scope>): <short description>

   Generated by Mistral Vibe.
   Co-Authored-By: Mistral Vibe <vibe@mistral.ai>"
   ```
   `<type>` matches the Work Type (feat/fix/refactor/... per AGENTS.md commit conventions).
3. Push the feature branch once and create the PR:
   ```bash
   git push -u origin <BRANCH>
   gh pr create --repo Arvoldek/until --title "<Title Case description> (#<N>)" --body "Closes #<N>

<summary of what was implemented, from the ANALYZER REPORT + CODER DONE>"
   ```
   The board automation moves the item to Review automatically.

### Step 8 — Report to the user
PR URL, issue number, branch, what the analyzer planned, what the coder implemented, the review history (each loop's verdict), and any remaining concerns.

## Failure handling
- Child failed (`tools.agents.list` shows `status: "failed"`): report the error to the user and stop.
- No report arrives: check `tools.agents.list`; interrupt the child if running, then report the blocker.
- User interrupts mid-pipeline: summarize current state (which step, which loop) so work can resume.
