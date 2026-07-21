import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import '../rewards/pebble_path.dart';

/// المراجعة الأسبوعية — لغة «ماذا لاحظت؟» وليست «كيف تحسّن نتيجتك؟».
/// اقتراح واحد فقط للأسبوع القادم، وبلا مقارنات ولا منافسة.
class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ماذا لاحظت هذا الأسبوع؟')),
      body: FutureBuilder<_WeekData>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const PebblePathCard(),
              SectionCard(
                title: 'جلسات التركيز',
                child: Text(
                  data.focusCount == 0
                      ? 'مفيش جلسات الأسبوع ده — والعودة نفسها هي المقياس، مش الغياب.'
                      : 'قعدت مع نفسك ${data.focusCount} ${data.focusCount == 1 ? 'جلسة' : 'جلسات'} '
                          '(${data.focusMinutes} دقيقة إجمالًا). كل جلسة حجر في طريق الحصى.',
                ),
              ),
              SectionCard(
                title: 'سرعة الرجوع',
                child: Text(
                  data.resetCount == 0
                      ? 'مستخدمتش «العودة الهادئة» الأسبوع ده.'
                      : 'رجعت من التوهان ${data.resetCount} ${data.resetCount == 1 ? 'مرة' : 'مرات'} — '
                          'النجاح الحقيقي إن الرجوع بيبقى أسرع وأهدأ.',
                ),
              ),
              if (data.wins.isNotEmpty)
                SectionCard(
                  title: 'إنجازات صغيرة استحقت التوثيق',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final w in data.wins.take(7))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• ${w.title}'),
                        ),
                    ],
                  ),
                ),
              SectionCard(
                title: 'المسودات',
                child: Text(
                  'خاصة: ${data.privateDrafts} — منشورة: ${data.sharedDrafts}. '
                  'اللي احتفظت بيه خاصًا له قيمة زي اللي نشرته.',
                ),
              ),
              SectionCard(
                title: 'اقتراح واحد للأسبوع الجاي',
                child: Text(
                  data.suggestion,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const GentleFooter(
                  text: 'غيّر عنق زجاجة واحد بس — مش خمس عادات مع بعض.'),
            ],
          );
        },
      ),
    );
  }

  Future<_WeekData> _load(WidgetRef ref) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final fromDate = weekAgo.toIso8601String().substring(0, 10);
    final toDate = now.toIso8601String().substring(0, 10);

    final focus = await ref.read(focusRepoProvider).between(weekAgo, now);
    final resets = await ref.read(resetRepoProvider).recent(limit: 50);
    final wins = await ref.read(winsRepoProvider).between(fromDate, toDate);
    final drafts = await ref.read(draftsRepoProvider).all();

    final weekResets = resets
        .where((r) => r.createdAt != null && r.createdAt!.isAfter(weekAgo))
        .length;
    final privateDrafts = drafts
        .where((d) =>
            d.status == DraftStatus.keptPrivate ||
            d.status == DraftStatus.draft)
        .length;
    final sharedDrafts =
        drafts.where((d) => d.status == DraftStatus.shared).length;

    // اقتراح واحد فقط — أبسط عنق زجاجة ملحوظ.
    String suggestion;
    if (focus.isEmpty) {
      suggestion =
          'جرّب جلسة «بداية ثقيلة» واحدة (10 دقايق) في أهدأ وقت عندك.';
    } else if (weekResets > focus.length) {
      suggestion =
          'التوهان أكتر من الجلسات — خلي الموبايل خارج مجال النظر وقت أول جلسة بس.';
    } else if (wins.isEmpty) {
      suggestion = 'وثّق إنجاز صغير واحد يوميًا — حتى «فتحت الكتاب».';
    } else {
      suggestion =
          'حافظ على الخيط: نفس الخطوة الصغيرة، نفس الوقت، يوم بعد يوم.';
    }

    return _WeekData(
      focusCount: focus.length,
      focusMinutes:
          focus.fold<int>(0, (sum, s) => sum + s.actualMinutes),
      resetCount: weekResets,
      wins: wins,
      privateDrafts: privateDrafts,
      sharedDrafts: sharedDrafts,
      suggestion: suggestion,
    );
  }
}

class _WeekData {
  const _WeekData({
    required this.focusCount,
    required this.focusMinutes,
    required this.resetCount,
    required this.wins,
    required this.privateDrafts,
    required this.sharedDrafts,
    required this.suggestion,
  });

  final int focusCount;
  final int focusMinutes;
  final int resetCount;
  final List<SmallWin> wins;
  final int privateDrafts;
  final int sharedDrafts;
  final String suggestion;
}
