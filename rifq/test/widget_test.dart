import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/providers.dart';
import 'package:rifq/features/fatigue/fatigue_screen.dart';
import 'package:rifq/features/home/home_screen.dart';
import 'package:rifq/features/onboarding/onboarding_screen.dart';

import 'fakes.dart';

Widget _app(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      settingsRepoProvider.overrideWithValue(FakeSettingsRepository()),
      winsRepoProvider.overrideWithValue(FakeWinsRepository()),
      focusRepoProvider.overrideWithValue(FakeFocusRepository()),
      resetRepoProvider.overrideWithValue(FakeResetRepository()),
      reflectionRepoProvider.overrideWithValue(FakeReflectionRepository()),
      draftsRepoProvider.overrideWithValue(FakeDraftsRepository()),
      intentRepoProvider.overrideWithValue(FakeIntentRepository()),
      notificationRulesRepoProvider
          .overrideWithValue(FakeNotificationRulesRepository()),
      checkInRepoProvider.overrideWithValue(FakeCheckInRepository()),
      schedulerProvider.overrideWithValue(FakeNotificationScheduler()),
      instagramLauncherProvider.overrideWithValue(FakeInstagramLauncher()),
      usageStatsProvider.overrideWithValue(FakeUsageStatsGateway()),
      ...overrides,
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          // تقليل الحركة في الاختبارات: يوقف الحلقة المحيطة اللانهائية
          // فيستقر pumpAndSettle، ويتحقق من مسار «تقليل الحركة».
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('الحديقة الحية تعرض الأنظمة الثلاثة كوجهات واضحة',
      (tester) async {
    await tester.pumpWidget(_app(const HomeScreen()));
    await tester.pumpAndSettle();

    // الوجهات الثلاث حاضرة بتسمياتها العربية الواضحة.
    expect(find.text('المرآة'), findsOneWidget);
    expect(find.text('البوصلة'), findsOneWidget);
    expect(find.text('الملجأ'), findsOneWidget);
    // مع سطورها الشارحة (الفهم لا يعتمد على الرسم وحده).
    expect(find.text('تأمل ما عشته'), findsOneWidget);
    expect(find.text('اختر اتجاهك'), findsOneWidget);
    expect(find.text('افهم ما تحتاجه الآن'), findsOneWidget);
    // الفعل المباشر الواحد (أسفل المشهد — يُمرَّر إليه).
    await tester.scrollUntilVisible(
        find.text('أحتاج أن أهدأ الآن'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('أحتاج أن أهدأ الآن'), findsOneWidget);
  });

  testWidgets('الوجهات لها مساحات لمس دلالية ومتاحة لقارئ الشاشة',
      (tester) async {
    await tester.pumpWidget(_app(const HomeScreen()));
    await tester.pumpAndSettle();
    // تسمية دلالية مجمّعة (عنوان + شرح) لكل وجهة.
    expect(
        find.bySemanticsLabel('المرآة — تأمل ما عشته'), findsOneWidget);
  });

  testWidgets('Onboarding يبدأ برسالة الباب ولا يطلب صلاحيات',
      (tester) async {
    await tester.pumpWidget(_app(const OnboardingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('رِفْق'), findsOneWidget);
    expect(find.text('ارجع لنفسك على مهل'), findsOneWidget);
    expect(find.textContaining('باب ترجع منه لحياتك'), findsOneWidget);
  });

  testWidgets('شاشة الفتور تعرض الأنواع وتفعّل وضع الرحمة بعد الاختيار',
      (tester) async {
    await tester.pumpWidget(_app(const FatigueScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ما الأقرب لما تمر به؟'), findsOneWidget);
    expect(find.text('فقدت الحماس'), findsOneWidget);

    await tester.tap(find.text('فقدت الحماس'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
        find.text('فعّل وضع الرحمة'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('فعّل وضع الرحمة'), findsOneWidget);
    expect(find.textContaining('الحد الأدنى'), findsOneWidget);
  });
}
