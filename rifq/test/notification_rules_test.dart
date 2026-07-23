import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/db/models.dart';
import 'package:rifq/core/notifications/notification_rules_engine.dart';

void main() {
  const engine = NotificationRulesEngine();

  NotificationRule rule({
    NotificationCategory category = NotificationCategory.morningGrounding,
    int hour = 9,
    int minute = 0,
    bool enabled = true,
    int ignored = 0,
  }) =>
      NotificationRule(
        id: category.index + 1,
        category: category,
        enabled: enabled,
        preferredHour: hour,
        preferredMinute: minute,
        ignoredCount: ignored,
      );

  group('ساعات الصمت', () {
    test('نطاق عادي (13 إلى 15)', () {
      expect(engine.isQuietHour(13, start: 13, end: 15), isTrue);
      expect(engine.isQuietHour(14, start: 13, end: 15), isTrue);
      expect(engine.isQuietHour(15, start: 13, end: 15), isFalse);
      expect(engine.isQuietHour(9, start: 13, end: 15), isFalse);
    });

    test('نطاق عابر لمنتصف الليل (22 إلى 8)', () {
      expect(engine.isQuietHour(23, start: 22, end: 8), isTrue);
      expect(engine.isQuietHour(3, start: 22, end: 8), isTrue);
      expect(engine.isQuietHour(8, start: 22, end: 8), isFalse);
      expect(engine.isQuietHour(12, start: 22, end: 8), isFalse);
    });

    test('بداية = نهاية تعني لا صمت', () {
      expect(engine.isQuietHour(10, start: 0, end: 0), isFalse);
    });
  });

  group('اختيار تنبيهات اليوم', () {
    final day = DateTime(2026, 7, 21); // يوم فردي

    test('يحترم الحد الأقصى اليومي', () {
      final rules = [
        rule(category: NotificationCategory.morningGrounding, hour: 8),
        rule(category: NotificationCategory.studyStart, hour: 12),
        rule(category: NotificationCategory.eveningHarvest, hour: 16),
        rule(category: NotificationCategory.returnFromScrolling, hour: 20),
      ];
      final selected = engine.selectForDay(rules,
          maxPerDay: 3, quietStart: 23, quietEnd: 6, day: day);
      expect(selected.length, 3);
    });

    test('يستبعد الفئات المعطلة وتنبيهات ساعات الصمت', () {
      final rules = [
        rule(category: NotificationCategory.morningGrounding, hour: 2),
        rule(
            category: NotificationCategory.studyStart,
            hour: 12,
            enabled: false),
        rule(category: NotificationCategory.eveningHarvest, hour: 16),
      ];
      final selected = engine.selectForDay(rules,
          maxPerDay: 3, quietStart: 22, quietEnd: 8, day: day);
      expect(selected.length, 1);
      expect(selected.first.category, NotificationCategory.eveningHarvest);
    });

    test('الفئة المتجاهَلة 3 مرات تُخفف: تظهر يومًا بعد يوم', () {
      final rules = [
        rule(
            category: NotificationCategory.morningGrounding,
            hour: 9,
            ignored: 3),
      ];
      final oddDay = DateTime(2026, 7, 21);
      final evenDay = DateTime(2026, 7, 22);
      expect(
          engine
              .selectForDay(rules,
                  maxPerDay: 3, quietStart: 0, quietEnd: 0, day: oddDay)
              .isEmpty,
          isTrue);
      expect(
          engine
              .selectForDay(rules,
                  maxPerDay: 3, quietStart: 0, quietEnd: 0, day: evenDay)
              .length,
          1);
    });

    test('لا تنبيهين خلال أقل من 90 دقيقة', () {
      final rules = [
        rule(category: NotificationCategory.morningGrounding, hour: 9),
        rule(category: NotificationCategory.studyStart, hour: 9, minute: 30),
        rule(category: NotificationCategory.eveningHarvest, hour: 12),
      ];
      final selected = engine.selectForDay(rules,
          maxPerDay: 5, quietStart: 0, quietEnd: 0, day: day);
      expect(selected.length, 2);
    });
  });

  group('عدادات التجاهل', () {
    test('التجاهل يزيد العداد والتفاعل يصفّره', () {
      var r = rule();
      r = engine.markIgnored(r);
      r = engine.markIgnored(r);
      expect(r.ignoredCount, 2);
      expect(r.reducedFrequency, isFalse);
      r = engine.markIgnored(r);
      expect(r.reducedFrequency, isTrue);
      r = engine.markEngaged(r);
      expect(r.ignoredCount, 0);
      expect(r.reducedFrequency, isFalse);
    });
  });

  group('اختيار النص', () {
    test('deterministic حسب اليوم ولا يتجاوز حدود القائمة', () {
      const texts = ['أ', 'ب', 'ج'];
      final day = DateTime(2026, 7, 21);
      expect(engine.pickText(texts, day), engine.pickText(texts, day));
      for (var i = 0; i < 10; i++) {
        final text = engine.pickText(texts, day.add(Duration(days: i)));
        expect(texts.contains(text), isTrue);
      }
    });
  });
}
