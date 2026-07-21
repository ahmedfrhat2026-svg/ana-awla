import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// جدول التنبيهات: عدد يومي، ساعات صمت، وتفعيل/وقت لكل فئة.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  List<NotificationRule>? _rules;

  static const categoryLabels = {
    NotificationCategory.morningGrounding: 'تهدئة الصباح',
    NotificationCategory.studyStart: 'بداية المذاكرة',
    NotificationCategory.returnFromScrolling: 'الرجوع من التمرير',
    NotificationCategory.eveningHarvest: 'حصاد المساء',
    NotificationCategory.weeklyReflection: 'المراجعة الأسبوعية',
    NotificationCategory.compassionAfterMiss: 'رحمة بعد خطة فاتت',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rules = await ref.read(notificationRulesRepoProvider).all();
    if (mounted) setState(() => _rules = rules);
  }

  Future<void> _reschedule() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    final rules = _rules;
    if (settings == null || rules == null) return;
    final scheduler = ref.read(schedulerProvider);
    // إذن الإشعارات يُطلب هنا — في سياق إنشاء الجدول، وليس عند فتح التطبيق.
    final granted = await scheduler.requestPermissionIfNeeded();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('من غير إذن الإشعارات هيشتغل التطبيق عادي — بس من غير تذكير')));
      }
      return;
    }
    await scheduler.scheduleDaily(settings, rules);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('اتجدول بهدوء ✓')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final rules = _rules;
    if (settings == null || rules == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('جدول التنبيهات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            title: 'عدد التنبيهات اليومي (الحد الأقصى)',
            child: Slider(
              value: settings.notificationsPerDay.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              label: '${settings.notificationsPerDay}',
              onChanged: (v) => notifier.save(
                  settings.copyWith(notificationsPerDay: v.round())),
            ),
          ),
          SectionCard(
            title: 'ساعات الصمت الكامل',
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: settings.quietHoursStart,
                    decoration: const InputDecoration(labelText: 'من الساعة'),
                    items: [
                      for (var h = 0; h < 24; h++)
                        DropdownMenuItem(value: h, child: Text('$h:00'))
                    ],
                    onChanged: (v) => v == null
                        ? null
                        : notifier.save(settings.copyWith(quietHoursStart: v)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: settings.quietHoursEnd,
                    decoration: const InputDecoration(labelText: 'إلى الساعة'),
                    items: [
                      for (var h = 0; h < 24; h++)
                        DropdownMenuItem(value: h, child: Text('$h:00'))
                    ],
                    onChanged: (v) => v == null
                        ? null
                        : notifier.save(settings.copyWith(quietHoursEnd: v)),
                  ),
                ),
              ],
            ),
          ),
          for (final rule in rules)
            SwitchListTile(
              title: Text(categoryLabels[rule.category] ?? rule.category.name),
              subtitle: Text(
                'الساعة ${rule.preferredHour}:${rule.preferredMinute.toString().padLeft(2, '0')}'
                '${rule.reducedFrequency ? ' — وتيرة مخففة (اتجاهل 3 مرات)' : ''}',
              ),
              value: rule.enabled,
              onChanged: (v) async {
                final updated = rule.copyWith(enabled: v);
                await ref
                    .read(notificationRulesRepoProvider)
                    .update(updated);
                await _load();
              },
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _reschedule,
            child: const Text('احفظ وجدوِل'),
          ),
          const GentleFooter(
            text: 'العبادة لا تتحول لنقاط، ومفيش مقارنة بحد — رِفْق رفيق مش رقيب.',
          ),
        ],
      ),
    );
  }
}
