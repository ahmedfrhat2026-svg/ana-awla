import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/rifq_scaffold.dart';
import '../../design_system/components/rifq_surfaces.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';

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
class MirrorHubScreen extends StatelessWidget {
  const MirrorHubScreen({super.key});

  @override
  Widget build(BuildContext context) => const SystemHubScreen(
        title: 'المرآة',
        intro: 'تأمل ما عشته — من غير محاكمة ولا أرقام.',
        entries: [
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
        ],
        footer: 'كل سطر هنا كان يومًا عشته فعلًا.',
      );
}

/// 🧭 البوصلة — اختر اتجاهك.
class CompassHubScreen extends StatelessWidget {
  const CompassHubScreen({super.key});

  @override
  Widget build(BuildContext context) => const SystemHubScreen(
        title: 'البوصلة',
        intro: 'اختر ما يستحق طاقتك — لا ما يبدو مثاليًا.',
        entries: [
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
        ],
        footer: 'اتجاهك يتحدد بأصغر خطوة لها معنى.',
      );
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
            title: 'أهدأ / أنا تايه دلوقتي',
            subtitle: 'تنفّس، ذِكر، وخطوة أرضية',
            icon: Icons.self_improvement,
            route: '/reset',
          ),
          HubEntry(
            title: 'دخلت في الفتور؟',
            subtitle: 'وضع الرحمة والعودة',
            icon: Icons.nightlight_outlined,
            route: '/fatigue',
          ),
        ],
        footer: 'لا تحتاج أن تشرح كل شيء — اختر أقرب شعور.',
      );
}
