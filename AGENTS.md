# AGENTS.md — Until

Instructions for AI agents working on this repository.

## Project

**Until** — a Flutter application. Repo: `Arvoldek/until`.

## Flutter Coding Guidelines

All agents writing Dart/Flutter code must follow these guidelines.

### Architecture

Use a **layered, feature-first** architecture:

```
lib/
├── main.dart                  # Entry point only
├── app/                       # App-level: theme, router, DI setup
│   ├── app.dart
│   ├── theme.dart
│   └── router.dart
├── core/                      # Cross-cutting concerns
│   ├── errors/                # Failure types, exceptions
│   ├── network/               # HTTP client, interceptors
│   └── utils/                 # Extensions, helpers, constants
├── shared/                    # Reusable across features
│   ├── widgets/               # Common UI components
│   └── extensions/            # Dart extensions
└── features/                  # One folder per feature
    └── <feature_name>/
        ├── presentation/      # Widgets, screens, pages
        ├── application/       # State management, business logic
        └── data/              # Models, repositories, data sources
```

**Rules:**
- `presentation` depends on `application`, never the reverse
- `application` depends on `data`, never the reverse
- `data` has no Flutter imports (pure Dart)
- Features don't import from other features directly — use `shared/` or `core/`

### State Management

- **Riverpod** for app-wide and feature state (recommended: `flutter_riverpod`)
- **StatefulWidget + setState** only for purely local UI state (e.g., animation controllers, text field focus)
- Keep providers scoped as narrowly as possible (use `ProviderScope` overrides in tests)
- Never store BuildContext in providers or state objects

```dart
// Good: Riverpod provider
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// Good: ConsumerWidget for UI
final counter = ref.watch(counterProvider);
```

### Widget Best Practices

- **Prefer `StatelessWidget`** — use `StatefulWidget` only when you need local mutable state
- **Use `const` constructors** everywhere possible — wrap widgets in `const` to prevent unnecessary rebuilds
- **Extract widgets** into separate files when a `build` method exceeds ~50 lines or a widget is reused
- **Use `Key`** for items in lists (`ValueKey`, `ObjectKey`) to preserve state across reorders
- **Avoid deep widget trees** — compose small, single-purpose widgets
- **Use `LayoutBuilder`** for responsive layouts, not `MediaQuery` size checks everywhere

```dart
// Good: const constructor
class MyCard extends StatelessWidget {
  const MyCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8), // const padding
        child: Text(title),
      ),
    );
  }
}
```

### Dart Style

- Follow [Effective Dart](https://dart.dev/effective-dart)
- **Single quotes** for strings (enforced by `flutter_lints`)
- **Trailing commas** in multi-line argument lists (enables better formatting)
- **`final`** for variables that don't change, **`const`** for compile-time constants
- **Naming:** `camelCase` for variables/functions, `PascalCase` for classes, `snake_case` for files
- File names: `snake_case.dart` (e.g., `user_profile_page.dart`)

### Async Programming

- **Always handle Futures** — never fire-and-forget without `.catchError` or `try/catch`
- Use `async/await` over raw `.then()` chains
- For streams, use `StreamProvider`/`StreamBuilder` or `ref.listen`
- Cancel subscriptions in `dispose()`

```dart
// Good
try {
  final user = await userRepository.fetchUser(id);
  return user;
} catch (e) {
  return null; // or handle error properly
}

// Bad — unhandled Future
userRepository.fetchUser(id); // missing await
```

### Error Handling

- Use a **Result/Failure pattern** for operations that can fail (e.g., network calls)
- Never silently swallow errors with empty `catch` blocks
- Define typed failures in `core/errors/`

```dart
// Good: sealed class for results
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final String error;
}

// Usage with pattern matching
final result = await repo.fetchData();
switch (result) {
  case Success(:final value):
    // handle success
  case Failure(:final error):
    // handle error
}
```

### Immutability & Data Classes

- Make **data classes immutable** (all fields `final`)
- Use **`copyWith`** for creating modified copies
- Use **`Equatable`** (or `freezed`) for value equality in state classes
- Use **`freezed`** or **`json_serializable`** for models with JSON serialization

```dart
// Good: immutable data class
class User {
  const User({required this.id, required this.name});

  final String id;
  final String name;

  User copyWith({String? name}) => User(id: id, name: name ?? this.name);

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

### Testing

- **Unit tests** for business logic in `application/` and `data/`
- **Widget tests** for UI components in `presentation/`
- **Integration tests** for critical user flows
- Run `flutter test` before committing
- Aim for meaningful tests, not just coverage numbers

```dart
// test/features/counter/application/counter_notifier_test.dart
void main() {
  group('CounterNotifier', () {
    test('increments value', () {
      final notifier = CounterNotifier();
      notifier.increment();
      expect(notifier.state, 1);
    });
  });
}
```

### Performance

- Use **`const`** constructors aggressively — they prevent rebuilds
- Use **`ListView.builder`** (not `ListView`) for long or dynamic lists
- Use **`RepaintBoundary`** around complex widgets that don't change often
- Avoid `setState` on large widget trees — use fine-grained providers
- Profile with **Flutter DevTools** before optimizing

### Documentation

- Add **`///` doc comments** for all public classes, methods, and fields
- Document **why**, not just what
- Keep README updated for each feature

```dart
/// Fetches a user by their unique [id].
///
/// Returns a [User] on success, or throws a [UserNotFoundException]
/// if no user exists with the given [id].
Future<User> fetchUser(String id) async { ... }
```

### Pre-Commit Checklist

Before committing, always run:

```bash
# Format code
dart format .

# Analyze for issues
flutter analyze

# Run tests
flutter test

# All must pass with zero issues before committing
```

### Commit Messages

```
<type>(<scope>): <short description>

<optional body>

<optional footer>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`

Examples:
```
feat(auth): add login screen with email/password
fix(profile): resolve crash when avatar fails to load
refactor(home): extract widget into separate file
test(auth): add unit tests for login notifier
```

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

## Branch Naming Convention

All branches must follow this format:

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
- Always include the issue number (`issue-<N>`)
- Type must match the **Work Type** field on the project board
- Lowercase only, hyphens as separators (no spaces, no underscores)
- Short description: 3–5 words derived from the issue title
- Create the branch from `main`

```bash
# Example: working on issue #42 (a bug titled "Fix login crash on startup")
git checkout main && git pull
git checkout -b bug/issue-42-fix-login-crash
```

## Pull Request Workflow

1. Create a branch following the [naming convention](#branch-naming-convention)
2. Implement, test, commit
3. Create PR: `gh pr create --repo Arvoldek/until --title "..." --body "Closes #123"`
4. PR is auto-added to project → **Review** (when linked to an issue)
5. Request review; reviewer approves → **Merge**
6. Merge the PR → **Done**

**PR title convention:** Same as branch description, e.g. `Fix login crash on startup (#42)`

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
