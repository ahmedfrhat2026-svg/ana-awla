import 'package:flutter/material.dart';

import 'rifq_colors.dart';
import 'rifq_motion.dart';
import 'rifq_shapes.dart';
import 'rifq_spacing.dart';
import 'rifq_theme_extensions.dart';
import 'rifq_typography.dart';

/// ثيم رِفْق — حديقة داخلية هادئة: ضوء نهار دافئ، أسطح ورقية، ظلال ناعمة،
/// حركة غير مشتِّتة. كل القيم تأتي من التوكِنز المركزية، بلا ألوان خام مبعثرة.

ThemeData rifqLightTheme() => _build(
      brightness: Brightness.light,
      palette: RifqPalette.light,
      scheme: const ColorScheme.light(
        primary: RifqLightColors.forest,
        onPrimary: RifqLightColors.canvas,
        secondary: RifqLightColors.clay,
        onSecondary: RifqLightColors.canvas,
        surface: RifqLightColors.canvas,
        onSurface: RifqLightColors.textPrimary,
        surfaceContainerHighest: RifqLightColors.surface,
        error: RifqLightColors.error,
        onError: RifqLightColors.canvas,
      ),
    );

ThemeData rifqDarkTheme() => _build(
      brightness: Brightness.dark,
      palette: RifqPalette.dark,
      scheme: const ColorScheme.dark(
        primary: RifqDarkColors.sage,
        onPrimary: RifqDarkColors.deepSurface,
        secondary: RifqDarkColors.clay,
        onSecondary: RifqDarkColors.deepSurface,
        surface: RifqDarkColors.background,
        onSurface: RifqDarkColors.textPrimary,
        surfaceContainerHighest: RifqDarkColors.surface,
        error: RifqDarkColors.error,
        onError: RifqDarkColors.deepSurface,
      ),
    );

ThemeData _build({
  required Brightness brightness,
  required RifqPalette palette,
  required ColorScheme scheme,
}) {
  final baseText = brightness == Brightness.light
      ? Typography.material2021(platform: TargetPlatform.android).black
      : Typography.material2021(platform: TargetPlatform.android).white;
  final textTheme = RifqType.build(
    baseText,
    primary: palette.textPrimary,
    secondary: palette.textSecondary,
  );

  // ظل ناعم جدًا مشتق من الأخضر بدل الأسود القاسي.
  final softShadow = [
    BoxShadow(
      color: palette.forest.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ];

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.canvas,
    fontFamily: 'Cairo',
    extensions: [palette],
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.canvas,
      foregroundColor: palette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      shadowColor: palette.forest.withValues(alpha: 0.06),
      shape: const RoundedRectangleBorder(borderRadius: RifqRadii.large),
      margin: const EdgeInsets.symmetric(vertical: RifqSpacing.xs),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.forest,
        foregroundColor: palette.canvas,
        disabledBackgroundColor: palette.sage.withValues(alpha: 0.4),
        minimumSize: const Size.fromHeight(56),
        shape: const RoundedRectangleBorder(borderRadius: RifqRadii.medium),
        textStyle: textTheme.labelLarge,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.textPrimary,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: palette.sage.withValues(alpha: 0.4)),
        shape: const RoundedRectangleBorder(borderRadius: RifqRadii.medium),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: palette.forest),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.surface,
      selectedColor: palette.sage.withValues(alpha: 0.35),
      side: BorderSide(color: palette.sage.withValues(alpha: 0.25)),
      shape: const RoundedRectangleBorder(borderRadius: RifqRadii.small),
      labelStyle: textTheme.bodyMedium,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: palette.sage,
      inactiveTrackColor: palette.sage.withValues(alpha: 0.2),
      thumbColor: palette.forest,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? palette.forest : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? palette.sage.withValues(alpha: 0.5)
            : null,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: RifqSpacing.md, vertical: RifqSpacing.sm),
      border: const OutlineInputBorder(
        borderRadius: RifqRadii.small,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: RifqRadii.small,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: RifqRadii.small,
        borderSide: BorderSide(color: palette.sage, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(borderRadius: RifqRadii.large),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(RifqRadii.hero)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.forest,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.canvas),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: RifqRadii.small),
    ),
    // حركة هادئة غير مشتِّتة في كل التنقلات.
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    }),
    // ظل مشترك متاح للأسطح المخصّصة عبر الامتداد أدناه.
    splashColor: palette.sage.withValues(alpha: 0.12),
    highlightColor: palette.sage.withValues(alpha: 0.08),
  ).copyWith(
    extensions: [palette, _RifqSurfaceShadow(softShadow)],
  );
}

/// ظل السطح الناعم المشترك — يتيح للبطاقات المخصّصة نفس ظل الثيم.
@immutable
class _RifqSurfaceShadow extends ThemeExtension<_RifqSurfaceShadow> {
  const _RifqSurfaceShadow(this.shadow);
  final List<BoxShadow> shadow;

  @override
  ThemeExtension<_RifqSurfaceShadow> copyWith({List<BoxShadow>? shadow}) =>
      _RifqSurfaceShadow(shadow ?? this.shadow);

  @override
  ThemeExtension<_RifqSurfaceShadow> lerp(
          ThemeExtension<_RifqSurfaceShadow>? other, double t) =>
      this;
}

/// ظل السطح الناعم لرِفْق — للأسطح العضوية المخصّصة.
List<BoxShadow> rifqSoftShadow(BuildContext context) =>
    Theme.of(context).extension<_RifqSurfaceShadow>()?.shadow ??
    [
      BoxShadow(
        color: RifqPalette.of(context).forest.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 6),
      ),
    ];

/// إعادة تصدير مدد الحركة للراحة.
typedef RifqMotionTokens = RifqMotion;
