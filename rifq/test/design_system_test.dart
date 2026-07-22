import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/design_system/rifq_spacing.dart';
import 'package:rifq/design_system/rifq_theme.dart';
import 'package:rifq/design_system/rifq_theme_extensions.dart';

void main() {
  group('نظام التصميم', () {
    test('سلّم المسافات متصاعد ومتّسق', () {
      expect(RifqSpacing.xxs, 4);
      expect(RifqSpacing.md, 16);
      expect(RifqSpacing.xxxl, 64);
      expect(RifqSpacing.pageH, greaterThanOrEqualTo(20));
    });

    test('الثيم الفاتح يحمل امتداد لوحة الحديقة', () {
      final theme = rifqLightTheme();
      final palette = theme.extension<RifqPalette>();
      expect(palette, isNotNull);
      expect(palette!.canvas, const Color(0xFFF5F1E8));
      expect(theme.textTheme.headlineSmall, isNotNull);
      expect(theme.brightness, Brightness.light);
    });

    test('الثيم الداكن يحمل لوحة داكنة متّسقة', () {
      final theme = rifqDarkTheme();
      final palette = theme.extension<RifqPalette>();
      expect(palette, isNotNull);
      expect(theme.brightness, Brightness.dark);
      // النص الأساسي فاتح على خلفية داكنة (تباين كافٍ).
      expect(palette!.textPrimary.computeLuminance(),
          greaterThan(palette.canvas.computeLuminance()));
    });

    testWidgets('RifqPalette.of يعطي تراجعًا آمنًا بلا امتداد', (tester) async {
      late RifqPalette resolved;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          resolved = RifqPalette.of(context);
          return const SizedBox();
        }),
      ));
      // بلا ثيم رِفْق يرجع للوضع الفاتح الافتراضي بدل ما يرمي.
      expect(resolved.canvas, RifqPalette.light.canvas);
    });

    testWidgets('الثيم يطبّق Cairo على النص وRTL يعمل', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: rifqLightTheme(),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: Text('مرحبا')),
        ),
      ));
      final ctx = tester.element(find.text('مرحبا'));
      // التسلسل الهرمي: العناوين أثقل من الجسد (بلا اعتماد على اسم الخط).
      expect(
          Theme.of(ctx).textTheme.headlineSmall?.fontWeight, FontWeight.w700);
      expect(Theme.of(ctx).textTheme.bodyLarge?.fontWeight, FontWeight.w400);
      expect(Directionality.of(ctx), TextDirection.rtl);
    });
  });
}
