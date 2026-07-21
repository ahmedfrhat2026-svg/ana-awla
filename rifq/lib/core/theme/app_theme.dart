import 'package:flutter/material.dart';

/// هوية رِفْق البصرية: عاجي دافئ، أخضر زيتوني هادئ، رملي، نص فحمي.
/// مساحات واسعة، زوايا دائرية، بلا صخب وبلا Badges حمراء.
class RifqColors {
  static const ivory = Color(0xFFFAF6EE);
  static const sand = Color(0xFFE8DCC8);
  static const olive = Color(0xFF6B7A52);
  static const oliveDark = Color(0xFF4F5C3D);
  static const charcoal = Color(0xFF33322E);
  static const mist = Color(0xFFF1EBDF);

  // الوضع الداكن: نفس الروح بدرجات أعمق.
  static const nightBg = Color(0xFF23241F);
  static const nightSurface = Color(0xFF2D2E28);
  static const nightText = Color(0xFFE9E4D8);
}

ThemeData rifqLightTheme() => _base(
      brightness: Brightness.light,
      background: RifqColors.ivory,
      surface: RifqColors.mist,
      text: RifqColors.charcoal,
    );

ThemeData rifqDarkTheme() => _base(
      brightness: Brightness.dark,
      background: RifqColors.nightBg,
      surface: RifqColors.nightSurface,
      text: RifqColors.nightText,
    );

ThemeData _base({
  required Brightness brightness,
  required Color background,
  required Color surface,
  required Color text,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: RifqColors.olive,
    brightness: brightness,
    surface: background,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    // خط Cairo لكل النصوص — عربي وإنجليزي (مضمّن محليًا، رخصة OFL).
    fontFamily: 'Cairo',
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: text,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RifqColors.olive,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: text,
        minimumSize: const Size.fromHeight(52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    // حركة هادئة غير مشتتة في كل التنقلات.
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    }),
    textTheme: (brightness == Brightness.light
            ? Typography.material2021(platform: TargetPlatform.android).black
            : Typography.material2021(platform: TargetPlatform.android).white)
        .apply(bodyColor: text, displayColor: text),
  );
}
