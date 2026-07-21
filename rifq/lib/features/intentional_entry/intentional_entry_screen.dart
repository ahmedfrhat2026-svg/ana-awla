import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/sacred_texts.dart';
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

    // بوابة القرآن: قبل التصفح الحر، لحظة قراءة هادئة تعيد النية.
    if (_intention == 'تصفح') {
      final passed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (_) => const _QuranGateSheet(),
      );
      if (passed != true || !mounted) return;
    }

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

/// بوابة القرآن — قبل التصفح الحر: آيات موثّقة تُقرأ بتمهّل،
/// وزر المتابعة يفتح بعد نصف دقيقة تشجيعًا على القراءة الفعلية.
/// (الحظر الإجباري للتطبيقات يحتاج صلاحيات حساسة — مؤجل عمدًا لنسخة لاحقة.)
class _QuranGateSheet extends StatefulWidget {
  const _QuranGateSheet();

  @override
  State<_QuranGateSheet> createState() => _QuranGateSheetState();
}

class _QuranGateSheetState extends State<_QuranGateSheet> {
  static const _unlockSeconds = 30;
  int _remaining = _unlockSeconds;
  Timer? _timer;
  late final List<SacredText> _ayat;

  @override
  void initState() {
    super.initState();
    final all = gateAyat;
    final start = DateTime.now().day % all.length;
    _ayat = [for (var i = 0; i < 3 && i < all.length; i++) all[(start + i) % all.length]];
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _remaining--);
      if (_remaining <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('قبل ما تدخل… لحظة لقلبك',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('اقرأ بتمهّل — مش مطلوب غير نص دقيقة.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            for (final ayah in _ayat)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SectionCard(
                  child: Column(
                    children: [
                      Text('«${ayah.text}»',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(ayah.source,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            FilledButton(
              onPressed: _remaining <= 0
                  ? () => Navigator.pop(context, true)
                  : null,
              child: Text(_remaining <= 0
                  ? 'قرأت — كمّل بنيّة'
                  : 'اقرأ على مهلك… ($_remaining)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('غيّرت رأيي — مش هدخل دلوقتي 🌿'),
            ),
          ],
        ),
      ),
    );
  }
}
