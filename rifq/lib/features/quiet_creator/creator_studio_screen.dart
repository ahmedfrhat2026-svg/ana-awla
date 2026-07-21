import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/content_template_engine.dart';
import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// صانع المحتوى الهادئ: عش أولًا، وثّق ثانيًا، انشر ثالثًا.
/// يحوّل إنجازات اليوم إلى صيغ إنستجرام بقوالب محلية — بلا AI وبلا إنترنت.
class CreatorStudioScreen extends ConsumerStatefulWidget {
  const CreatorStudioScreen({super.key});

  @override
  ConsumerState<CreatorStudioScreen> createState() =>
      _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends ConsumerState<CreatorStudioScreen> {
  final _reflection = TextEditingController();
  final _lesson = TextEditingController();
  ContentFormat _format = ContentFormat.caption;
  final Set<int> _selectedWinIds = {};

  static const _formatLabels = {
    ContentFormat.story: 'Story هادئة',
    ContentFormat.caption: 'Caption',
    ContentFormat.carousel: 'Carousel (3–5 شرائح)',
    ContentFormat.reelScript: 'Reel Script (15–30 ث)',
    ContentFormat.weeklyHarvest: 'حصاد الجمعة',
  };

  @override
  void dispose() {
    _reflection.dispose();
    _lesson.dispose();
    super.dispose();
  }

  Future<void> _openGate(List<SmallWin> wins) async {
    final selected = wins
        .where((w) => w.id != null && _selectedWinIds.contains(w.id))
        .toList();
    final gate = ref.read(privacyGateProvider);
    final hasSensitive = selected.any((w) => w.category.sensitiveByDefault);

    // بوابة النية والخصوصية — قبل توليد أي محتوى.
    final decision = await showModalBottomSheet<GateDecision>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _IntentionGateSheet(hasSensitive: hasSensitive),
    );
    if (decision == null || !mounted) return;

    if (decision == GateDecision.keepPrivate) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('اتحفظ خاص — أجمل اللحظات مش لازم تتنشر 🌿')));
      return;
    }

    // العناصر الحساسة لا تدخل المحتوى إلا لو المستخدم اختار «الدرس فقط».
    final effectiveWins = selected.map((w) {
      if (!w.category.sensitiveByDefault) {
        return w.copyWith(
            privacyLevel: decision == GateDecision.shareLessonOnly
                ? PrivacyLevel.lessonOnly
                : PrivacyLevel.public);
      }
      return decision == GateDecision.shareLessonOnly
          ? w.copyWith(privacyLevel: PrivacyLevel.lessonOnly)
          : w; // تبقى خاصة وتُستبعد من المحتوى.
    }).toList();

    final engine = ref.read(templateEngineProvider);
    var draft = engine.build(
      _format,
      ContentInput(
        wins: effectiveWins,
        reflection: _reflection.text.trim(),
        lesson: _lesson.text.trim(),
      ),
    );
    draft = gate.apply(draft, decision);
    final id = await ref.read(draftsRepoProvider).add(draft);
    if (!mounted) return;
    context.push('/creator/preview',
        extra: ContentDraft.fromMap({...draft.toMap(), 'id': id}));
  }

  @override
  Widget build(BuildContext context) {
    final winsAsync = ref.watch(todayWinsProvider);
    final wins = winsAsync.valueOrNull ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('المؤثر الهادئ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('عش أولًا، وثّق ثانيًا، انشر ثالثًا.',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SectionCard(
            title: 'اختار لحظات النهارده',
            child: wins.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('لسه موثقتش حاجة النهارده.'),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => context.push('/harvest'),
                        child: const Text('وثّق لحظة الأول'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      for (final w in wins)
                        CheckboxListTile(
                          value: _selectedWinIds.contains(w.id),
                          title: Text(w.title),
                          subtitle: w.category.sensitiveByDefault
                              ? const Text('حساس — خاص افتراضيًا 🔒')
                              : null,
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              _selectedWinIds.add(w.id!);
                            } else {
                              _selectedWinIds.remove(w.id);
                            }
                          }),
                        ),
                    ],
                  ),
          ),
          SectionCard(
            title: 'استخرج القيمة',
            child: Column(
              children: [
                CalmTextField(
                    controller: _reflection,
                    hint: 'إيه اللي حصل؟ وإيه اللي حسّيته؟'),
                const SizedBox(height: 10),
                CalmTextField(
                    controller: _lesson,
                    hint: 'إيه الجزء اللي ممكن يساعد حد تاني؟',
                    maxLines: 2),
              ],
            ),
          ),
          SectionCard(
            title: 'الصيغة',
            child: ChoiceChips(
              options: _formatLabels.values.toList(),
              selected: _formatLabels[_format],
              onSelected: (v) => setState(() {
                _format = _formatLabels.entries
                    .firstWhere((e) => e.value == v)
                    .key;
              }),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _openGate(wins),
            child: const Text('كمّل لبوابة النية'),
          ),
          const GentleFooter(
              text: 'التطبيق لا يحكم على النيات — القرار قرارك دايمًا.'),
        ],
      ),
    );
  }
}

/// بوابة النية والخصوصية — سؤالان ثم أربعة خيارات.
class _IntentionGateSheet extends StatelessWidget {
  const _IntentionGateSheet({required this.hasSensitive});

  final bool hasSensitive;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('بوابة النية',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(intentionGateQuestion1,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(intentionGateQuestion2,
                style: Theme.of(context).textTheme.titleMedium),
            if (hasSensitive) ...[
              const SizedBox(height: 12),
              Text(
                'في لحظات حساسة (عبادة/صدقة/عائلة/صحة/مال) — دي خاصة افتراضيًا، '
                'ولو اخترت المشاركة هيدخل «الدرس» فقط من غير التفاصيل.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, GateDecision.keepPrivate),
              child: const Text('احتفظ به خاصًا'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pop(context, GateDecision.shareLessonOnly),
              child: const Text('شارك الدرس دون التفاصيل الشخصية'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.pop(context, GateDecision.sharePublic),
              child: const Text('أنشئ نسخة عامة'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context, GateDecision.saveDraft),
              child: const Text('مش متأكد — احفظه مسودة'),
            ),
          ],
        ),
      ),
    );
  }
}
