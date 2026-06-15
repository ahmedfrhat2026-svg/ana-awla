import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../db/database.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channel = AndroidNotificationChannel(
    'ana_awla_main',
    'تذكيرات أنا أولى',
    description: 'تذكيرات يومية لإدخال المصروفات والادخار',
    importance: Importance.defaultImportance,
  );

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (_) {}

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    await android?.requestNotificationsPermission();

    _initialized = true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'ana_awla_main',
          'تذكيرات أنا أولى',
          channelDescription: 'تذكيرات يومية لإدخال المصروفات والادخار',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );

  Future<void> showNow(int id, String title, String body) async {
    await init();
    await _plugin.show(id, title, body, _details);
  }

  Future<void> _scheduleDaily(int id, String title, String body, int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleAllReminders() async {
    await init();
    await _plugin.cancelAll();

    final s = await AppDb.instance.allSettings();
    final morning = _parseTime(s['notifMorning'] ?? '10:00');
    final afternoon = _parseTime(s['notifAfternoon'] ?? '15:00');
    final evening = _parseTime(s['notifEvening'] ?? '20:00');
    final night = _parseTime(s['notifNight'] ?? '23:30');

    await _scheduleDaily(
      1001,
      'صباح الخير 👋',
      'إيه أول مصروف هتسجله النهارده؟',
      morning.$1,
      morning.$2,
    );
    await _scheduleDaily(
      1002,
      'نص اليوم عدّى',
      'سجّلت كل اللي صرفته لحد دلوقتي؟',
      afternoon.$1,
      afternoon.$2,
    );
    await _scheduleDaily(
      1003,
      'تمام، اليوم قرّب يخلص',
      'افتح التطبيق وراجع مصروفات اليوم.',
      evening.$1,
      evening.$2,
    );
    await _scheduleDaily(
      1004,
      'مراجعة دقيقة قبل النوم',
      'فيه حاجة صرفتها ومكتبتهاش؟',
      night.$1,
      night.$2,
    );
  }

  Future<void> notifyBudgetWarning(double percent) async {
    await init();
    await showNow(
      2001,
      'وصلت ${(percent * 100).round()}% من ميزانية اليوم',
      'خلّي باقي اليوم هادي.',
    );
  }

  Future<void> notifyOverBudget(double over) async {
    await init();
    await showNow(
      2002,
      'عدّيت ميزانية اليوم بـ ${over.toStringAsFixed(0)} جنيه',
      'بكرة فرصة جديدة. كمّل بهدوء.',
    );
  }

  Future<void> notifyMotivation(double saved) async {
    await init();
    await showNow(
      3001,
      'أنت وفّرت ${saved.toStringAsFixed(0)} جنيه 🎉',
      'كل قرار «مشتريتش» بيقربك من هدفك.',
    );
  }

  (int, int) _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 9;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return (h, m);
  }
}
