/// تدرّج الطباعة (typography scale) لتطبيق "رِفْق".
///
/// هذا الملف لا يحدّد اسم الخط (fontFamily) — يُفترض ضبط خط "Cairo"
/// عالمياً عبر [ThemeData]. هنا فقط نضبط الأحجام والارتفاعات والأوزان
/// والألوان بما يناسب النص العربي (ارتفاع سطر أكبر لسهولة القراءة).
library;

import 'package:flutter/material.dart';

/// يبني تدرّج طباعة رِفْق فوق [TextTheme] أساسي.
abstract final class RifqType {
  /// يعيد [TextTheme] جديداً مبنياً فوق [base]، بأحجام وارتفاعات وأوزان
  /// وألوان "رِفْق"، مع الحفاظ على اسم الخط والقياسات الأخرى الموروثة
  /// من [base].
  static TextTheme build(
    TextTheme base, {
    required Color primary,
    required Color secondary,
  }) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 34,
        height: 1.25,
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
        color: primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 28,
        height: 1.28,
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
        color: primary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 22,
        height: 1.3,
        fontWeight: FontWeight.w700,
        fontVariations: const [FontVariation('wght', 700)],
        color: primary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 19,
        height: 1.35,
        fontWeight: FontWeight.w600,
        fontVariations: const [FontVariation('wght', 600)],
        color: primary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
        fontVariations: const [FontVariation('wght', 600)],
        color: primary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.7,
        fontWeight: FontWeight.w400,
        fontVariations: const [FontVariation('wght', 400)],
        color: primary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.65,
        fontWeight: FontWeight.w400,
        fontVariations: const [FontVariation('wght', 400)],
        color: primary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w400,
        fontVariations: const [FontVariation('wght', 400)],
        color: secondary,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        height: 1.3,
        fontWeight: FontWeight.w600,
        fontVariations: const [FontVariation('wght', 600)],
        color: primary,
      ),
    );
  }
}
