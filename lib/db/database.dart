import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'ana_awla.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            amount REAL NOT NULL,
            currency TEXT NOT NULL DEFAULT 'EGP',
            merchant TEXT,
            category TEXT,
            paymentMethod TEXT,
            note TEXT,
            needType TEXT NOT NULL DEFAULT 'unset',
            regretLevel TEXT NOT NULL DEFAULT 'unset',
            createdAt TEXT NOT NULL
          )''');
        await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');

        await db.execute('''
          CREATE TABLE savings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            amount REAL NOT NULL,
            reason TEXT,
            category TEXT,
            createdAt TEXT NOT NULL
          )''');
        await db.execute('CREATE INDEX idx_savings_date ON savings(date)');

        await db.execute('''
          CREATE TABLE waiting(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            createdAt TEXT NOT NULL,
            amount REAL NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            decidedAt TEXT
          )''');

        await db.execute('''
          CREATE TABLE rules(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keyword TEXT NOT NULL UNIQUE,
            category TEXT NOT NULL
          )''');

        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT
          )''');

        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    const defaultRules = <String, String>{
      'أوبر': 'مواصلات',
      'اوبر': 'مواصلات',
      'كريم': 'مواصلات',
      'تاكسي': 'مواصلات',
      'بنزين': 'مواصلات',
      'وقود': 'مواصلات',
      'قهوة': 'قهوة',
      'كوفي': 'قهوة',
      'ستاربكس': 'قهوة',
      'كوستا': 'قهوة',
      'كارفور': 'بقالة',
      'سبينس': 'بقالة',
      'بيم': 'بقالة',
      'سوبر ماركت': 'بقالة',
      'غدا': 'أكل',
      'غداء': 'أكل',
      'عشا': 'أكل',
      'عشاء': 'أكل',
      'فطار': 'أكل',
      'فطور': 'أكل',
      'مطعم': 'أكل',
      'طلبات': 'أكل',
      'دواء': 'صحة',
      'صيدلية': 'صحة',
      'دكتور': 'صحة',
      'كهرباء': 'فواتير',
      'مياه': 'فواتير',
      'إنترنت': 'فواتير',
      'انترنت': 'فواتير',
      'موبايل': 'فواتير',
      'هدية': 'هدايا',
      'ملابس': 'شوبينج',
      'شوبينج': 'شوبينج',
    };
    final batch = db.batch();
    defaultRules.forEach((k, v) {
      batch.insert('rules', {'keyword': k, 'category': v});
    });
    batch.insert('settings', {'key': 'monthlyIncome', 'value': '15000'});
    batch.insert('settings', {'key': 'monthlySavingsGoal', 'value': '3000'});
    batch.insert('settings', {'key': 'dailyBudget', 'value': '400'});
    batch.insert('settings', {'key': 'waitingThreshold', 'value': '700'});
    batch.insert('settings', {'key': 'notifMorning', 'value': '10:00'});
    batch.insert('settings', {'key': 'notifAfternoon', 'value': '15:00'});
    batch.insert('settings', {'key': 'notifEvening', 'value': '20:00'});
    batch.insert('settings', {'key': 'notifNight', 'value': '23:30'});
    batch.insert('settings', {'key': 'notifGapHours', 'value': '6'});
    await batch.commit(noResult: true);
  }

  Future<int> insertExpense(Expense e) async {
    final d = await db;
    return d.insert('expenses', e.toMap());
  }

  Future<int> updateExpense(Expense e) async {
    final d = await db;
    return d.update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> deleteExpense(int id) async {
    final d = await db;
    return d.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> expensesBetween(DateTime from, DateTime to) async {
    final d = await db;
    final rows = await d.query(
      'expenses',
      where: 'date >= ? AND date < ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'date DESC, createdAt DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> expensesToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return expensesBetween(start, end);
  }

  Future<List<Expense>> expensesThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return expensesBetween(start, end);
  }

  Future<int> insertSaving(Saving s) async {
    final d = await db;
    return d.insert('savings', s.toMap());
  }

  Future<int> deleteSaving(int id) async {
    final d = await db;
    return d.delete('savings', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Saving>> savingsBetween(DateTime from, DateTime to) async {
    final d = await db;
    final rows = await d.query(
      'savings',
      where: 'date >= ? AND date < ?',
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'date DESC',
    );
    return rows.map(Saving.fromMap).toList();
  }

  Future<double> savingsThisMonthTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final list = await savingsBetween(start, end);
    return list.fold<double>(0, (a, b) => a + b.amount);
  }

  Future<int> insertWaiting(WaitingItem w) async {
    final d = await db;
    return d.insert('waiting', w.toMap());
  }

  Future<int> updateWaiting(WaitingItem w) async {
    final d = await db;
    return d.update('waiting', w.toMap(), where: 'id = ?', whereArgs: [w.id]);
  }

  Future<int> deleteWaiting(int id) async {
    final d = await db;
    return d.delete('waiting', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WaitingItem>> waitingList() async {
    final d = await db;
    final rows = await d.query('waiting', orderBy: 'createdAt DESC');
    return rows.map(WaitingItem.fromMap).toList();
  }

  Future<List<Rule>> rules() async {
    final d = await db;
    final rows = await d.query('rules', orderBy: 'category, keyword');
    return rows.map(Rule.fromMap).toList();
  }

  Future<int> upsertRule(Rule r) async {
    final d = await db;
    return d.insert(
      'rules',
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteRule(int id) async {
    final d = await db;
    return d.delete('rules', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, String>> allSettings() async {
    final d = await db;
    final rows = await d.query('settings');
    return {for (final r in rows) r['key'] as String: (r['value'] as String?) ?? ''};
  }

  Future<String?> getSetting(String key) async {
    final d = await db;
    final rows = await d.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final d = await db;
    await d.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
