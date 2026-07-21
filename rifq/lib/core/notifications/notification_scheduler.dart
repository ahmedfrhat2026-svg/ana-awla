import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../content/seed_texts.dart';
import '../db/models.dart';
import 'notification_rules_engine.dart';

/// واجهة جدولة التنبيهات — الشاشات تعتمد عليها، والتنفيذ الحقيقي أدناه،
/// وتنفيذ وهمي للاختبارات في مجلد test.
abstract interface class NotificationScheduler {
  Future<bool> requestPermissionIfNeeded();
  Future<void> scheduleDaily(UserSettings settings, List<NotificationRule> rules);
  Future<void> scheduleIntentReturn(int minutes, String companionName);
  Future<void> cancelAll();
}

/// التنفيذ الفعلي عبر flutter_local_notifications.
///
/// ملاحظات أندرويد:
/// - إذن POST_NOTIFICATIONS يُطلب في سياقه (بعد إنشاء أول جدول)، وليس عند
///   أول فتح للتطبيق.
/// - نستخدم تنبيهات غير دقيقة (inexact) حفاظًا على البطارية — لا حاجة
///   لصلاحية المنبهات الدقيقة في هذا التطبيق.
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler({NotificationRulesEngine? engine})
      : _engine = engine ?? const NotificationRulesEngine();

  final NotificationRulesEngine _engine;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationDetails(
    'rifq_companion',
    'رفيقك الهادئ',
    channelDescription: 'تذكيرات هادئة قليلة من رِفْق',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: false,
    enableVibration: false,
  );

  Future<void> _ensureInit() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermissionIfNeeded() async {
    await _ensureInit();
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  @override
  Future<void> scheduleDaily(
      UserSettings settings, List<NotificationRule> rules) async {
    await _ensureInit();
    await _plugin.cancelAll();

    final now = DateTime.now();
    // في وضع الفتور: تنبيه واحد رحيم يوميًا فقط.
    final maxPerDay = settings.fatigueModeActive ? 1 : settings.notificationsPerDay;
    final selected = _engine.selectForDay(
      rules,
      maxPerDay: maxPerDay,
      quietStart: settings.quietHoursStart,
      quietEnd: settings.quietHoursEnd,
      day: now,
    );

    var id = 100;
    for (final rule in selected) {
      final text = settings.fatigueModeActive
          ? _engine.pickText(fatigueGentleTexts, now)
          : _engine.pickText(_textsFor(rule.category), now);
      var when = tz.TZDateTime.local(
          now.year, now.month, now.day, rule.preferredHour, rule.preferredMinute);
      if (when.isBefore(tz.TZDateTime.now(tz.local))) {
        when = when.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id++,
        settings.companionName,
        text,
        when,
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  List<String> _textsFor(NotificationCategory category) => switch (category) {
        NotificationCategory.morningGrounding => gentleNotifications,
        NotificationCategory.studyStart => studyNotifications,
        NotificationCategory.returnFromScrolling => scrollReturnPrompts,
        NotificationCategory.eveningHarvest => eveningReflectionPrompts,
        NotificationCategory.weeklyReflection => eveningReflectionPrompts,
        NotificationCategory.compassionAfterMiss => fatigueGentleTexts,
      };

  @override
  Future<void> scheduleIntentReturn(int minutes, String companionName) async {
    await _ensureInit();
    final when = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
    await _plugin.zonedSchedule(
      7,
      companionName,
      'أخدت الحاجة اللي دخلت عشانها؟ ارجع لحاجة حقيقية دلوقتي.',
      when,
      const NotificationDetails(android: _channel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelAll() async {
    await _ensureInit();
    await _plugin.cancelAll();
  }
}
