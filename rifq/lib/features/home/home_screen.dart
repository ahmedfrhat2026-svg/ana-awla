import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/seed_texts.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';

/// الشاشة الرئيسية — بلا أرقام صاخبة ولا Feed: أربعة أبواب للخروج إلى الحياة.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الهدوء';
    if (h < 18) return 'مساء الرِفْق';
    return 'مساء السكينة';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final tinyStep = tinyActions[DateTime.now().day % tinyActions.length];
    final fatigueActive = settings?.fatigueModeActive ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting()),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (fatigueActive)
            SectionCard(
              child: Row(
                children: [
                  const Icon(Icons.spa_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'وضع الرحمة والعودة مفعّل — المطلوب النهارده الحفاظ على الخيط بس.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          Text('ماذا تحتاج الآن؟',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          BigActionButton(
            icon: Icons.self_improvement,
            title: 'أهدأ',
            subtitle: 'جلسة تنفّس وذِكر وتهدئة',
            onTap: () => context.push('/reset'),
          ),
          BigActionButton(
            icon: Icons.menu_book_outlined,
            title: 'أذاكر',
            subtitle: 'أصغر خطوة ثم جلسة تركيز',
            onTap: () => context.push('/focus'),
          ),
          BigActionButton(
            icon: Icons.favorite_outline,
            title: 'أوثّق لحظتي',
            subtitle: 'إنجاز صغير، صورة أو جملة',
            onTap: () => context.push('/harvest'),
          ),
          BigActionButton(
            icon: Icons.u_turn_right,
            title: 'أنقذني من التمرير',
            subtitle: 'إيقاف لحظي واستعادة النية',
            onTap: () => context.push('/reset'),
          ),
          const SizedBox(height: 8),
          SectionCard(
            title: 'خطوتك الصغيرة اليوم',
            child: Text(tinyStep,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.wb_twilight),
                  label: const Text('حصاد اليوم'),
                  onPressed: () => context.push('/harvest'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: const Text('المؤثر الهادئ'),
                  onPressed: () => context.push('/creator'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('دخول إنستجرام بنية'),
                  onPressed: () => context.push('/instagram'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_view_week_outlined),
                  label: const Text('مراجعة الأسبوع'),
                  onPressed: () => context.push('/weekly'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            icon: const Icon(Icons.nightlight_outlined),
            label: const Text('دخلت في الفتور؟'),
            onPressed: () => context.push('/fatigue'),
          ),
          const GentleFooter(text: 'خطوتك الصغيرة اليوم كافية كبداية.'),
        ],
      ),
    );
  }
}
