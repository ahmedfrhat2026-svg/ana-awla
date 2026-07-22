import 'package:flutter/material.dart';

import 'rifq_motion.dart';

/// مساعد احترام تفضيل «تقليل الحركة» في النظام.
///
/// عند تفعيله: تُوقَف الحلقات المحيطة (ambient)، ويُستبدل التحرك بتلاشٍ،
/// وتُقصَّر مدد الانتقال. تعتمد الواجهات على [ambientEnabled] قبل تشغيل أي
/// حركة بيئية مستمرة (ماء، أوراق، ضوء).
abstract final class RifqReducedMotion {
  /// هل طلب المستخدم تقليل الحركة من إعدادات النظام؟
  static bool isOn(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// هل يُسمح بالحركة المحيطة المستمرة؟ (عكس تقليل الحركة).
  static bool ambientEnabled(BuildContext context) => !isOn(context);

  /// مدة انتقال محترمة لتقليل الحركة: تصبح فورية شبه كاملة عند التفعيل.
  static Duration transition(BuildContext context,
      {Duration base = RifqMotion.common}) {
    if (isOn(context)) return RifqMotion.instant;
    return base;
  }
}
