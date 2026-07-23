import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/rifq_scaffold.dart';
import '../../design_system/components/rifq_surfaces.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';
import '../../core/providers.dart';
import '../compass/life_value.dart';
import '../mirror/return_moment.dart';
import '../mirror/widgets/still_water.dart';

/// عنصر داخل غرفة نظام — عنوان، سطر، وأيقونة، يفتح مسارًا موجودًا.
class HubEntry {
  const HubEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

/// غرفة نظام هادئة (مرآة/بوصلة/ملجأ) — ترويسة + مقدمة قصيرة + مداخل.
/// تحافظ على الوصول لكل الميزات الموجودة دون شبكة أزرار مزدحمة.
class SystemHubScreen extends StatelessWidget {
  const SystemHubScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.entries,
    this.footer,
  });

  final String title;
  final String intro;
  final List<HubEntry> entries;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    return RifqScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RifqPageHeader(
            title: title,
            subtitle: intro,
            onBack: () => context.pop(),
          ),
          for (final e in entries) ...[
            RifqOrganicSurface(
              onTap: () => context.push(e.route),
              padding: const EdgeInsets.all(RifqSpacing.md),
              child: Row(
                children: [
                  Icon(e.icon, color: palette.forest, size: 28),
                  const SizedBox(width: RifqSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(e.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: palette.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: palette.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: RifqSpacing.sm),
          ],
          if (footer != null) ...[
            const SizedBox(height: RifqSpacing.md),
            Text(footer!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: palette.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// 🪞 المرآة — تأمل ما عشته.
/// تبدأ بماء ساكن يحمل حصوات عودتك وجملة وصفية، ثم مداخل التأمل.
class MirrorHubScreen extends ConsumerWidget {
  const MirrorHubScreen({super.key});

  static const _entries = [
    HubEntry(
      title: 'متحف العودة',
      subtitle: 'لحظات رجوعك بعد الانقطاع',
      icon: Icons.water_drop_outlined,
      route: '/mirror/museum',
    ),
    HubEntry(
      title: 'أوثّق لحظتي',
      subtitle: 'اترك أثرًا صغيرًا من يومك',
      icon: Icons.favorite_outline,
      route: '/harvest',
    ),
    HubEntry(
      title: 'حصاد رحلتك',
      subtitle: 'كل ما عشته خلال أسبوع أو شهر',
      icon: Icons.auto_stories_outlined,
      route: '/harvest/archive',
    ),
    HubEntry(
      title: 'سكينة الأسبوع',
      subtitle: 'ماذا لاحظت؟ لا كيف كانت نتيجتك',
      icon: Icons.nights_stay_outlined,
      route: '/weekly',
    ),
    HubEntry(
      title: 'أرشيف مذاكرتك',
      subtitle: 'جلساتك وأسئلتك المتوقعة',
      icon: Icons.history_edu_outlined,
      route: '/focus/archive',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = RifqPalette.of(context);
    final summary = ref.watch(returnsSummaryProvider).valueOrNull;

    return RifqScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RifqPageHeader(
            title: 'المرآة',
            subtitle: 'تأمل ما عشته — من غير محاكمة ولا أرقام.',
            onBack: () => context.pop(),
          ),
          StillWaterHeader(stoneCount: summary?.total ?? 0),
          const SizedBox(height: RifqSpacing.md),
          if (summary != null)
            Padding(
              padding: const EdgeInsets.only(bottom: RifqSpacing.lg),
              child: Text(summary.sentence,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          for (final e in _entries) ...[
            RifqOrganicSurface(
              onTap: () => context.push(e.route),
              padding: const EdgeInsets.all(RifqSpacing.md),
              child: Row(
                children: [
                  Icon(e.icon, color: palette.forest, size: 28),
                  const SizedBox(width: RifqSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(e.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: palette.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: palette.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: RifqSpacing.sm),
          ],
          const SizedBox(height: RifqSpacing.sm),
          Center(
            child: Text('كل أثر هنا كان يومًا عشته فعلًا.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: palette.textSecondary)),
          ),
        ],
      ),
    );
  }
}

/// 🧭 البوصلة — اختر اتجاهك.
/// تبدأ بملاحظة وصفية عن قربك من قيمك، ثم مداخل الاتجاه والقرار.
class CompassHubScreen extends ConsumerWidget {
  const CompassHubScreen({super.key});

  static const _entries = [
    HubEntry(
      title: 'حديقة القيم',
      subtitle: 'ما تريد أن تمنحه مساحة — تنمو ولا تموت',
      icon: Icons.local_florist_outlined,
      route: '/compass/values',
    ),
    HubEntry(
      title: 'غرفة القرار',
      subtitle: 'هل هذا اختيار أم هروب؟',
      icon: Icons.psychology_alt_outlined,
      route: '/compass/decision',
    ),
    HubEntry(
      title: 'أذاكر',
      subtitle: 'أصغر خطوة ثم جلسة تركيز',
      icon: Icons.menu_book_outlined,
      route: '/focus',
    ),
    HubEntry(
      title: 'المؤثر الهادئ',
      subtitle: 'حوّل ما عشته لمحتوى هادف',
      icon: Icons.edit_note,
      route: '/creator',
    ),
    HubEntry(
      title: 'وقتك على السوشيال',
      subtitle: 'اعرف اتجاه وقتك بوعي',
      icon: Icons.timelapse_outlined,
      route: '/usage',
    ),
    HubEntry(
      title: 'دخول إنستجرام بنية',
      subtitle: 'قرار مقصود، لا انسحاب',
      icon: Icons.photo_camera_outlined,
      route: '/instagram',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = RifqPalette.of(context);
    final values = ref.watch(lifeValuesProvider).valueOrNull;
    return RifqScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RifqPageHeader(
            title: 'البوصلة',
            subtitle: 'اختر ما يستحق طاقتك — لا ما يبدو مثاليًا.',
            onBack: () => context.pop(),
          ),
          if (values != null)
            Padding(
              padding: const EdgeInsets.only(bottom: RifqSpacing.lg),
              child: Text(compassObservation(values),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          for (final e in _entries) ...[
            RifqOrganicSurface(
              onTap: () => context.push(e.route),
              padding: const EdgeInsets.all(RifqSpacing.md),
              child: Row(
                children: [
                  Icon(e.icon, color: palette.forest, size: 28),
                  const SizedBox(width: RifqSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(e.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: palette.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: palette.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: RifqSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// 🕊️ الملجأ — افهم ما تحتاجه الآن.
class SanctuaryHubScreen extends StatelessWidget {
  const SanctuaryHubScreen({super.key});

  @override
  Widget build(BuildContext context) => const SystemHubScreen(
        title: 'الملجأ',
        intro: 'مساحة صغيرة تفهمك بسرعة، ثم تعيدك للحياة.',
        entries: [
          HubEntry(
            title: 'ماذا يحدث داخلك الآن؟',
            subtitle: 'اختر أقرب شعور، وخذ خطوة واحدة',
            icon: Icons.favorite_outline,
            route: '/sanctuary/feeling',
          ),
          HubEntry(
            title: 'وضع الخلوة',
            subtitle: 'اترك الهاتف، واذهب لتعيش قليلًا',
            icon: Icons.park_outlined,
            route: '/sanctuary/retreat',
          ),
          HubEntry(
            title: 'أهدأ / أنا تايه دلوقتي',
            subtitle: 'تنفّس، ذِكر، وخطوة أرضية',
            icon: Icons.self_improvement,
            route: '/reset',
          ),
          HubEntry(
            title: 'دخلت في الفتور؟',
            subtitle: 'وضع الرحمة والعودة لأيام',
            icon: Icons.nightlight_outlined,
            route: '/fatigue',
          ),
        ],
        footer: 'لا تحتاج أن تشرح كل شيء — اختر أقرب شعور.',
      );
}
