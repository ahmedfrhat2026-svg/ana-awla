import 'package:rifq/core/db/models.dart';
import 'package:rifq/core/db/repositories.dart';
import 'package:rifq/core/instagram/instagram_launcher.dart';
import 'package:rifq/core/notifications/notification_scheduler.dart';

/// تنفيذات وهمية في الذاكرة للاختبارات — بلا sqflite وبلا Plugins.

class FakeSettingsRepository implements SettingsRepository {
  UserSettings stored = const UserSettings(onboardingDone: true);

  @override
  Future<UserSettings> load() async => stored;

  @override
  Future<void> save(UserSettings settings) async => stored = settings;
}

class FakeWinsRepository implements WinsRepository {
  final List<SmallWin> wins = [];
  int _nextId = 1;

  @override
  Future<int> add(SmallWin win) async {
    final id = _nextId++;
    wins.add(SmallWin.fromMap({...win.toMap(), 'id': id}));
    return id;
  }

  @override
  Future<List<SmallWin>> byDate(String date) async =>
      wins.where((w) => w.date == date).toList();

  @override
  Future<List<SmallWin>> between(String fromDate, String toDate) async => wins
      .where((w) =>
          w.date.compareTo(fromDate) >= 0 && w.date.compareTo(toDate) <= 0)
      .toList();
}

class FakeFocusRepository implements FocusRepository {
  final List<FocusSession> sessions = [];
  int _nextId = 1;

  @override
  Future<int> add(FocusSession session) async {
    final id = _nextId++;
    sessions.add(FocusSession.fromMap({...session.toMap(), 'id': id}));
    return id;
  }

  @override
  Future<void> update(FocusSession session) async {
    final i = sessions.indexWhere((s) => s.id == session.id);
    if (i >= 0) sessions[i] = session;
  }

  @override
  Future<List<FocusSession>> recent({int limit = 20}) async =>
      sessions.reversed.take(limit).toList();

  @override
  Future<List<FocusSession>> between(DateTime from, DateTime to) async =>
      sessions
          .where((s) =>
              s.startedAt != null &&
              s.startedAt!.isAfter(from) &&
              s.startedAt!.isBefore(to))
          .toList();
}

class FakeResetRepository implements ResetRepository {
  final List<ResetSession> sessions = [];
  int _nextId = 1;

  @override
  Future<int> add(ResetSession session) async {
    final id = _nextId++;
    sessions.add(ResetSession.fromMap({...session.toMap(), 'id': id}));
    return id;
  }

  @override
  Future<void> update(ResetSession session) async {
    final i = sessions.indexWhere((s) => s.id == session.id);
    if (i >= 0) sessions[i] = session;
  }

  @override
  Future<List<ResetSession>> recent({int limit = 20}) async =>
      sessions.reversed.take(limit).toList();
}

class FakeReflectionRepository implements ReflectionRepository {
  final List<Reflection> reflections = [];

  @override
  Future<int> add(Reflection reflection) async {
    reflections.add(reflection);
    return reflections.length;
  }

  @override
  Future<Reflection?> byDate(String date) async =>
      reflections.where((r) => r.date == date).lastOrNull;

  @override
  Future<List<Reflection>> between(String fromDate, String toDate) async =>
      reflections
          .where((r) =>
              r.date.compareTo(fromDate) >= 0 &&
              r.date.compareTo(toDate) <= 0)
          .toList();
}

class FakeDraftsRepository implements DraftsRepository {
  final List<ContentDraft> drafts = [];
  int _nextId = 1;

  @override
  Future<int> add(ContentDraft draft) async {
    final id = _nextId++;
    drafts.add(ContentDraft.fromMap({...draft.toMap(), 'id': id}));
    return id;
  }

  @override
  Future<void> update(ContentDraft draft) async {
    final i = drafts.indexWhere((d) => d.id == draft.id);
    if (i >= 0) drafts[i] = draft;
  }

  @override
  Future<List<ContentDraft>> all() async => drafts.reversed.toList();
}

class FakeIntentRepository implements IntentRepository {
  final List<IntentSession> sessions = [];

  @override
  Future<int> add(IntentSession session) async {
    sessions.add(session);
    return sessions.length;
  }

  @override
  Future<void> update(IntentSession session) async {}

  @override
  Future<List<IntentSession>> recent({int limit = 20}) async =>
      sessions.reversed.take(limit).toList();
}

class FakeNotificationRulesRepository implements NotificationRulesRepository {
  List<NotificationRule> rules = [
    const NotificationRule(
        id: 1,
        category: NotificationCategory.morningGrounding,
        preferredHour: 8,
        preferredMinute: 30),
    const NotificationRule(
        id: 2,
        category: NotificationCategory.studyStart,
        preferredHour: 16),
    const NotificationRule(
        id: 3,
        category: NotificationCategory.eveningHarvest,
        preferredHour: 21),
  ];

  @override
  Future<List<NotificationRule>> all() async => rules;

  @override
  Future<void> update(NotificationRule rule) async {
    rules = [
      for (final r in rules)
        if (r.id == rule.id) rule else r
    ];
  }
}

class FakeCheckInRepository implements CheckInRepository {
  final List<DailyCheckIn> checkIns = [];

  @override
  Future<int> add(DailyCheckIn checkIn) async {
    checkIns.add(checkIn);
    return checkIns.length;
  }

  @override
  Future<DailyCheckIn?> byDate(String date) async =>
      checkIns.where((c) => c.date == date).lastOrNull;
}

class FakeNotificationScheduler implements NotificationScheduler {
  int scheduleDailyCalls = 0;
  int intentReturnCalls = 0;
  bool permissionGranted = true;

  @override
  Future<bool> requestPermissionIfNeeded() async => permissionGranted;

  @override
  Future<void> scheduleDaily(
      UserSettings settings, List<NotificationRule> rules) async {
    scheduleDailyCalls++;
  }

  @override
  Future<void> scheduleIntentReturn(int minutes, String companionName) async {
    intentReturnCalls++;
  }

  @override
  Future<void> cancelAll() async {}
}

class FakeInstagramLauncher implements InstagramLauncher {
  int openCalls = 0;

  @override
  Future<bool> open() async {
    openCalls++;
    return true;
  }
}
