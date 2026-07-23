import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/db/models.dart';
import 'package:rifq/features/compass/life_value.dart';

void main() {
  final now = DateTime(2026, 7, 23, 12);

  LifeValue v(ValueKind k,
          {int count = 0, DateTime? acted, DateTime? chosen}) =>
      LifeValue(
        kind: k,
        actionCount: count,
        chosenAt: chosen ?? now,
        lastActedAt: acted,
      );

  group('نمو القيمة', () {
    test('المراحل تتصاعد مع عدد الأفعال', () {
      expect(v(ValueKind.knowledge, count: 0).growth(now: now).stage,
          GrowthStage.seed);
      expect(
          v(ValueKind.knowledge, count: 2, acted: now).growth(now: now).stage,
          GrowthStage.sprout);
      expect(
          v(ValueKind.knowledge, count: 5, acted: now).growth(now: now).stage,
          GrowthStage.growing);
      expect(
          v(ValueKind.knowledge, count: 10, acted: now).growth(now: now).stage,
          GrowthStage.established);
      expect(
          v(ValueKind.knowledge, count: 30, acted: now).growth(now: now).stage,
          GrowthStage.flourishing);
    });

    test('الإهمال يُدخلها راحة — لا موت ولا تراجع', () {
      final neglected = v(ValueKind.health,
          count: 10, acted: now.subtract(const Duration(days: 15)));
      final g = neglected.growth(now: now);
      // المرحلة تبقى كما هي (لا تراجع).
      expect(g.stage, GrowthStage.established);
      // لكنها في راحة.
      expect(g.resting, isTrue);
    });

    test('فعل حديث يُبقيها نامية', () {
      final active = v(ValueKind.faith,
          count: 4, acted: now.subtract(const Duration(days: 2)));
      expect(active.growth(now: now).resting, isFalse);
    });

    test('أصغر فعل يُعيدها من الراحة ويزيد العدّاد', () {
      final resting = v(ValueKind.calm,
          count: 3, acted: now.subtract(const Duration(days: 20)));
      expect(resting.growth(now: now).resting, isTrue);
      final revived = resting.actOn(at: now);
      expect(revived.actionCount, 4);
      expect(revived.growth(now: now).resting, isFalse);
    });
  });

  group('ملاحظة البوصلة', () {
    test('بلا قيم: دعوة للاختيار', () {
      expect(compassObservation(const [], now: now).contains('لم تختر قيمك'),
          isTrue);
    });

    test('قيمة نشطة وأخرى مهملة: لغة رحيمة بلا نِسَب', () {
      final s = compassObservation([
        v(ValueKind.knowledge,
            count: 6, acted: now.subtract(const Duration(days: 1))),
        v(ValueKind.health,
            count: 2, acted: now.subtract(const Duration(days: 20))),
      ], now: now);
      expect(s.contains('العلم'), isTrue);
      expect(s.contains('الصحة'), isTrue);
      // لا نِسَب مئوية ولا لغة فشل.
      for (final bad in ['٪', '%', 'فشلت', 'نقاط']) {
        expect(s.contains(bad), isFalse);
      }
    });
  });

  group('التسميات', () {
    test('كل القيم لها تسمية عربية وأمثلة أفعال', () {
      for (final k in ValueKind.values) {
        expect(k.label, isNotEmpty);
        expect(k.exampleActions, isNotEmpty);
      }
    });
  });

  group('roundtrip LifeValue', () {
    test('يحفظ العدّاد والتواريخ', () {
      final original = v(ValueKind.family, count: 7, acted: now, chosen: now);
      final restored = LifeValue.fromMap({...original.toMap(), 'id': 3});
      expect(restored.id, 3);
      expect(restored.kind, ValueKind.family);
      expect(restored.actionCount, 7);
    });
  });
}
