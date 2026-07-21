import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// مراقبة استخدام السوشيال — كلها اختيارية:
/// المستخدم يمنح الصلاحية بنفسه، ويحدّد حدّه اليومي، والتطبيق يعرض
/// الوقت ويذكّره برفق لو عدّاه. لا حظر إجباري ولا قراءة لأي محتوى.
class UsageMonitorScreen extends ConsumerWidget {
  const UsageMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermAsync = ref.watch(usagePermissionProvider);
    final usageAsync = ref.watch(instagramUsageProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('وقتك على السوشيال')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          hasPermAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (hasPerm) {
              if (!hasPerm) {
                return SectionCard(
                  title: 'محتاج إذنك الأول',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'عشان رِفْق يعرف قعدت قد إيه في إنستجرام، محتاج تديله '
                        '«Usage Access» من إعدادات أندرويد. هو مش بيقرأ أي محتوى '
                        '— بس مدة الاستخدام. وتقدر تلغيه في أي وقت.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('افتح الإعدادات وامنح الإذن'),
                        onPressed: () async {
                          await ref
                              .read(usageStatsProvider)
                              .openPermissionSettings();
                          ref.invalidate(usagePermissionProvider);
                          ref.invalidate(instagramUsageProvider);
                        },
                      ),
                    ],
                  ),
                );
              }
              return usageAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('مش قادر أقرأ الاستخدام دلوقتي.'),
                data: (minutes) =>
                    _UsageView(minutes: minutes ?? 0, settings: settings, ref: ref),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UsageView extends StatelessWidget {
  const _UsageView(
      {required this.minutes, required this.settings, required this.ref});

  final int minutes;
  final dynamic settings;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final limit = settings?.socialLimitMinutes ?? 60;
    final over = minutes > limit;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            children: [
              Text('$minutes دقيقة',
                  style: Theme.of(context).textTheme.displaySmall),
              Text('قضيتها في إنستجرام النهارده',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (minutes / (limit == 0 ? 1 : limit)).clamp(0.0, 1.0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: over ? scheme.error : scheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                over
                    ? 'عدّيت حدّك اليومي ($limit دقيقة) — مفيش لوم، بس خد لحظة وارجع لحاجة حقيقية 🌿'
                    : 'حدّك اليومي: $limit دقيقة',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'غيّر حدّك اليومي',
          child: Row(
            children: [
              for (final m in const [30, 45, 60, 90])
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text('$m'),
                    selected: limit == m,
                    onSelected: (_) => ref
                        .read(settingsProvider.notifier)
                        .save(settings.copyWith(socialLimitMinutes: m)),
                  ),
                ),
            ],
          ),
        ),
        const GentleFooter(
            text: 'الرقم مش عشان تحاسب نفسك — عشان تاخد قرار بوعي.'),
      ],
    );
  }
}
