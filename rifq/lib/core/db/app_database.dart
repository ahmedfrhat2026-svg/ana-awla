import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// قاعدة بيانات رِفْق — كل البيانات محلية على الجهاز فقط.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = '${await getDatabasesPath()}/rifq.db';
    _db = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: migrate,
    );
    return _db!;
  }

  /// ترقيات المخطط:
  /// v2: صورة الملاحظات + تتبع التفاعل مع التنبيهات.
  /// v3: الفويس نوت + رقم آخر نسخة مشاهدة + حد السوشيال اليومي.
  /// v4: قيم الحياة (البوصلة) — حديقة تنمو ولا تموت.
  static Future<void> migrate(
      DatabaseExecutor d, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await d
          .execute('ALTER TABLE focus_session ADD COLUMN notesImagePath TEXT');
      await d.execute(
          'ALTER TABLE notification_rule ADD COLUMN lastEngagedAt TEXT');
    }
    if (oldVersion < 3) {
      await d
          .execute('ALTER TABLE focus_session ADD COLUMN voiceNotePath TEXT');
      await d.execute('ALTER TABLE reflection ADD COLUMN voicePath TEXT');
      await d
          .execute('ALTER TABLE user_settings ADD COLUMN lastSeenVersion TEXT');
      await d.execute(
          'ALTER TABLE user_settings ADD COLUMN socialLimitMinutes INTEGER');
    }
    if (oldVersion < 4) {
      await d.execute(_lifeValueTable);
    }
  }

  static const _lifeValueTable = '''
      CREATE TABLE life_value(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kind TEXT UNIQUE, actionCount INTEGER,
        chosenAt TEXT, lastActedAt TEXT
      )
    ''';

  /// للاختبارات: حقن قاعدة بيانات جاهزة (in-memory).
  set testDatabase(Database database) => _db = database;

  Future<void> _onCreate(Database d, int version) async {
    await createSchema(d);
  }

  /// إنشاء الجداول — دالة عامة لتُستخدم أيضًا في الاختبارات.
  static Future<void> createSchema(DatabaseExecutor d) async {
    await d.execute('''
      CREATE TABLE user_settings(
        id INTEGER PRIMARY KEY,
        locale TEXT, theme TEXT,
        companionName TEXT, companionPersona TEXT,
        notificationsPerDay INTEGER,
        quietHoursStart INTEGER, quietHoursEnd INTEGER,
        onboardingDone INTEGER,
        fatigueModeUntil TEXT,
        goals TEXT,
        lastSeenVersion TEXT,
        socialLimitMinutes INTEGER,
        createdAt TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE daily_checkin(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT, mood INTEGER, energy INTEGER, note TEXT, createdAt TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE small_win(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT, title TEXT, details TEXT,
        category TEXT, privacyLevel TEXT, imagePath TEXT, createdAt TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE focus_session(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT, task TEXT, tinyStep TEXT,
        plannedMinutes INTEGER, actualMinutes INTEGER, energyBefore INTEGER,
        status TEXT, retrievalAnswer TEXT, unclearPoint TEXT,
        examQuestion TEXT, nextStep TEXT, notesImagePath TEXT,
        voiceNotePath TEXT, startedAt TEXT, endedAt TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE reset_session(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trigger TEXT, selectedNeed TEXT, breathingDuration INTEGER,
        tinyAction TEXT, completed INTEGER, createdAt TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE reflection(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT, learned TEXT, gratitude TEXT,
        releaseThought TEXT, moodAfter INTEGER, voicePath TEXT, createdAt TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE content_draft(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sourceWinIds TEXT, format TEXT, title TEXT, body TEXT,
        privacyLevel TEXT, status TEXT, imagePath TEXT,
        createdAt TEXT, updatedAt TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE intent_session(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        targetApp TEXT, intention TEXT, plannedMinutes INTEGER,
        startedAt TEXT, returnedAt TEXT, extraMinutes INTEGER, outcome TEXT
      )
    ''');
    await d.execute('''
      CREATE TABLE notification_rule(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT, enabled INTEGER,
        preferredHour INTEGER, preferredMinute INTEGER,
        ignoredCount INTEGER, lastTriggeredAt TEXT, lastEngagedAt TEXT
      )
    ''');
    await d.execute(_lifeValueTable);
    // القيم الافتراضية: إعدادات هادئة وثلاثة تنبيهات يوميًا كحد أقصى.
    await d.insert('user_settings', const UserSettings().toMap());
    const defaults = [
      (NotificationCategory.morningGrounding, 8, 30),
      (NotificationCategory.studyStart, 16, 0),
      (NotificationCategory.eveningHarvest, 21, 0),
      (NotificationCategory.returnFromScrolling, 20, 0),
      (NotificationCategory.weeklyReflection, 18, 0),
      (NotificationCategory.compassionAfterMiss, 12, 0),
    ];
    for (final (cat, h, min) in defaults) {
      await d.insert(
        'notification_rule',
        NotificationRule(
          category: cat,
          // ثلاث فئات فقط مفعّلة افتراضيًا احترامًا لحد الثلاثة تنبيهات.
          enabled: cat == NotificationCategory.morningGrounding ||
              cat == NotificationCategory.studyStart ||
              cat == NotificationCategory.eveningHarvest,
          preferredHour: h,
          preferredMinute: min,
        ).toMap(),
      );
    }
  }
}
