import 'package:flutter/material.dart';

import '../db/database.dart';
import '../db/models.dart';
import '../services/budget.dart';
import '../services/notifications.dart';
import '../services/parser.dart';
import '../theme.dart';
import '../widgets/before_pay_sheet.dart';
import '../widgets/money.dart';
import '../widgets/regret_picker.dart';
import '../widgets/save_sheet.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _inputCtrl = TextEditingController();
  final _focusNode = FocusNode();

  bool _loading = true;
  BudgetSummary? _summary;
  List<Expense> _today = [];
  List<WaitingItem> _waiting = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final summary = await BudgetService(AppDb.instance).compute();
    final today = await AppDb.instance.expensesToday();
    final waiting = (await AppDb.instance.waitingList())
        .where((w) => w.status == WaitingStatus.pending)
        .toList();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _today = today;
      _waiting = waiting;
      _loading = false;
    });
  }

  Future<void> _submitInput() async {
    final raw = _inputCtrl.text.trim();
    if (raw.isEmpty) return;

    final rules = await AppDb.instance.rules();
    final parser = ArabicExpenseParser(rules);
    final parsed = parser.parse(raw);
    if (parsed == null) {
      _toast('مش لاقي مبلغ في النص. اكتب رقم.');
      return;
    }

    final threshold =
        double.tryParse(await AppDb.instance.getSetting('waitingThreshold') ?? '700') ?? 700;
    if (parsed.amount >= threshold) {
      final wait = await _askWait(parsed.amount, parsed.merchant ?? raw);
      if (wait == true) {
        await AppDb.instance.insertWaiting(WaitingItem(
          createdAt: DateTime.now(),
          amount: parsed.amount,
          description: parsed.merchant ?? raw,
        ));
        _inputCtrl.clear();
        await _refresh();
        _toast('اتحطت في قائمة 24 ساعة.');
        return;
      }
    }

    final now = DateTime.now();
    await AppDb.instance.insertExpense(Expense(
      date: now,
      amount: parsed.amount,
      merchant: parsed.merchant,
      category: parsed.category,
      paymentMethod: parsed.paymentMethod,
      note: null,
      createdAt: now,
    ));
    _inputCtrl.clear();
    await _refresh();

    final s = _summary!;
    if (s.overBudget) {
      await NotificationService.instance.notifyOverBudget(s.spentToday - s.dailyBudget);
    } else if (s.near80) {
      await NotificationService.instance.notifyBudgetWarning(s.percentToday);
    }
  }

  Future<bool?> _askWait(double amount, String desc) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ده فوق حدك السريع'),
        content: Text('${fmtMoney(amount)} — تحطه في قائمة 24 ساعة وتقرر بعدها؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('لا، سجّله كمصروف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('أجّل 24 ساعة'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openSave() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const SaveSheet(),
    );
    if (ok == true) {
      _toast('اتسجل في صندوق «أنا أولى».');
      await _refresh();
    }
  }

  Future<void> _openBeforePay() async {
    await showModalBottomSheet<BeforePayResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const BeforePaySheet(),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final s = _summary!;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          _header(s),
          const SizedBox(height: 16),
          _input(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openSave,
                  icon: const Icon(Icons.savings_outlined, size: 18, color: AppColors.good),
                  label: const Text('كنت هاصرف',
                      style: TextStyle(color: AppColors.good, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.good),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openBeforePay,
                  icon: const Icon(Icons.psychology_outlined, size: 18, color: AppColors.accent),
                  label: const Text('قبل ما أدفع',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
          if (_waiting.isNotEmpty) ...[
            const SizedBox(height: 20),
            _waitingSection(),
          ],
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('مصروفات اليوم',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          if (_today.isEmpty)
            _emptyToday()
          else
            ..._today.map(_expenseTile),
        ],
      ),
    );
  }

  Widget _header(BudgetSummary s) {
    final remaining = s.remainingToday;
    final overBudget = remaining < 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('صرفت النهارده',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtMoney(s.spentToday, suffix: ''),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('ج', style: TextStyle(color: AppColors.inkSoft, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: s.percentToday,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                overBudget ? AppColors.bad : (s.near80 ? AppColors.warn : AppColors.good),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                overBudget
                    ? 'فوق الميزانية بـ ${fmtMoney(-remaining)}'
                    : 'متبقي من ميزانية اليوم: ${fmtMoney(remaining)}',
                style: TextStyle(
                  color: overBudget ? AppColors.bad : AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'هدف: ${fmtMoney(s.dailyBudget)}',
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
              ),
            ],
          ),
          if (s.savingsThisMonth > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.good.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_rounded, color: AppColors.good, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'صندوق «أنا أولى» الشهر ده: ${fmtMoney(s.savingsThisMonth)}',
                      style: const TextStyle(
                          color: AppColors.good, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _input() {
    return TextField(
      controller: _inputCtrl,
      focusNode: _focusNode,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _submitInput(),
      decoration: InputDecoration(
        hintText: 'اكتب مصروف… مثال: قهوة 85 كاش',
        suffixIcon: IconButton(
          icon: const Icon(Icons.send_rounded, color: AppColors.accent),
          onPressed: _submitInput,
        ),
      ),
    );
  }

  Widget _emptyToday() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        children: [
          Icon(Icons.spa_outlined, size: 36, color: AppColors.inkSoft),
          SizedBox(height: 10),
          Text('مفيش مصروفات اليوم لحد دلوقتي.',
              style: TextStyle(color: AppColors.inkSoft)),
        ],
      ),
    );
  }

  Widget _expenseTile(Expense e) {
    final time = TimeOfDay.fromDateTime(e.date).format(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.bg,
            child: Icon(_iconForCategory(e.category), color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.merchant ?? e.category ?? 'مصروف',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (e.category != null) e.category!,
                    if (e.paymentMethod != null) e.paymentMethod!,
                    time,
                  ].join(' · '),
                  style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtMoney(e.amount),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  await showRegretPicker(context, e);
                  await _refresh();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _regretDot(e.regretLevel),
                    const SizedBox(width: 4),
                    const Text('قيّم', style: TextStyle(color: AppColors.inkSoft, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.inkSoft),
            onPressed: () async {
              await AppDb.instance.deleteExpense(e.id!);
              await _refresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _regretDot(RegretLevel r) {
    Color c;
    switch (r) {
      case RegretLevel.happy:
        c = AppColors.good;
        break;
      case RegretLevel.neutral:
        c = AppColors.warn;
        break;
      case RegretLevel.regret:
        c = AppColors.bad;
        break;
      case RegretLevel.unset:
        c = AppColors.divider;
        break;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }

  IconData _iconForCategory(String? c) {
    switch (c) {
      case 'مواصلات':
        return Icons.directions_car_outlined;
      case 'قهوة':
        return Icons.local_cafe_outlined;
      case 'أكل':
        return Icons.restaurant_outlined;
      case 'بقالة':
        return Icons.shopping_basket_outlined;
      case 'صحة':
        return Icons.medical_services_outlined;
      case 'فواتير':
        return Icons.receipt_long_outlined;
      case 'شوبينج':
        return Icons.shopping_bag_outlined;
      case 'هدايا':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  Widget _waitingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('قائمة 24 ساعة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        ..._waiting.map((w) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: w.isReady ? AppColors.accent : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.description,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          w.isReady
                              ? 'جاهز للقرار · ${fmtMoney(w.amount)}'
                              : 'استنى لحد ${TimeOfDay.fromDateTime(w.readyAt).format(context)} · ${fmtMoney(w.amount)}',
                          style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (w.isReady) ...[
                    TextButton(
                      onPressed: () async {
                        await AppDb.instance.updateWaiting(WaitingItem(
                          id: w.id,
                          createdAt: w.createdAt,
                          amount: w.amount,
                          description: w.description,
                          status: WaitingStatus.bought,
                          decidedAt: DateTime.now(),
                        ));
                        final now = DateTime.now();
                        await AppDb.instance.insertExpense(Expense(
                          date: now,
                          amount: w.amount,
                          merchant: w.description,
                          createdAt: now,
                        ));
                        await _refresh();
                      },
                      child: const Text('اشتريته'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await AppDb.instance.updateWaiting(WaitingItem(
                          id: w.id,
                          createdAt: w.createdAt,
                          amount: w.amount,
                          description: w.description,
                          status: WaitingStatus.saved,
                          decidedAt: DateTime.now(),
                        ));
                        await AppDb.instance.insertSaving(Saving(
                          date: DateTime.now(),
                          amount: w.amount,
                          reason: w.description,
                          category: 'انتظار 24 ساعة',
                          createdAt: DateTime.now(),
                        ));
                        await _refresh();
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.good),
                      child: const Text('وفّرت'),
                    ),
                  ],
                ],
              ),
            )),
      ],
    );
  }
}
