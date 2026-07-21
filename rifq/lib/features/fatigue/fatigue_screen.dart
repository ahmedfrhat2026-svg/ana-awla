import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/seed_texts.dart';
import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// «دخلت في الفتور» — بروتوكول الرحمة والعودة:
/// بلا إحصائيات وبلا أيام ضائعة. ثلاثة أيام من وضع الرحمة:
/// مهمة واحدة صغيرة، تنبيه واحد، ولغة حفاظ على الخيط.
class FatigueScreen extends ConsumerStatefulWidget {
  const FatigueScreen({super.key});

  @override
  ConsumerState<FatigueScreen> createState() => _FatigueScreenState();
}

class _FatigueScreenState extends ConsumerState<FatigueScreen> {
  FatigueKind? _kind;

  static const _kindLabels = {
    FatigueKind.exhausted: 'مرهق',
    FatigueKind.lostMotivation: 'فقدت الحماس',
    FatigueKind.backToScrolling: 'رجعت للتمرير',
    FatigueKind.feelingBehind: 'حاسس إني متأخر',
    FatigueKind.planTooBig: 'الخطة كانت كبيرة',
    FatigueKind.unknown: 'مش عارف',
  };

  /// تمييز أنواع الفتور الثلاثة — لكل نوع ردّ مناسب.
  (String, String) _adviceFor(FatigueKind kind) => switch (kind) {
        FatigueKind.exhausted => (
            'ده شكله إرهاق حقيقي مش فتور.',
            'الحل: راحة مقصودة — نوم، ماء، وتخفيف الخطة. مش جلد ذات. '
                'ولو فقدان الطاقة مستمر لأسابيع مع تغير في النوم أو الشهية، '
                'الأفضل التحدث مع مختص.',
          ),
        FatigueKind.lostMotivation => (
            'فتور طبيعي — الحماس وقود بداية، مش وقود دائم.',
            'المطلوب دلوقتي الحد الأدنى: افتح صفحة وحل سؤال. '
                'إنت شخص بيرجع حتى وهو مش متحمس.',
          ),
        FatigueKind.backToScrolling => (
            'التمرير مش نهاية الرحلة.',
            'قاعدة «لا أختفي مرتين»: النهارده النسخة الصغيرة بس — '
                'عشر دقايق تكفي لإعادة الاتصال.',
          ),
        FatigueKind.feelingBehind => (
            'الشعور بالتأخر غالبًا هروب من شعور، مش حقيقة.',
            'الماضي مش محتاج إصلاح الليلة — الخطوة الجاية بس. '
                'اقترب من المهمة دقيقتين، مش أكتر.',
          ),
        FatigueKind.planTooBig => (
            'الخطة كانت أكبر من الطاقة — والتعديل ذكاء مش تنازل.',
            'انزل لنسخة الفتور: افتح صفحة، صورة وجملة، تلات أنفاس بطيئة.',
          ),
        FatigueKind.unknown => (
            'مش لازم تعرف السبب عشان ترجع.',
            'اسأل نفسك: أنا محتاج راحة فعلًا، ولا بهرب من شعور مزعج؟ '
                'وفي الحالتين: خطوة واحدة صغيرة كفاية.',
          ),
      };

  Future<void> _activate() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null) return;
    await ref.read(settingsProvider.notifier).save(settings.copyWith(
          fatigueModeUntil: DateTime.now().add(const Duration(days: 3)),
        ));
    // إعادة الجدولة بوتيرة الرحمة (تنبيه واحد يوميًا).
    final rules = await ref.read(notificationRulesRepoProvider).all();
    final updated = ref.read(settingsProvider).valueOrNull;
    if (updated != null) {
      await ref.read(schedulerProvider).scheduleDaily(updated, rules);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(fatigueGentleTexts[
              DateTime.now().day % fatigueGentleTexts.length])));
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وضع الرحمة والعودة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('أنا في مرحلة الفتور — والمطلوب الحفاظ على الخيط، '
              'مش تحقيق إنجاز كبير.',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('ما الأقرب لما تمر به؟',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ChoiceChips(
            options: _kindLabels.values.toList(),
            selected: _kindLabels[_kind],
            onSelected: (v) => setState(() {
              _kind = _kindLabels.entries
                  .firstWhere((e) => e.value == v)
                  .key;
            }),
          ),
          if (_kind != null) ...[
            const SizedBox(height: 16),
            SectionCard(
              title: _adviceFor(_kind!).$1,
              child: Text(_adviceFor(_kind!).$2,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(height: 8),
            const SectionCard(
              title: 'وضع الرحمة — 3 أيام',
              child: Text(
                '• الأهداف الكبيرة تتلغي مؤقتًا.\n'
                '• مهمة واحدة من 2 إلى 10 دقايق يوميًا.\n'
                '• تنبيه واحد هادئ بدل التلاتة.\n'
                '• لا أرقام ولا لغة إنجاز — الاحتفال بالعودة نفسها.\n'
                '• تذكير بالنوم والماء والحركة.',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _activate,
              child: const Text('فعّل وضع الرحمة'),
            ),
          ],
          const GentleFooter(
              text: 'في أيام الحماس أبني، وفي أيام الفتور أحافظ على الخيط.'),
        ],
      ),
    );
  }
}
