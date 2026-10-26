/// App-wide theme configuration following Apple Human Interface Guidelines.
///
/// Provides light and dark [CupertinoThemeData] definitions with adaptive
/// system colors, iOS typography styles, and accessibility support.
///
/// Reference: https://developer.apple.com/design/human-interface-guidelines
library;

import 'package:cupertino_ui/cupertino_ui.dart';

/// Typography styles following Apple HIG text styles.
///
/// Each style uses the SF Pro system font (via [CupertinoSystemText] /
/// [CupertinoSystemDisplay]) and adaptive label colors so they respond to
/// Dynamic Type, bold text, and increased-contrast settings.
///
/// Reference: https://developer.apple.com/design/human-interface-guidelines/typography
abstract final class AppTextStyles {
  // -- Large Title -----------------------------------------------------------

  /// Large title style — 34pt, bold, used for prominent page titles.
  static const TextStyle largeTitle = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemDisplay',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.38,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Title 1 ---------------------------------------------------------------

  /// Title 1 style — 28pt, regular, used for primary page titles.
  static const TextStyle title1 = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemDisplay',
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.36,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Title 2 ---------------------------------------------------------------

  /// Title 2 style — 22pt, regular, used for secondary page titles.
  static const TextStyle title2 = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemDisplay',
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.35,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Title 3 ---------------------------------------------------------------

  /// Title 3 style — 20pt, regular, used for tertiary headings.
  static const TextStyle title3 = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.38,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Headline --------------------------------------------------------------

  /// Headline style — 17pt, semibold, used for primary content headings.
  static const TextStyle headline = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Body ------------------------------------------------------------------

  /// Body style — 17pt, regular, the default text style for content.
  static const TextStyle body = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Callout ---------------------------------------------------------------

  /// Callout style — 16pt, regular, used for secondary content.
  static const TextStyle callout = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Subheadline -----------------------------------------------------------

  /// Subheadline style — 15pt, regular, used for supporting text.
  static const TextStyle subheadline = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Footnote --------------------------------------------------------------

  /// Footnote style — 13pt, regular, used for fine print and metadata.
  static const TextStyle footnote = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Caption 1 -------------------------------------------------------------

  /// Caption 1 style — 12pt, regular, used for image captions and annotations.
  static const TextStyle caption1 = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );

  // -- Caption 2 -------------------------------------------------------------

  /// Caption 2 style — 11pt, regular, used for the smallest text elements.
  static const TextStyle caption2 = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.06,
    color: CupertinoColors.label,
    decoration: TextDecoration.none,
  );
}

/// Light theme following Apple HIG.
///
/// Uses adaptive [CupertinoDynamicColor] values so colors automatically respond
/// to increased-contrast and other accessibility settings. The [brightness] is
/// intentionally left null so [CupertinoApp] falls back to the system
/// brightness via [MediaQuery.platformBrightnessOf].
const CupertinoThemeData lightTheme = CupertinoThemeData(
  primaryColor: CupertinoColors.systemPurple,
  primaryContrastingColor: CupertinoColors.white,
  barBackgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0xF0F9F9F9),
    darkColor: Color(0xF01D1D1D),
  ),
  scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
  selectionHandleColor: CupertinoColors.systemPurple,
  textTheme: CupertinoTextThemeData(
    primaryColor: CupertinoColors.systemPurple,
    textStyle: AppTextStyles.body,
    actionTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 17,
      letterSpacing: -0.41,
      color: CupertinoColors.systemPurple,
      decoration: TextDecoration.none,
    ),
    actionSmallTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 15,
      letterSpacing: -0.23,
      color: CupertinoColors.systemPurple,
      decoration: TextDecoration.none,
    ),
    tabLabelTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.24,
      color: CupertinoColors.inactiveGray,
      decoration: TextDecoration.none,
    ),
    navTitleTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
      color: CupertinoColors.label,
      decoration: TextDecoration.none,
    ),
    navLargeTitleTextStyle: AppTextStyles.largeTitle,
    navActionTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 17,
      letterSpacing: -0.41,
      color: CupertinoColors.systemPurple,
      decoration: TextDecoration.none,
    ),
    pickerTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemDisplay',
      fontSize: 21,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.6,
      color: CupertinoColors.label,
      decoration: TextDecoration.none,
    ),
    dateTimePickerTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemDisplay',
      fontSize: 21,
      letterSpacing: 0.4,
      fontWeight: FontWeight.normal,
      color: CupertinoColors.label,
      decoration: TextDecoration.none,
    ),
  ),
);

/// Dark theme following Apple HIG.
///
/// Uses the same adaptive [CupertinoDynamicColor] values as [lightTheme] —
/// the dynamic colors resolve differently in dark mode. The [brightness] is
/// intentionally left null so [CupertinoApp] falls back to the system
/// brightness via [MediaQuery.platformBrightnessOf].
const CupertinoThemeData darkTheme = CupertinoThemeData(
  primaryColor: CupertinoColors.systemPurple,
  primaryContrastingColor: CupertinoColors.white,
  barBackgroundColor: CupertinoDynamicColor.withBrightness(
    color: Color(0xF0F9F9F9),
    darkColor: Color(0xF01D1D1D),
  ),
  scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
  selectionHandleColor: CupertinoColors.systemPurple,
  textTheme: CupertinoTextThemeData(
    primaryColor: CupertinoColors.systemPurple,
    textStyle: AppTextStyles.body,
    actionTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 17,
      letterSpacing: -0.41,
      color: CupertinoColors.systemPurple,
      decoration: TextDecoration.none,
    ),
    actionSmallTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 15,
      letterSpacing: -0.23,
      color: CupertinoColors.systemPurple,
      decoration: TextDecoration.none,
    ),
    tabLabelTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.24,
      color: CupertinoColors.inactiveGray,
      decoration: TextDecoration.none,
    ),
    navTitleTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.41,
      color: CupertinoColors.label,
      decoration: TextDecoration.none,
    ),
    navLargeTitleTextStyle: AppTextStyles.largeTitle,
    navActionTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemText',
      fontSize: 17,
      letterSpacing: -0.41,
      color: CupertinoColors.systemPurple,
      decoration: TextDecoration.none,
    ),
    pickerTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemDisplay',
      fontSize: 21,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.6,
      color: CupertinoColors.label,
      decoration: TextDecoration.none,
    ),
    dateTimePickerTextStyle: TextStyle(
      inherit: false,
      fontFamily: 'CupertinoSystemDisplay',
      fontSize: 21,
      letterSpacing: 0.4,
      fontWeight: FontWeight.normal,
      color: CupertinoColors.label,
      decoration: TextDecoration.none,
    ),
  ),
);
