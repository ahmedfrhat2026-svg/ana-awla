import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';
import '../../shared/widgets.dart';
import '../settings/settings_screen.dart';

/// Onboarding من خمس صفحات — بلا طلب أي صلاحيات.
/// إذن الإشعارات يُطلب لاحقًا في سياقه (عند أول جدولة).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _companionName = TextEditingController(text: 'رفيق');
  int _page = 0;
  CompanionPersona _persona = CompanionPersona.gentle;
  int _notificationsPerDay = 3;
  final Set<String> _goals = {};

  static const _goalOptions = [
    'تقليل التمرير',
    'العودة للمذاكرة',
    'السلام الداخلي',
    'تنظيم اليوم',
    'إنشاء محتوى هادف',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _companionName.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsProvider).valueOrNull ??
        const UserSettings();
    await ref.read(settingsProvider.notifier).save(settings.copyWith(
          onboardingDone: true,
          companionName: _companionName.text.trim().isEmpty
              ? 'رفيق'
              : _companionName.text.trim(),
          companionPersona: _persona,
          notificationsPerDay: _notificationsPerDay,
          goals: _goals.toList(),
        ));
    if (mounted) context.go('/');
  }

  void _next() {
    if (_page == 4) {
      _finish();
    } else {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _page1(),
                  _page2(),
                  _page3(),
                  _page4(),
                  _page5(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 5; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _page ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _next,
                    child: Text(_page == 4 ? 'ابدأ على مهل' : 'كمّل'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrap(List<Widget> children) => ListView(
        padding: const EdgeInsets.all(24),
        children: children,
      );

  Widget _page1() => _wrap([
        const SizedBox(height: 60),
        Text('رِفْق',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('ارجع لنفسك على مهل',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: 40),
        Text(
          'رِفْق مش تطبيق هتعيش جواه.\nهو باب ترجع منه لحياتك.',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ]);

  Widget _page2() => _wrap([
        Text('إيه اللي جابك هنا؟',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('اختار اللي يشبهك — تقدر تغيّر بعدين.',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        for (final goal in _goalOptions)
          CheckboxListTile(
            value: _goals.contains(goal),
            title: Text(goal),
            onChanged: (v) => setState(() {
              v == true ? _goals.add(goal) : _goals.remove(goal);
            }),
          ),
      ]);

  Widget _page3() => _wrap([
        Text('اختار رفيقك',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        for (final entry in SettingsScreen.personaLabels.entries)
          Card(
            child: ListTile(
              selected: _persona == entry.key,
              leading: Icon(_persona == entry.key
                  ? Icons.check_circle
                  : Icons.circle_outlined),
              title: Text(entry.value),
              subtitle: Text(switch (entry.key) {
                CompanionPersona.gentle =>
                  '«مش لازم تكون جاهز بالكامل. نبدأ بحاجة صغيرة؟»',
                CompanionPersona.practical =>
                  '«حدد عشر دقايق، اقفل الإشعارات، وافتح أول مهمة.»',
                CompanionPersona.balancedFaith =>
                  '«خذ بالأسباب بهدوء، واستعن بالله، ثم ابدأ بما تستطيع.»',
              }),
              onTap: () => setState(() => _persona = entry.key),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _companionName,
          decoration: const InputDecoration(labelText: 'سمّي رفيقك (اختياري)'),
        ),
      ]);

  Widget _page4() => _wrap([
        Text('التنبيهات على مزاجك',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('قليلة، هادئة، وفيها فعل صغير — مش مجرد اقتباس. '
            'ولو اتجاهلتها هتقل لوحدها بدل ما تزن عليك.',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        SectionCard(
          title: 'كام تنبيه في اليوم؟',
          child: Slider(
            value: _notificationsPerDay.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            label: '$_notificationsPerDay',
            onChanged: (v) =>
                setState(() => _notificationsPerDay = v.round()),
          ),
        ),
        Text('مش هنطلب إذن الإشعارات دلوقتي — لما تيجي تجدول أول تذكير.',
            style: Theme.of(context).textTheme.bodySmall),
      ]);

  Widget _page5() => _wrap([
        Text('خصوصيتك أولًا',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        const SectionCard(
          child: Text(
            'بياناتك محفوظة على جهازك افتراضيًا.\n\n'
            '• لا حسابات ولا تسجيل دخول.\n'
            '• لا إعلانات ولا متابعة.\n'
            '• العبادات والأمور الحساسة خاصة دائمًا.\n'
            '• رِفْق ليس بديلًا عن طبيب أو معالج.',
          ),
        ),
      ]);
}
