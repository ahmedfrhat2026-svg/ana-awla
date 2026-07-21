import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_info.dart';
import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// الإعدادات: الرفيق، المظهر، التنبيهات، الخصوصية والأمان.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const personaLabels = {
    CompanionPersona.gentle: 'رفيق لطيف',
    CompanionPersona.practical: 'مدرّب عملي',
    CompanionPersona.balancedFaith: 'رفيق إيماني متزن',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            title: 'رفيقك',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: settings.companionName,
                  decoration: const InputDecoration(labelText: 'اسم الرفيق'),
                  onFieldSubmitted: (v) => notifier.save(settings.copyWith(companionName: v.trim())),
                ),
                const SizedBox(height: 12),
                ChoiceChips(
                  options: personaLabels.values.toList(),
                  selected: personaLabels[settings.companionPersona],
                  onSelected: (v) {
                    final persona = personaLabels.entries
                        .firstWhere((e) => e.value == v)
                        .key;
                    notifier.save(settings.copyWith(companionPersona: persona));
                  },
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'المظهر',
            child: ChoiceChips(
              options: const ['تلقائي', 'فاتح', 'داكن'],
              selected: switch (settings.theme) {
                'light' => 'فاتح',
                'dark' => 'داكن',
                _ => 'تلقائي',
              },
              onSelected: (v) => notifier.save(settings.copyWith(
                  theme: switch (v) {
                'فاتح' => 'light',
                'داكن' => 'dark',
                _ => 'system',
              })),
            ),
          ),
          if (settings.fatigueModeActive)
            SectionCard(
              title: 'وضع الرحمة مفعّل',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('التطبيق في وضع الرحمة والعودة لتلات أيام.'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => notifier.save(settings.copyWith(clearFatigueMode: true)),
                    child: const Text('رجعت — أوقف وضع الرحمة'),
                  ),
                ],
              ),
            ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('جدول التنبيهات'),
            subtitle:
                Text('${settings.notificationsPerDay} يوميًا كحد أقصى — '
                    'صمت من ${settings.quietHoursStart} لـ ${settings.quietHoursEnd}'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/settings/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('الأمان وحدود التطبيق'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/safety'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('الإصدار'),
            subtitle: const Text('رِفْق $appVersion'),
            trailing: TextButton(
              child: const Text('ما الجديد؟'),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('الجديد في $appVersion'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item
                          in whatsNew[appVersion] ?? const <String>[])
                        Text('• $item\n'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('تمام'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SectionCard(
            title: 'الخصوصية',
            child: Text(
              'بياناتك كلها محفوظة على جهازك فقط. لا يوجد إنترنت، ولا حسابات، '
              'ولا إعلانات، ولا مزامنة. العبادات والصدقات والأمور الحساسة '
              'خاصة افتراضيًا ولا تُشارك إلا باختيارك الصريح.',
            ),
          ),
        ],
      ),
    );
  }
}
