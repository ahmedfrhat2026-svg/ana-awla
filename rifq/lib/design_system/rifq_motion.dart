/// رموز الحركة (motion tokens) لتطبيق "رِفْق".
///
/// توفّر هذه القيم مدداً ومنحنيات حركة موحّدة تعكس طابع التطبيق الهادئ.
/// تنبيه مهم: المدد الطويلة (البيئية/المحيطة مثل [RifqMotion.environmental])
/// يجب ألا تُستخدم قبل التحقق من إعداد "تقليل الحركة" (reduced motion) في
/// نظام التشغيل، احتراماً لتفضيلات المستخدم وإمكانية الوصول.
library;

import 'package:flutter/material.dart';

/// مدد ومنحنيات الحركة الأساسية لتطبيق رِفْق.
abstract final class RifqMotion {
  /// حركة فورية جداً (مثل ردود فعل اللمس).
  static const Duration instant = Duration(milliseconds: 120);

  /// حركة شائعة الاستخدام (انتقالات عادية).
  static const Duration common = Duration(milliseconds: 220);

  /// حركة تأملية أبطأ (انتقالات أكبر أو أكثر أهمية).
  static const Duration reflective = Duration(milliseconds: 360);

  /// حركة بيئية/محيطة طويلة جداً — يجب التحقق من إعداد تقليل الحركة
  /// (reduced motion) قبل استخدامها.
  static const Duration environmental = Duration(milliseconds: 800);

  /// منحنى قياسي للانتقالات العامة.
  static const Curve standard = Curves.easeInOut;

  /// منحنى الدخول (ظهور العناصر).
  static const Curve entrance = Curves.easeOutCubic;

  /// منحنى الخروج (اختفاء العناصر).
  static const Curve exit = Curves.easeInCubic;
}
