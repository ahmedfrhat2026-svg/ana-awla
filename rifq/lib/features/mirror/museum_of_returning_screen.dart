import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/rifq_scaffold.dart';
import '../../design_system/components/rifq_surfaces.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';
import 'return_moment.dart';
import 'widgets/still_water.dart';

/// متحف العودة — لا يحتفظ بإنجازاتك فقط، بل بلحظات رجوعك بعد الانقطاع.
/// كل عودة حصاة تستقرّ على الماء؛ والمقياس ليس عددًا يُطارَد، بل قصّة صادقة.
class MuseumOfReturningScreen extends ConsumerWidget {
  const MuseumOfReturningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = RifqPalette.of(context);
    final async = ref.watch(returnsSummaryProvider);

    return RifqScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RifqPageHeader(
            title: 'متحف العودة',
            subtitle: 'لحظات رجوعك — لا أيام التزامك.',
            onBack: () => context.pop(),
          ),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: RifqSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const RifqEmptyState(
              icon: Icons.water_drop_outlined,
              title: 'تعذّر فتح المتحف الآن',
              body: 'حاول مرة أخرى بعد قليل.',
            ),
            data: (summary) => _content(context, palette, summary),
          ),
        ],
      ),
    );
  }

  Widget _content(
      BuildContext context, RifqPalette palette, ReturnsSummary summary) {
    if (summary.total == 0) {
      return Column(
        children: [
          const StillWaterHeader(stoneCount: 0),
          const SizedBox(height: RifqSpacing.lg),
          RifqEmptyState(
            icon: Icons.spa_outlined,
            title: 'لا توجد لحظات هنا بعد',
            body: 'أول مرة تعود فيها من التوهان، ستستقرّ حصاة صغيرة على الماء.',
            action: FilledButton.icon(
              icon: const Icon(Icons.self_improvement),
              label: const Text('ابدأ عودة هادئة'),
              onPressed: () => context.push('/reset'),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StillWaterHeader(stoneCount: summary.total),
        const SizedBox(height: RifqSpacing.md),
        // الجملة الوصفية هي البطل — الرقم ثانوي وهادئ.
        Text(summary.sentence, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: RifqSpacing.xs),
        Text(
          'حصوات طريقك حتى الآن: ${summary.total}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: palette.textSecondary),
        ),
        const SizedBox(height: RifqSpacing.lg),
        for (final m in summary.moments)
          Padding(
            padding: const EdgeInsets.only(bottom: RifqSpacing.sm),
            child: RifqOrganicSurface(
              padding: const EdgeInsets.all(RifqSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 12, color: palette.sand),
                  const SizedBox(width: RifqSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('عدت إلى: ${m.returnedTo}',
                            style: Theme.of(context).textTheme.titleMedium),
                        if (m.tinyAction.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('بخطوة: ${m.tinyAction}',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                        const SizedBox(height: 4),
                        Text(arabicDate(m.when),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: palette.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: RifqSpacing.md),
        Center(
          child: Text('كل حصاة كانت لحظة اخترت فيها أن ترجع.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.textSecondary)),
        ),
      ],
    );
  }
}
