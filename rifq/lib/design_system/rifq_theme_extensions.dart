import 'package:flutter/material.dart';

import 'rifq_colors.dart';

/// امتداد ثيم يحمل ألوان «الحديقة» الدلالية التي لا يعبّر عنها [ColorScheme]
/// القياسي — الماء، الحجر، الزيتون، الرمل، الضوء الذهبي، وأسطح الورق.
/// تسحبها الواجهات عبر `Theme.of(context).extension<RifqPalette>()`.
@immutable
class RifqPalette extends ThemeExtension<RifqPalette> {
  const RifqPalette({
    required this.canvas,
    required this.surface,
    required this.deepSurface,
    required this.water,
    required this.sage,
    required this.forest,
    required this.clay,
    required this.sand,
    required this.gold,
    required this.textPrimary,
    required this.textSecondary,
  });

  /// خلفية النهار الدافئة — القاعدة التي يقف عليها المشهد.
  final Color canvas;

  /// سطح ورقي هادئ للبطاقات.
  final Color surface;

  /// سطح أعمق للطبقات الغائرة (ماء عميق، ظل).
  final Color deepSurface;

  /// ماء المرآة.
  final Color water;

  /// أخضر مريمية للنبات الحي.
  final Color sage;

  /// أخضر زيتوني عميق للتفاصيل والنصوص القوية.
  final Color forest;

  /// طين دافئ — لمسة أرضية للأزرار المهمة.
  final Color clay;

  /// رمل الطريق.
  final Color sand;

  /// ضوء ذهبي هادئ للحظات المعنى.
  final Color gold;

  final Color textPrimary;
  final Color textSecondary;

  static const light = RifqPalette(
    canvas: RifqLightColors.canvas,
    surface: RifqLightColors.surface,
    deepSurface: RifqLightColors.sand,
    water: RifqLightColors.water,
    sage: RifqLightColors.sage,
    forest: RifqLightColors.forest,
    clay: RifqLightColors.clay,
    sand: RifqLightColors.sand,
    gold: RifqLightColors.gold,
    textPrimary: RifqLightColors.textPrimary,
    textSecondary: RifqLightColors.textSecondary,
  );

  static const dark = RifqPalette(
    canvas: RifqDarkColors.background,
    surface: RifqDarkColors.surface,
    deepSurface: RifqDarkColors.deepSurface,
    water: RifqDarkColors.water,
    sage: RifqDarkColors.sage,
    forest: RifqDarkColors.sage,
    clay: RifqDarkColors.clay,
    sand: RifqDarkColors.deepSurface,
    gold: RifqDarkColors.gold,
    textPrimary: RifqDarkColors.textPrimary,
    textSecondary: RifqDarkColors.textSecondary,
  );

  /// وصول مختصر مع تراجع آمن للوضع الفاتح لو غاب الامتداد.
  static RifqPalette of(BuildContext context) =>
      Theme.of(context).extension<RifqPalette>() ?? light;

  @override
  RifqPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? deepSurface,
    Color? water,
    Color? sage,
    Color? forest,
    Color? clay,
    Color? sand,
    Color? gold,
    Color? textPrimary,
    Color? textSecondary,
  }) =>
      RifqPalette(
        canvas: canvas ?? this.canvas,
        surface: surface ?? this.surface,
        deepSurface: deepSurface ?? this.deepSurface,
        water: water ?? this.water,
        sage: sage ?? this.sage,
        forest: forest ?? this.forest,
        clay: clay ?? this.clay,
        sand: sand ?? this.sand,
        gold: gold ?? this.gold,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  RifqPalette lerp(ThemeExtension<RifqPalette>? other, double t) {
    if (other is! RifqPalette) return this;
    return RifqPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      deepSurface: Color.lerp(deepSurface, other.deepSurface, t)!,
      water: Color.lerp(water, other.water, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
      forest: Color.lerp(forest, other.forest, t)!,
      clay: Color.lerp(clay, other.clay, t)!,
      sand: Color.lerp(sand, other.sand, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}
