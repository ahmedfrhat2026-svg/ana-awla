import '../db/database.dart';
import '../db/models.dart';

class BudgetSummary {
  final double dailyBudget;
  final double spentToday;
  final double remainingToday;
  final double monthlyBudget;
  final double spentThisMonth;
  final double savingsThisMonth;
  final int cleanDaysStreak;
  final double spentThisWeek;
  final double spentLastWeek;

  const BudgetSummary({
    required this.dailyBudget,
    required this.spentToday,
    required this.remainingToday,
    required this.monthlyBudget,
    required this.spentThisMonth,
    required this.savingsThisMonth,
    required this.cleanDaysStreak,
    required this.spentThisWeek,
    required this.spentLastWeek,
  });

  double get percentToday => dailyBudget <= 0 ? 0 : (spentToday / dailyBudget).clamp(0, 1).toDouble();
  bool get overBudget => spentToday > dailyBudget;
  bool get near80 => percentToday >= 0.8 && !overBudget;
}

class BudgetService {
  final AppDb db;
  BudgetService(this.db);

  Future<BudgetSummary> compute() async {
    final settings = await db.allSettings();
    final dailyBudget = double.tryParse(settings['dailyBudget'] ?? '') ?? 400.0;

    final monthlyIncome = double.tryParse(settings['monthlyIncome'] ?? '') ?? 0.0;
    final monthlySavingsGoal = double.tryParse(settings['monthlySavingsGoal'] ?? '') ?? 0.0;
    final monthlyBudget = (monthlyIncome - monthlySavingsGoal).clamp(0, double.infinity).toDouble();

    final today = await db.expensesToday();
    final spentToday = today.fold<double>(0, (a, b) => a + b.amount);

    final month = await db.expensesThisMonth();
    final spentMonth = month.fold<double>(0, (a, b) => a + b.amount);

    final savings = await db.savingsThisMonthTotal();

    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    final startOfPrevWeek = startOfWeek.subtract(const Duration(days: 7));

    final thisWeek = await db.expensesBetween(startOfWeek, startOfWeek.add(const Duration(days: 7)));
    final prevWeek = await db.expensesBetween(startOfPrevWeek, startOfWeek);
    final spentThisWeek = thisWeek.fold<double>(0, (a, b) => a + b.amount);
    final spentLastWeek = prevWeek.fold<double>(0, (a, b) => a + b.amount);

    final streak = await _cleanDaysStreak();

    return BudgetSummary(
      dailyBudget: dailyBudget,
      spentToday: spentToday,
      remainingToday: dailyBudget - spentToday,
      monthlyBudget: monthlyBudget,
      spentThisMonth: spentMonth,
      savingsThisMonth: savings,
      cleanDaysStreak: streak,
      spentThisWeek: spentThisWeek,
      spentLastWeek: spentLastWeek,
    );
  }

  DateTime _startOfWeek(DateTime d) {
    final base = DateTime(d.year, d.month, d.day);
    final daysSinceSat = (base.weekday + 1) % 7;
    return base.subtract(Duration(days: daysSinceSat));
  }

  Future<int> _cleanDaysStreak() async {
    var streak = 0;
    final now = DateTime.now();
    for (var i = 0; i < 60; i++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final list = await db.expensesBetween(day, next);
      final hasImpulse = list.any((e) => e.needType == NeedType.impulse);
      if (hasImpulse) break;
      streak++;
    }
    return streak;
  }

  Future<Map<String, double>> topCategoriesThisMonth({int limit = 5}) async {
    final month = await db.expensesThisMonth();
    final map = <String, double>{};
    for (final e in month) {
      final k = e.category ?? 'غير مصنف';
      map[k] = (map[k] ?? 0) + e.amount;
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries.take(limit));
  }

  Future<double> impulseThisMonthTotal() async {
    final month = await db.expensesThisMonth();
    return month
        .where((e) => e.needType == NeedType.impulse)
        .fold<double>(0, (a, b) => a + b.amount);
  }

  Future<double> regretThisMonthTotal() async {
    final month = await db.expensesThisMonth();
    return month
        .where((e) => e.regretLevel == RegretLevel.regret)
        .fold<double>(0, (a, b) => a + b.amount);
  }
}
