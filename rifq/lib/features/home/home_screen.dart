import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_info.dart';
import '../../core/providers.dart';
import '../../design_system/rifq_spacing.dart';
import '../../design_system/rifq_theme_extensions.dart';
import '../rewards/pebble_path.dart';
import 'widgets/living_garden.dart';

/// الشاشة الرئيسية — بلا أرقام صاخبة ولا Feed: أربعة أبواب للخروج إلى الحياة.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _whatsNewChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowWhatsNew());
  }

  /// «ما الجديد» — يظهر مرة واحدة فقط بعد كل تحديث.
  Future<void> _maybeShowWhatsNew() async {
    if (_whatsNewChecked) return;
    _whatsNewChecked = true;
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null ||
        !settings.onboardingDone ||
        settings.lastSeenVersion == appVersion) {
      return;
    }
    final items = whatsNew[appVersion] ?? const <String>[];
    if (items.isEmpty || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الجديد في نسخة $appVersion 🌿'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final item in items) Text('• $item\n')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('جميل'),
          ),
        ],
      ),
    );
    await ref
        .read(settingsProvider.notifier)
        .save(settings.copyWith(lastSeenVersion: appVersion));
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الهدوء';
    if (h < 18) return 'مساء الرِفْق';
    return 'مساء السكينة';
  }

  /// جملة قصيرة مبنية على حالة المستخدم الفعلية — بلا ادعاء بما لا نعرفه.
  String _stateSentence(bool fatigue, int todayWins) {
    if (fatigue) {
      return 'وضع الرحمة مفعّل. لا تحتاج أن تعوّض شيئًا — افتح الباب فقط.';
    }
    if (todayWins > 0) {
      return 'تركت أثرًا اليوم بالفعل. المساحة هنا كلما احتجتها.';
    }
    final h = DateTime.now().hour;
    if (h < 12) {
      return 'لا تحتاج أن تصلح اليوم كله الآن. ابدأ بما تحتاجه هذه اللحظة.';
    }
    if (h < 18) return 'هناك مساحة صغيرة يمكنك العودة إليها.';
    return 'مساء هادئ. ماذا تحتاج قبل أن ينتهي اليوم؟';
  }

  @override
  Widget build(BuildContext context) {
    final palette = RifqPalette.of(context);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final fatigueActive = settings?.fatigueModeActive ?? false;
    final todayWins = ref.watch(todayWinsProvider).valueOrNull?.length ?? 0;

    final destinations = [
      GardenDestination(
        label: 'المرآة',
        hint: 'تأمل ما عشته',
        icon: Icons.water_drop_outlined,
        alignment: const Alignment(-0.85, 0.55),
        onTap: () => context.push('/mirror'),
      ),
      GardenDestination(
        label: 'البوصلة',
        hint: 'اختر اتجاهك',
        icon: Icons.explore_outlined,
        alignment: const Alignment(0.15, 0.95),
        onTap: () => context.push('/compass'),
      ),
      GardenDestination(
        label: 'الملجأ',
        hint: 'افهم ما تحتاجه الآن',
        icon: Icons.cottage_outlined,
        alignment: const Alignment(0.9, 0.15),
        onTap: () => context.push('/sanctuary'),
      ),
    ];

    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        child: ListView(
          padding: RifqSpacing.page,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_greeting(),
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                IconButton(
                  tooltip: 'الإعدادات',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: RifqSpacing.xs),
            Text(
              _stateSentence(fatigueActive, todayWins),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: RifqSpacing.md),
            LivingGarden(destinations: destinations),
            const SizedBox(height: RifqSpacing.lg),
            // فعل واحد واضح مباشر.
            FilledButton.icon(
              icon: const Icon(Icons.self_improvement),
              label: const Text('أحتاج أن أهدأ الآن'),
              onPressed: () => context.push('/reset'),
            ),
            const SizedBox(height: RifqSpacing.xl),
            const PebblePathCard(),
            // أدوات هادئة ثانوية — تبقى كل الميزات في متناول اليد.
            _quietUtilities(context, palette),
            const SizedBox(height: RifqSpacing.lg),
            Center(
              child: Text('رِفْق $appVersion',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary.withValues(alpha: 0.7))),
            ),
            const SizedBox(height: RifqSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _quietUtilities(BuildContext context, RifqPalette palette) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text('أدوات هادئة',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.textSecondary)),
        children: [
          _util(context, Icons.wb_twilight, 'حصاد اليوم', '/harvest'),
          _util(
              context, Icons.timelapse_outlined, 'وقتك على السوشيال', '/usage'),
          _util(context, Icons.photo_camera_outlined, 'دخول إنستجرام بنية',
              '/instagram'),
          _util(context, Icons.edit_note, 'المؤثر الهادئ', '/creator'),
          _util(context, Icons.nightlight_outlined, 'دخلت في الفتور؟',
              '/fatigue'),
        ],
      ),
    );
  }

  Widget _util(
      BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_left, size: 20),
      onTap: () => context.push(route),
    );
  }
}
