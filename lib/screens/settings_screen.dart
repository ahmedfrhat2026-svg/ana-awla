import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/database.dart';
import '../services/notifications.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, String> _settings = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await AppDb.instance.allSettings();
    if (!mounted) return;
    setState(() {
      _settings = s;
      _loading = false;
    });
  }

  Future<void> _editNumber(String key, String label, {String suffix = 'ج'}) async {
    final current = _settings[key] ?? '';
    final ctrl = TextEditingController(text: current);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(suffixText: suffix),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) {
      await AppDb.instance.setSetting(key, v);
      await _load();
    }
  }

  Future<void> _editTime(String key, String label) async {
    final current = _settings[key] ?? '09:00';
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final v = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await AppDb.instance.setSetting(key, v);
      await NotificationService.instance.scheduleAllReminders();
      await _load();
    }
  }

  Future<void> _exportCsv() async {
    final expenses = await AppDb.instance.expensesBetween(
      DateTime(2020, 1, 1),
      DateTime(2100, 1, 1),
    );
    final savings = await AppDb.instance.savingsBetween(
      DateTime(2020, 1, 1),
      DateTime(2100, 1, 1),
    );

    final sb = StringBuffer();
    sb.writeln('type,date,amount,currency,merchant,category,paymentMethod,note,needType,regretLevel');
    for (final e in expenses) {
      sb.writeln([
        'expense',
        e.date.toIso8601String(),
        e.amount,
        e.currency,
        _csv(e.merchant),
        _csv(e.category),
        _csv(e.paymentMethod),
        _csv(e.note),
        e.needType.name,
        e.regretLevel.name,
      ].join(','));
    }
    for (final s in savings) {
      sb.writeln([
        'saving',
        s.date.toIso8601String(),
        s.amount,
        'EGP',
        _csv(s.reason),
        _csv(s.category),
        '',
        '',
        '',
        '',
      ].join(','));
    }

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final f = File(p.join(dir.path, 'ana_awla_export_$stamp.csv'));
    await f.writeAsString(sb.toString());
    await Share.shareXFiles([XFile(f.path)], subject: 'تصدير مصروفات أنا أولى');
  }

  String _csv(String? v) {
    if (v == null) return '';
    final s = v.replaceAll('"', '""');
    return s.contains(',') ? '"$s"' : s;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _section('الميزانية والدخل', [
          _row('الدخل الشهري', _settings['monthlyIncome'] ?? '0',
              onTap: () => _editNumber('monthlyIncome', 'الدخل الشهري')),
          _row('هدف الادخار الشهري', _settings['monthlySavingsGoal'] ?? '0',
              onTap: () => _editNumber('monthlySavingsGoal', 'هدف الادخار الشهري')),
          _row('ميزانية اليوم', _settings['dailyBudget'] ?? '0',
              onTap: () => _editNumber('dailyBudget', 'ميزانية اليوم')),
          _row('حد قائمة 24 ساعة', _settings['waitingThreshold'] ?? '0',
              onTap: () => _editNumber('waitingThreshold', 'الحد اللي يستحق انتظار 24 ساعة')),
        ]),
        const SizedBox(height: 16),
        _section('أوقات التنبيهات', [
          _row('صباحاً', _settings['notifMorning'] ?? '10:00',
              onTap: () => _editTime('notifMorning', 'صباحاً'), suffix: ''),
          _row('بعد الظهر', _settings['notifAfternoon'] ?? '15:00',
              onTap: () => _editTime('notifAfternoon', 'بعد الظهر'), suffix: ''),
          _row('مساءً', _settings['notifEvening'] ?? '20:00',
              onTap: () => _editTime('notifEvening', 'مساءً'), suffix: ''),
          _row('قبل النوم', _settings['notifNight'] ?? '23:30',
              onTap: () => _editTime('notifNight', 'قبل النوم'), suffix: ''),
        ]),
        const SizedBox(height: 16),
        _section('البيانات', [
          ListTile(
            leading: const Icon(Icons.file_download_outlined, color: AppColors.accent),
            title: const Text('تصدير CSV'),
            subtitle: const Text('يفتح شاشة المشاركة لحفظ الملف.'),
            onTap: _exportCsv,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined, color: AppColors.accent),
            title: const Text('اختبار التنبيه'),
            subtitle: const Text('يطلع تنبيه فوري للتأكد من الإعداد.'),
            onTap: () async {
              await NotificationService.instance.showNow(
                9999,
                'التطبيق شغّال 👋',
                'هتوصلك التنبيهات في الأوقات اللي اخترتها.',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.replay_outlined, color: AppColors.accent),
            title: const Text('إعادة جدولة التنبيهات'),
            onTap: () async {
              await NotificationService.instance.scheduleAllReminders();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت إعادة الجدولة')),
              );
            },
          ),
        ]),
        const SizedBox(height: 16),
        const Center(
          child: Text('أنا أولى · v1.0',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {VoidCallback? onTap, String suffix = 'ج'}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              suffix.isEmpty ? value : '$value $suffix',
              style: const TextStyle(color: AppColors.inkSoft),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_left, color: AppColors.inkSoft, size: 18),
          ],
        ),
      ),
    );
  }
}
