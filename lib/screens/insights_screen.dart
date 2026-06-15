import 'package:flutter/material.dart';

import '../db/database.dart';
import '../services/budget.dart';
import '../theme.dart';
import '../widgets/money.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _loading = true;
  BudgetSummary? _s;
  Map<String, double> _top = {};
  double _impulse = 0;
  double _regret = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final svc = BudgetService(AppDb.instance);
    final s = await svc.compute();
    final top = await svc.topCategoriesThisMonth();
    final imp = await svc.impulseThisMonthTotal();
    final reg = await svc.regretThisMonthTotal();
    if (!mounted) return;
    setState(() {
      _s = s;
      _top = top;
      _impulse = imp;
      _regret = reg;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _s == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final s = _s!;
    final weekDelta = s.spentThisWeek - s.spentLastWeek;
    final betterThanLastWeek = weekDelta < 0;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _bigStats(s),
          const SizedBox(height: 16),
          _streak(s),
          const SizedBox(height: 16),
          _weekCompare(weekDelta, betterThanLastWeek),
          const SizedBox(height: 16),
          _section('أعلى تصنيفات الشهر', _topCategories()),
          const SizedBox(height: 16),
          _section(
            'مصروفات اندفاعية ومصروفات ندمت عليها',
            Column(
              children: [
                _statRow('اندفاعية الشهر ده', fmtMoney(_impulse), AppColors.warn),
                const SizedBox(height: 8),
                _statRow('ندمت عليها الشهر ده', fmtMoney(_regret), AppColors.bad),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigStats(BudgetSummary s) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'مصروف الشهر',
            fmtMoney(s.spentThisMonth),
            AppColors.accent,
            Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'صندوق «أنا أولى»',
            fmtMoney(s.savingsThisMonth),
            AppColors.good,
            Icons.savings_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _streak(BudgetSummary s) {
    final days = s.cleanDaysStreak;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.good.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_fire_department, color: AppColors.good),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days == 0
                      ? 'ابدأ اليوم — يوم بدون صرف اندفاعي'
                      : '$days يوم بدون صرف اندفاعي',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                const Text(
                  'الأيام بتتحسب من قيّمت المصروفات بـ «ندمان».',
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekCompare(double delta, bool better) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            better ? Icons.trending_down : Icons.trending_up,
            color: better ? AppColors.good : AppColors.warn,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مقارنة بالأسبوع اللي فات',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  better
                      ? 'وفّرت ${fmtMoney(delta.abs())} عن الأسبوع اللي فات'
                      : 'زاد المصروف بـ ${fmtMoney(delta)} عن الأسبوع اللي فات',
                  style: TextStyle(
                    color: better ? AppColors.good : AppColors.warn,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _topCategories() {
    if (_top.isEmpty) {
      return const Text('لسه مفيش بيانات الشهر ده.',
          style: TextStyle(color: AppColors.inkSoft));
    }
    final maxV = _top.values.first;
    return Column(
      children: _top.entries.map((e) {
        final pct = maxV == 0 ? 0.0 : (e.value / maxV).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(fmtMoney(e.value)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
