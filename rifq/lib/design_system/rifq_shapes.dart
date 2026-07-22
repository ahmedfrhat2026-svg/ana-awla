/// أنصاف أقطار الحواف (corner radii) لتطبيق "رِفْق".
///
/// توفّر هذه الرموز قيماً موحّدة لاستدارة الحواف في البطاقات والأزرار
/// والعناصر الأخرى، لضمان مظهر هادئ ومتّسق في كل الشاشات.
library;

import 'package:flutter/material.dart';

/// أنصاف أقطار الاستدارة الأساسية لتطبيق رِفْق.
abstract final class RifqRadii {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 26;
  static const double hero = 32;

  /// استدارة صغيرة (تعتمد على [sm]).
  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));

  /// استدارة متوسطة (تعتمد على [md]).
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));

  /// استدارة كبيرة (تعتمد على [lg]).
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));

  /// استدارة بارزة للعناصر الرئيسية (تعتمد على [hero]).
  static const BorderRadius heroRadius =
      BorderRadius.all(Radius.circular(hero));
}
