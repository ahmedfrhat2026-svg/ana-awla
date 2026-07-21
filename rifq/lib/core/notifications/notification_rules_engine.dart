import '../db/models.dart';

/// منطق قواعد التنبيهات — منفصل عن أي Plugin ليكون قابلًا للاختبار.
///
/// المبادئ:
/// - ثلاثة تنبيهات يوميًا كحد أقصى افتراضيًا.
/// - احترام ساعات الصمت بالكامل.
/// - إذا تُجوهلت فئة ثلاث مرات متتالية تقل وتيرتها بدل زيادة الإزعاج.
/// - لا لوم ولا تخويف — النصوص تأتي من ملفات المحتوى المدقّقة فقط.
class NotificationRulesEngine {
  const NotificationRulesEngine();

  /// هل هذه الساعة داخل ساعات الصمت؟ يدعم النطاق العابر لمنتصف الليل
  /// (مثال: من 22 إلى 8).
  bool isQuietHour(int hour, {required int start, required int end}) {
    if (start == end) return false; // لا توجد ساعات صمت.
    if (start < end) return hour >= start && hour < end;
    return hour >= start || hour < end;
  }

  /// اختيار الفئات التي ستُجدول اليوم:
  /// المفعّلة فقط، خارج ساعات الصمت، وبحد أقصى [maxPerDay]،
  /// مع تخطي الفئات المتجاهَلة في الأيام الزوجية لتقليل وتيرتها.
  List<NotificationRule> selectForDay(
    List<NotificationRule> rules, {
    required int maxPerDay,
    required int quietStart,
    required int quietEnd,
    required DateTime day,
  }) {
    final selected = rules
        .where((r) => r.enabled)
        .where((r) => !isQuietHour(r.preferredHour,
            start: quietStart, end: quietEnd))
        .where((r) => !r.reducedFrequency || day.day.isEven)
        .toList()
      ..sort((a, b) => (a.preferredHour * 60 + a.preferredMinute)
          .compareTo(b.preferredHour * 60 + b.preferredMinute));
    return _spaced(selected).take(maxPerDay).toList();
  }

  /// منع التنبيهات المتقاربة: لا تنبيهان خلال أقل من 90 دقيقة.
  List<NotificationRule> _spaced(List<NotificationRule> sorted) {
    final result = <NotificationRule>[];
    int? lastMinutes;
    for (final r in sorted) {
      final m = r.preferredHour * 60 + r.preferredMinute;
      if (lastMinutes == null || m - lastMinutes >= 90) {
        result.add(r);
        lastMinutes = m;
      }
    }
    return result;
  }

  /// تسجيل تجاهل تنبيه — يزيد العداد.
  NotificationRule markIgnored(NotificationRule rule) =>
      rule.copyWith(ignoredCount: rule.ignoredCount + 1);

  /// تفاعل المستخدم مع التنبيه — يصفّر العداد.
  NotificationRule markEngaged(NotificationRule rule) =>
      rule.copyWith(ignoredCount: 0);

  /// نص التنبيه المناسب للفئة من قوائم المحتوى، بشكل دوري deterministic
  /// حسب اليوم — بدون عشوائية حتى يمكن اختباره.
  String pickText(List<String> texts, DateTime day) =>
      texts[day.difference(DateTime(2026)).inDays.abs() % texts.length];
}
