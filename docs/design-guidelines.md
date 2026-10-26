# Design Guidelines — Until

Design rules for agents building UI in this app. The app targets a native iOS
look and feel using Apple's Human Interface Guidelines (HIG).

Reference: https://developer.apple.com/design/human-interface-guidelines

---

## Design System

Use **Cupertino** via the standalone `cupertino_ui` package. Never import
`package:flutter/cupertino.dart` (frozen/deprecated) or use Material widgets
for iOS UI.

```dart
// Do
import 'package:cupertino_ui/cupertino_ui.dart';

// Don't
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
```

The app root is `CupertinoApp` (not `MaterialApp`). Theme is configured in
`lib/app/theme.dart` and applied in `lib/app/app.dart`.

---

## Color

Use **adaptive system colors only** — `CupertinoDynamicColor` / `CupertinoColors`.
Never hardcode hex colors. Dynamic colors automatically adapt to light/dark mode
and increased-contrast settings.

```dart
// Do — adaptive system colors
color: CupertinoColors.label,
color: CupertinoColors.secondaryLabel,
color: CupertinoColors.systemBackground,
color: CupertinoColors.systemGroupedBackground,
color: CupertinoColors.systemBlue,
color: CupertinoColors.systemRed,
color: CupertinoColors.separator,

// Don't — hardcoded colors
color: Color(0xFF007AFF),
color: Colors.black,
```

### Semantic color reference

| Purpose | Color |
|---------|-------|
| Primary text | `CupertinoColors.label` |
| Secondary text | `CupertinoColors.secondaryLabel` |
| Tertiary text | `CupertinoColors.tertiaryLabel` |
| Quaternary text | `CupertinoColors.quaternaryLabel` |
| Page background | `CupertinoColors.systemBackground` |
| Grouped background | `CupertinoColors.systemGroupedBackground` |
| Secondary grouped bg | `CupertinoColors.secondarySystemGroupedBackground` |
| Fill | `CupertinoColors.systemFill` |
| Separator | `CupertinoColors.separator` |
| Opaque separator | `CupertinoColors.opaqueSeparator` |
| Placeholder text | `CupertinoColors.placeholderText` |
| Inactive elements | `CupertinoColors.inactiveGray` |
| Destructive actions | `CupertinoColors.destructiveRed` |
| Accent / interactive | `CupertinoColors.activeBlue` (or theme `primaryColor`) |

### Theme colors

The app's accent color is `CupertinoColors.systemPurple`. Access it via
`CupertinoTheme.of(context).primaryColor` — don't hardcode it.

```dart
// Do
final accent = CupertinoTheme.of(context).primaryColor;

// Don't
const accent = CupertinoColors.systemPurple; // duplicates theme config
```

---

## Typography

Use `CupertinoTextThemeData` with iOS text styles. Dynamic Type scaling is
respected automatically when using theme text styles.

### Available text styles

Defined in `lib/app/theme.dart` as `AppTextStyles`:

| Style | Size | Weight | Use |
|-------|------|--------|-----|
| `largeTitle` | 34pt | Bold | Prominent page titles, large headers |
| `title1` | 28pt | Regular | Primary page titles |
| `title2` | 22pt | Regular | Secondary page titles |
| `title3` | 20pt | Regular | Tertiary headings |
| `headline` | 17pt | Semibold | Primary content headings |
| `body` | 17pt | Regular | Default text, paragraphs |
| `callout` | 16pt | Regular | Secondary content |
| `subheadline` | 15pt | Regular | Supporting text, metadata |
| `footnote` | 13pt | Regular | Fine print |
| `caption1` | 12pt | Regular | Image captions, annotations |
| `caption2` | 11pt | Regular | Smallest text elements |

### Usage

```dart
// Do — use theme text styles (adapts to Dynamic Type, bold text, contrast)
Text('Hello', style: CupertinoTheme.of(context).textTheme.textStyle);
Text('Title', style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle);

// Do — use AppTextStyles for custom text
Text('Section header', style: AppTextStyles.headline);

// Don't — hardcode font sizes or use default Text without style
Text('Hello'); // inherits, but be explicit for design-critical text
Text('Hello', style: TextStyle(fontSize: 17)); // ignores Dynamic Type
```

### Fonts

Text styles use SF Pro system fonts:
- `CupertinoSystemText` — body text, UI labels
- `CupertinoSystemDisplay` — large titles, picker text

Never specify a custom `fontFamily` — let the system font handle Dynamic Type.

---

## Layout & Navigation

Follow iOS layout patterns:

### Safe areas

Always wrap content in `SafeArea` or use `CupertinoPageScaffold` (which handles
it). Never let content go under the notch, home indicator, or tab bar.

```dart
// Do
CupertinoPageScaffold(
  navigationBar: CupertinoNavigationBar(middle: Text('Title')),
  child: SafeArea(child: MyContent()),
)

// Don't — content may go under system UI
Scaffold(body: MyContent())
```

### Navigation bars

Use `CupertinoNavigationBar` for standard navigation. Use
`CupertinoSliverNavigationBar` for large-title scrolling pages.

```dart
// Do — standard nav bar
CupertinoNavigationBar(
  middle: Text('Page Title'),
  trailing: CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: _onAdd,
    child: Icon(CupertinoIcons.add),
  ),
)

// Do — large title (scrolls with content)
CustomScrollView(
  slivers: [
    CupertinoSliverNavigationBar(largeTitle: Text('Home')),
    SliverList(...),
  ],
)
```

### Lists

Use `CupertinoListSection` (inset grouped) and `CupertinoListTile` for settings-
style lists. Use `CupertinoScrollbar` for long scrollable content.

```dart
// Do — inset grouped list
CupertinoListSection.insetGrouped(
  header: Text('Settings'),
  children: [
    CupertinoListTile(
      title: Text('Notifications'),
      trailing: CupertinoSwitch(value: true, onChanged: (_) {}),
      onTap: _onTap,
    ),
  ],
)
```

### Tab bars

Use `CupertinoTabScaffold` with `CupertinoTabBar` for bottom tab navigation.

```dart
// Do
CupertinoTabScaffold(
  tabBar: CupertinoTabBar(
    items: [
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
    ],
  ),
  tabBuilder: (context, index) => CupertinoTabView(
    builder: (context) => _pages[index],
  ),
)
```

### Sheets

Use `showCupertinoModalPopup` for action sheets and modal popups.
Use `showCupertinoSheet` (via `CupertinoSheetRoute`) for bottom sheets.

```dart
// Do — action sheet
showCupertinoModalPopup(
  context: context,
  builder: (context) => CupertinoActionSheet(
    actions: [
      CupertinoActionSheetAction(
        onPressed: _onEdit,
        child: Text('Edit'),
      ),
      CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: _onDelete,
        child: Text('Delete'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      onPressed: () => Navigator.pop(context),
      child: Text('Cancel'),
    ),
  ),
)
```

### Tap targets

Minimum **44x44 pt** tap target for all interactive elements. Use
`CupertinoButton` with adequate padding, or wrap small tappable elements.

```dart
// Do — adequate tap target
CupertinoButton(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  onPressed: _onTap,
  child: Text('Tap me'),
)

// Don't — too small
GestureDetector(
  onTap: _onTap,
  child: Icon(CupertinoIcons.add), // 24pt icon, no padding
)
```

---

## Components

Which Cupertino widget to use for what:

| Need | Widget |
|------|--------|
| Primary action button | `CupertinoButton.filled` |
| Secondary action button | `CupertinoButton` (plain) |
| Tinted button | `CupertinoButton.tinted` |
| Destructive button | `CupertinoButton` with `color: CupertinoColors.destructiveRed` |
| Toggle | `CupertinoSwitch` |
| Single choice | `CupertinoSlidingSegmentedControl` or `CupertinoSegmentedControl` |
| Radio selection | `CupertinoRadio` |
| Checkbox | `CupertinoCheckbox` |
| Slider | `CupertinoSlider` |
| Text input | `CupertinoTextField` |
| Search input | `CupertinoSearchTextField` |
| Multi-line input | `CupertinoTextField(maxLines: ...)` |
| Date picker | `CupertinoDatePicker` |
| Time picker | `CupertinoTimerPicker` |
| Scrolling picker | `CupertinoPicker` |
| Alert dialog | `CupertinoAlertDialog` |
| Action sheet | `CupertinoActionSheet` |
| Context menu | `CupertinoContextMenu` |
| Loading indicator | `CupertinoActivityIndicator` |
| Progress bar (linear) | `CupertinoLinearActivityIndicator` |
| Pull to refresh | `CupertinoSliverRefreshControl` |
| Form rows | `CupertinoFormRow`, `CupertinoFormSection` |
| Expansion | `CupertinoExpansionTile` |
| Scrollbar | `CupertinoScrollbar` |

### Examples

```dart
// Button
CupertinoButton.filled(
  onPressed: _onSave,
  child: Text('Save'),
)

// Switch
CupertinoSwitch(value: _enabled, onChanged: (v) => setState(() => _enabled = v))

// Slider
CupertinoSlider(value: _volume, onChanged: (v) => setState(() => _volume = v))

// Text field
CupertinoTextField(
  placeholder: 'Enter your name',
  controller: _nameController,
)

// Alert dialog
showCupertinoDialog(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: Text('Delete Item?'),
    content: Text('This cannot be undone.'),
    actions: [
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: _onDelete,
        child: Text('Delete'),
      ),
    ],
  ),
)
```

---

## Motion

Use iOS-style transitions and easing. The `cupertino_ui` package provides
`CupertinoPageRoute` and `CupertinoSheetRoute` with the correct default
transitions — prefer these over custom transitions.

```dart
// Do — iOS page transition
Navigator.push(context, CupertinoPageRoute(builder: (context) => NextPage()));

// Do — modal sheet
showCupertinoModalPopup(context: context, builder: (context) => MySheet());

// Don't — Material transitions
Navigator.push(context, MaterialPageRoute(builder: (context) => NextPage()));
```

### Reduce motion

Respect the system reduce-motion setting. Check
`MediaQuery.disableAnimationsOf(context)` before adding custom animations.

```dart
// Do — respect reduce motion
final reduceMotion = MediaQuery.disableAnimationsOf(context);
AnimatedContainer(
  duration: reduceMotion ? Duration.zero : Duration(milliseconds: 300),
  // ...
)
```

---

## Accessibility

- **VoiceOver:** Add `semanticsLabel` to icon-only buttons and custom widgets.
  Use `ExcludeSemantics` / `MergeSemantics` to control the accessibility tree.
- **Contrast:** Use `CupertinoDynamicColor` values — they adapt to increased
  contrast automatically.
- **Dynamic Type:** Use theme text styles — they scale with the system text size.
- **Bold text:** Use `CupertinoDynamicColor` — bold text is handled by the
  system font weight adjustments.

```dart
// Do — accessible icon button
CupertinoButton(
  onPressed: _onAdd,
  child: Icon(CupertinoIcons.add, semanticLabel: 'Add item'),
)

// Do — accessible custom widget
Semantics(
  label: 'Counter value: $_count',
  child: Text('$_count'),
)

// Don't — missing semantics
CupertinoButton(
  onPressed: _onAdd,
  child: Icon(CupertinoIcons.add), // no semantic label
)
```

---

## Theme Integration

The app theme lives in `lib/app/theme.dart`:

- `lightTheme` / `darkTheme` — `CupertinoThemeData` constants
- `AppTextStyles` — iOS HIG text styles
- Theme is selected in `lib/app/app.dart` via `MediaQuery.platformBrightnessOf`

When building UI, always read colors and text styles from the theme:

```dart
// Do — read from theme
final theme = CupertinoTheme.of(context);
final textTheme = theme.textTheme;
final primaryColor = theme.primaryColor;
final scaffoldBg = theme.scaffoldBackgroundColor;

// Don't — hardcode theme values
Container(color: CupertinoColors.systemPurple)
```

---

## Liquid Glass (iOS 26)

Do **not** hand-roll glass/blur effects. When `cupertino_ui` ships the iOS 26
redesign (expected late 2026), follow the package's components and theme tokens.
Until then, use standard `CupertinoDynamicColor` backgrounds and the existing
theme system.

---

## Quick Checklist

Before committing UI code, verify:

- [ ] Imports `package:cupertino_ui/cupertino_ui.dart` (not `flutter/cupertino.dart` or `flutter/material.dart`)
- [ ] Uses `CupertinoDynamicColor` / `CupertinoColors` — no hardcoded hex colors
- [ ] Uses theme text styles or `AppTextStyles` — no hardcoded font sizes
- [ ] Content is inside `SafeArea` or `CupertinoPageScaffold`
- [ ] Interactive elements have 44x44pt minimum tap targets
- [ ] Icon-only buttons have `semanticLabel`
- [ ] Uses `CupertinoPageRoute` / `CupertinoSheetRoute` for navigation
- [ ] Respects `MediaQuery.disableAnimationsOf` for custom animations
- [ ] Reads colors from `CupertinoTheme.of(context)` where applicable
