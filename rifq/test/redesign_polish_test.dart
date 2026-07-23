import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/providers.dart';
import 'package:rifq/features/compass/decision_room_screen.dart';
import 'package:rifq/features/compass/values_garden_screen.dart';
import 'package:rifq/features/home/home_screen.dart';
import 'package:rifq/features/home/system_hub.dart';
import 'package:rifq/features/mirror/museum_of_returning_screen.dart';
import 'package:rifq/features/sanctuary/retreat_screen.dart';
import 'package:rifq/features/sanctuary/sanctuary_screen.dart';

import 'fakes.dart';

Widget _host(Widget child, {double textScale = 1.0}) {
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
      valuesRepoProvider.overrideWithValue(FakeValuesRepository()),
      schedulerProvider.overrideWithValue(FakeNotificationScheduler()),
      instagramLauncherProvider.overrideWithValue(FakeInstagramLauncher()),
      usageStatsProvider.overrideWithValue(FakeUsageStatsGateway()),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(textScale),
          ),
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
  // كل شاشات إعادة التصميم تُبنى دون استثناء (تشمل overflow في وضع الاختبار).
  final screens = <String, Widget>{
    'المرآة (hub)': const MirrorHubScreen(),
    'متحف العودة': const MuseumOfReturningScreen(),
    'البوصلة (hub)': const CompassHubScreen(),
    'حديقة القيم': const ValuesGardenScreen(),
    'غرفة القرار': const DecisionRoomScreen(),
    'الملجأ (hub)': const SanctuaryHubScreen(),
    'مشاعر الملجأ': const SanctuaryScreen(),
    'وضع الخلوة': const RetreatScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} تُبنى بلا أخطاء', (tester) async {
      await tester.pumpWidget(_host(entry.value));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('الحديقة الرئيسية صامدة عند تكبير الخط 1.6', (tester) async {
    await tester.pumpWidget(_host(const HomeScreen(), textScale: 1.6));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('المرآة'), findsOneWidget);
  });

  testWidgets('الملجأ يعرض السؤال الواحد والمشاعر الثمانية', (tester) async {
    await tester.pumpWidget(_host(const SanctuaryScreen()));
    await tester.pump();
    expect(find.text('ماذا يحدث داخلك الآن؟'), findsOneWidget);
    expect(find.text('مرهق'), findsOneWidget);
    // آخر شعور أسفل قائمة قابلة للتمرير.
    await tester.scrollUntilVisible(find.text('لا أعرف'), 120,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('لا أعرف'), findsOneWidget);
  });
}
