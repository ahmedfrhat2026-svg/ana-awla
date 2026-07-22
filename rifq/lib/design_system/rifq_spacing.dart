/// وحدات المسافات (spacing tokens) لتطبيق "رِفْق".
///
/// تُستخدم هذه القيم لضبط الهوامش والفراغات الداخلية بشكل متّسق
/// في جميع أنحاء التطبيق، بدلاً من كتابة أرقام حرة (magic numbers).
library;

import 'package:flutter/material.dart';

/// مقاييس المسافات الأساسية لتطبيق رِفْق.
abstract final class RifqSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// الهامش الأفقي القياسي لعرض الصفحة.
  static const double pageH = 22;

  /// هوامش الصفحة القياسية (أفقياً [pageH] ورأسياً [lg]).
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: pageH,
    vertical: lg,
  );
}
