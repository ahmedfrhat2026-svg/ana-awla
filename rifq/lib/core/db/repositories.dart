import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import 'app_database.dart';
import 'models.dart';

/// واجهات المستودعات — الشاشات تتعامل معها فقط، وليس مع قاعدة البيانات مباشرة.
/// توجد تنفيذات محلية (sqflite) هنا، وتنفيذات وهمية للاختبارات في مجلد test.

abstract interface class SettingsRepository {
  Future<UserSettings> load();
  Future<void> save(UserSettings settings);
}

abstract interface class WinsRepository {
  Future<int> add(SmallWin win);
  Future<List<SmallWin>> byDate(String date);
  Future<List<SmallWin>> between(String fromDate, String toDate);
}

abstract interface class FocusRepository {
  Future<int> add(FocusSession session);
  Future<void> update(FocusSession session);
  Future<List<FocusSession>> recent({int limit = 20});
  Future<List<FocusSession>> between(DateTime from, DateTime to);
}

abstract interface class ResetRepository {
  Future<int> add(ResetSession session);
  Future<void> update(ResetSession session);
  Future<List<ResetSession>> recent({int limit = 20});
}

abstract interface class ReflectionRepository {
  Future<int> add(Reflection reflection);
  Future<Reflection?> byDate(String date);
  Future<List<Reflection>> between(String fromDate, String toDate);
}

abstract interface class DraftsRepository {
  Future<int> add(ContentDraft draft);
  Future<void> update(ContentDraft draft);
  Future<List<ContentDraft>> all();
}

abstract interface class IntentRepository {
  Future<int> add(IntentSession session);
  Future<void> update(IntentSession session);
  Future<List<IntentSession>> recent({int limit = 20});
}

abstract interface class NotificationRulesRepository {
  Future<List<NotificationRule>> all();
  Future<void> update(NotificationRule rule);
}

abstract interface class CheckInRepository {
  Future<int> add(DailyCheckIn checkIn);
  Future<DailyCheckIn?> byDate(String date);
}

abstract interface class ValuesRepository {
  Future<List<LifeValue>> all();
  Future<void> choose(ValueKind kind);
  Future<void> remove(ValueKind kind);
  Future<void> actOn(ValueKind kind);
}

// ---------------------------------------------------------------------------
// التنفيذ المحلي عبر sqflite
// ---------------------------------------------------------------------------

class LocalSettingsRepository implements SettingsRepository {
  @override
  Future<UserSettings> load() async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('user_settings', limit: 1);
    if (rows.isEmpty) return const UserSettings();
    return UserSettings.fromMap(rows.first);
  }

  @override
  Future<void> save(UserSettings settings) async {
    final d = await AppDatabase.instance.db;
    await d.update('user_settings', settings.toMap(),
        where: 'id = ?', whereArgs: [settings.id]);
  }
}

class LocalWinsRepository implements WinsRepository {
  @override
  Future<int> add(SmallWin win) async {
    final d = await AppDatabase.instance.db;
    return d.insert('small_win', win.toMap());
  }

  @override
  Future<List<SmallWin>> byDate(String date) async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('small_win',
        where: 'date = ?', whereArgs: [date], orderBy: 'id DESC');
    return rows.map(SmallWin.fromMap).toList();
  }

  @override
  Future<List<SmallWin>> between(String fromDate, String toDate) async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('small_win',
        where: 'date >= ? AND date <= ?',
        whereArgs: [fromDate, toDate],
        orderBy: 'date DESC, id DESC');
    return rows.map(SmallWin.fromMap).toList();
  }
}

class LocalFocusRepository implements FocusRepository {
  @override
  Future<int> add(FocusSession session) async {
    final d = await AppDatabase.instance.db;
    return d.insert('focus_session', session.toMap());
  }

  @override
  Future<void> update(FocusSession session) async {
    final d = await AppDatabase.instance.db;
    await d.update('focus_session', session.toMap(),
        where: 'id = ?', whereArgs: [session.id]);
  }

  @override
  Future<List<FocusSession>> recent({int limit = 20}) async {
    final d = await AppDatabase.instance.db;
    final rows =
        await d.query('focus_session', orderBy: 'id DESC', limit: limit);
    return rows.map(FocusSession.fromMap).toList();
  }

  @override
  Future<List<FocusSession>> between(DateTime from, DateTime to) async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('focus_session',
        where: 'startedAt >= ? AND startedAt <= ?',
        whereArgs: [from.toIso8601String(), to.toIso8601String()],
        orderBy: 'startedAt DESC');
    return rows.map(FocusSession.fromMap).toList();
  }
}

class LocalResetRepository implements ResetRepository {
  @override
  Future<int> add(ResetSession session) async {
    final d = await AppDatabase.instance.db;
    return d.insert('reset_session', session.toMap());
  }

  @override
  Future<void> update(ResetSession session) async {
    final d = await AppDatabase.instance.db;
    await d.update('reset_session', session.toMap(),
        where: 'id = ?', whereArgs: [session.id]);
  }

  @override
  Future<List<ResetSession>> recent({int limit = 20}) async {
    final d = await AppDatabase.instance.db;
    final rows =
        await d.query('reset_session', orderBy: 'id DESC', limit: limit);
    return rows.map(ResetSession.fromMap).toList();
  }
}

class LocalReflectionRepository implements ReflectionRepository {
  @override
  Future<int> add(Reflection reflection) async {
    final d = await AppDatabase.instance.db;
    return d.insert('reflection', reflection.toMap());
  }

  @override
  Future<Reflection?> byDate(String date) async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('reflection',
        where: 'date = ?', whereArgs: [date], orderBy: 'id DESC', limit: 1);
    return rows.isEmpty ? null : Reflection.fromMap(rows.first);
  }

  @override
  Future<List<Reflection>> between(String fromDate, String toDate) async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('reflection',
        where: 'date >= ? AND date <= ?',
        whereArgs: [fromDate, toDate],
        orderBy: 'date DESC');
    return rows.map(Reflection.fromMap).toList();
  }
}

class LocalDraftsRepository implements DraftsRepository {
  @override
  Future<int> add(ContentDraft draft) async {
    final d = await AppDatabase.instance.db;
    return d.insert('content_draft', draft.toMap());
  }

  @override
  Future<void> update(ContentDraft draft) async {
    final d = await AppDatabase.instance.db;
    await d.update('content_draft', draft.toMap(),
        where: 'id = ?', whereArgs: [draft.id]);
  }

  @override
  Future<List<ContentDraft>> all() async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('content_draft', orderBy: 'id DESC');
    return rows.map(ContentDraft.fromMap).toList();
  }
}

class LocalIntentRepository implements IntentRepository {
  @override
  Future<int> add(IntentSession session) async {
    final d = await AppDatabase.instance.db;
    return d.insert('intent_session', session.toMap());
  }

  @override
  Future<void> update(IntentSession session) async {
    final d = await AppDatabase.instance.db;
    await d.update('intent_session', session.toMap(),
        where: 'id = ?', whereArgs: [session.id]);
  }

  @override
  Future<List<IntentSession>> recent({int limit = 20}) async {
    final d = await AppDatabase.instance.db;
    final rows =
        await d.query('intent_session', orderBy: 'id DESC', limit: limit);
    return rows.map(IntentSession.fromMap).toList();
  }
}

class LocalNotificationRulesRepository implements NotificationRulesRepository {
  @override
  Future<List<NotificationRule>> all() async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('notification_rule');
    return rows.map(NotificationRule.fromMap).toList();
  }

  @override
  Future<void> update(NotificationRule rule) async {
    final d = await AppDatabase.instance.db;
    await d.update('notification_rule', rule.toMap(),
        where: 'id = ?', whereArgs: [rule.id]);
  }
}

class LocalCheckInRepository implements CheckInRepository {
  @override
  Future<int> add(DailyCheckIn checkIn) async {
    final d = await AppDatabase.instance.db;
    return d.insert('daily_checkin', checkIn.toMap());
  }

  @override
  Future<DailyCheckIn?> byDate(String date) async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('daily_checkin',
        where: 'date = ?', whereArgs: [date], limit: 1);
    return rows.isEmpty ? null : DailyCheckIn.fromMap(rows.first);
  }
}

class LocalValuesRepository implements ValuesRepository {
  @override
  Future<List<LifeValue>> all() async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('life_value', orderBy: 'id');
    return rows.map(LifeValue.fromMap).toList();
  }

  @override
  Future<void> choose(ValueKind kind) async {
    final d = await AppDatabase.instance.db;
    // كل قيمة صف واحد فريد (kind UNIQUE) — لا تكرار عند إعادة الاختيار.
    await d.insert(
      'life_value',
      LifeValue(kind: kind, chosenAt: DateTime.now()).toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<void> remove(ValueKind kind) async {
    final d = await AppDatabase.instance.db;
    await d.delete('life_value', where: 'kind = ?', whereArgs: [kind.name]);
  }

  @override
  Future<void> actOn(ValueKind kind) async {
    final d = await AppDatabase.instance.db;
    final rows = await d.query('life_value',
        where: 'kind = ?', whereArgs: [kind.name], limit: 1);
    if (rows.isEmpty) {
      // خدمة قيمة غير مختارة تختارها وتسجّل أول فعل.
      await d.insert(
          'life_value',
          LifeValue(
                  kind: kind,
                  actionCount: 1,
                  chosenAt: DateTime.now(),
                  lastActedAt: DateTime.now())
              .toMap());
      return;
    }
    final current = LifeValue.fromMap(rows.first);
    final updated = current.actOn();
    await d.update('life_value', updated.toMap(),
        where: 'kind = ?', whereArgs: [kind.name]);
  }
}
