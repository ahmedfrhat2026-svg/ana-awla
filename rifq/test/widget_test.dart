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
      ...overrides,
    ],
    child: MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('الشاشة الرئيسية تعرض الأبواب الأربعة والسؤال الرئيسي',
      (tester) async {
    await tester.pumpWidget(_app(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ماذا تحتاج الآن؟'), findsOneWidget);
    expect(find.text('أهدأ'), findsOneWidget);
    expect(find.text('أذاكر'), findsOneWidget);

    // العناصر الأدنى في ListView تُبنى عند التمرير فقط.
    await tester.scrollUntilVisible(
        find.text('أنقذني من التمرير'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('أنقذني من التمرير'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('خطوتك الصغيرة اليوم كافية كبداية.'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('خطوتك الصغيرة اليوم كافية كبداية.'), findsOneWidget);
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
