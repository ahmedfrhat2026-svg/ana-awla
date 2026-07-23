import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// «طريق الحصى» — مكافآت بروح رِفْق:
/// كل جلسة تركيز، وكل عودة من التوهان، وكل إنجاز موثّق = حجر في طريقك.
/// اليوم الفائت لا يكسر شيئًا، ولا توجد شعلة تحترق ولا مقارنة بأحد.
class PebblePathLogic {
  const PebblePathLogic();

  /// المحطات الهادئة على الطريق — أرقام وأسماء بلا تنافس.
  static const milestones = <(int, String)>[
    (1, 'أول حجر — البداية نفسها إنجاز'),
    (5, 'خمس حصوات — الخيط اتمسك'),
    (10, 'عشر حصوات — الطريق بدأ يبان'),
    (25, 'خمسة وعشرون — العادة بتتكوّن على مهل'),
    (50, 'خمسون حجرًا — ده مشوار حقيقي'),
    (100, 'مئة حجر — أدومها وإن قل'),
    (200, 'مئتان — الطريق بقى جزء منك'),
  ];

  /// آخر محطة وصلها المستخدم، أو null قبل أول حجر.
  (int, String)? reached(int pebbles) {
    (int, String)? last;
    for (final m in milestones) {
      if (pebbles >= m.$1) last = m;
    }
    return last;
  }

  /// المحطة القادمة، أو null بعد آخر محطة.
  (int, String)? next(int pebbles) {
    for (final m in milestones) {
      if (pebbles < m.$1) return m;
    }
    return null;
  }
}

/// عدد الحصوات الكلي من البيانات الفعلية (جلسات + عودات + إنجازات).
final pebbleCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final focus = await ref.watch(focusRepoProvider).recent(limit: 1000);
  final resets = await ref.watch(resetRepoProvider).recent(limit: 1000);
  final wins =
      await ref.watch(winsRepoProvider).between('2000-01-01', '2100-01-01');
  final completedResets = resets.where((r) => r.completed).length;
  return focus.length + completedResets + wins.length;
});

/// بطاقة طريق الحصى — تُعرض في الرئيسية والمراجعة الأسبوعية.
class PebblePathCard extends ConsumerWidget {
  const PebblePathCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(pebbleCountProvider).valueOrNull;
    if (count == null) return const SizedBox.shrink();
    const logic = PebblePathLogic();
    final reached = logic.reached(count);
    final next = logic.next(count);
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'طريق الحصى',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // حصوات مرئية بسيطة (بحد أقصى 12 نقطة)
              for (var i = 0; i < (count > 12 ? 12 : count); i++)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary
                          .withValues(alpha: 0.35 + 0.05 * (i % 4)),
                    ),
                  ),
                ),
              if (count > 12) Text('  +${count - 12}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count == 0
                ? 'أول حجر بيتحط بأصغر خطوة — جلسة، عودة، أو لحظة موثّقة.'
                : '$count ${count == 1 ? 'حجر' : 'حجر'} في طريقك.'
                    '${reached != null ? '\n${reached.$2}' : ''}'
                    '${next != null ? '\nالمحطة الجاية: ${next.$1}' : ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
