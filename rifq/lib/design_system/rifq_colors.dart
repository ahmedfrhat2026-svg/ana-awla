/// ألوان "رِفْق" الخام (design tokens).
///
/// هذه القيم أساسية فقط وليست مخصّصة للاستخدام المباشر في الشاشات.
/// يجب أن تعتمد الواجهات على [Theme] و [ColorScheme] الخاصين بالتطبيق،
/// واللذين يُبنيان اعتماداً على هذه الألوان، بدلاً من الإشارة إليها هنا
/// مباشرة. هذا يضمن اتساق المظهر ودعم الوضعين الفاتح والداكن بسهولة.
library;

import 'package:flutter/material.dart';

/// لوحة الألوان الفاتحة (light palette) لتطبيق رِفْق.
abstract final class RifqLightColors {
  static const Color canvas = Color(0xFFF5F1E8);
  static const Color surface = Color(0xFFECE6D9);
  static const Color sage = Color(0xFF708A72);
  static const Color forest = Color(0xFF365646);
  static const Color clay = Color(0xFFC78668);
  static const Color sand = Color(0xFFD8C7A5);
  static const Color textPrimary = Color(0xFF29332E);
  static const Color textSecondary = Color(0xFF647168);
  static const Color water = Color(0xFFA9C8C0);
  static const Color gold = Color(0xFFD4B879);

  /// أحمر ترابي هادئ يُستخدم لحالات الخطأ.
  static const Color error = Color(0xFF9E5B4E);
}

/// لوحة الألوان الداكنة (dark palette) لتطبيق رِفْق.
abstract final class RifqDarkColors {
  static const Color background = Color(0xFF1E2D29);
  static const Color surface = Color(0xFF283B35);
  static const Color deepSurface = Color(0xFF17241F);
  static const Color textPrimary = Color(0xFFF3EFE5);
  static const Color textSecondary = Color(0xFFBAC7BE);
  static const Color clay = Color(0xFFD1A77F);
  static const Color sage = Color(0xFF8EAA90);
  static const Color water = Color(0xFF6E948B);
  static const Color gold = Color(0xFFC9AE73);
  static const Color error = Color(0xFFC98476);
}
