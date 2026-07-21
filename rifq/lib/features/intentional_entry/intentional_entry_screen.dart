import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// دخول إنستجرام بنية: حدد ليه وهتقعد قد إيه، وهنفكرك ترجع.
/// بدون أي صلاحيات حساسة — مؤقت محلي + تنبيه رجوع.
class IntentionalEntryScreen extends ConsumerStatefulWidget {
  const IntentionalEntryScreen({super.key});

  @override
  ConsumerState<IntentionalEntryScreen> createState() =>
      _IntentionalEntryScreenState();
}

class _IntentionalEntryScreenState
    extends ConsumerState<IntentionalEntryScreen> {
  String? _intention;
  int _minutes = 10;

  static const _intentions = [
    'نشر محتوى',
    'الرد على التعليقات',
    'البحث عن شيء محدد',
    'التواصل مع شخص',
    'تصفح',
  ];

  Future<void> _enter() async {
    if (_intention == null) return;
    final settings = ref.read(settingsProvider).valueOrNull;
    await ref.read(intentRepoProvider).add(IntentSession(
          intention: _intention!,
          plannedMinutes: _minutes,
        ));
    // تنبيه الرجوع يحتاج إذن الإشعارات — يُطلب هنا في سياقه.
    final scheduler = ref.read(schedulerProvider);
    final granted = await scheduler.requestPermissionIfNeeded();
    if (granted) {
      await scheduler.scheduleIntentReturn(
          _minutes, settings?.companionName ?? 'رِفْق');
    }
    final opened = await ref.read(instagramLauncherProvider).open();
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مقدرتش أفتح إنستجرام')));
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دخول بنية')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('هدف الدخول الآن؟',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ChoiceChips(
            options: _intentions,
            selected: _intention,
            onSelected: (v) => setState(() => _intention = v),
          ),
          const SizedBox(height: 20),
          if (_intention == 'تصفح')
            SectionCard(
              child: Text(
                'كم دقيقة تريد أن تمنحها لهذا التصفح؟ التصفح مش غلط — '
                'المهم يكون قرار مش انسحاب.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          SectionCard(
            title: 'المدة',
            child: ChoiceChips(
              options: const ['5 دقائق', '10 دقائق', '15 دقيقة', '20 دقيقة'],
              selected: '$_minutes دقائق'.replaceFirst('15 دقائق', '15 دقيقة')
                  .replaceFirst('20 دقائق', '20 دقيقة'),
              onSelected: (v) => setState(() {
                _minutes = int.parse(v.split(' ').first);
              }),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('افتح إنستجرام'),
            onPressed: _intention == null ? null : _enter,
          ),
          const GentleFooter(
              text: 'هفكّرك بعد المدة: أخدت اللي دخلت عشانه؟'),
        ],
      ),
    );
  }
}
