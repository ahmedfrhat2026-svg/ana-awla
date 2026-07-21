import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/content/sacred_texts.dart';
import 'package:rifq/core/db/models.dart';
import 'package:rifq/core/notifications/notification_rules_engine.dart';
import 'package:rifq/features/rewards/pebble_path.dart';

void main() {
  group('محاسبة التجاهل عند الجدولة', () {
    const engine = NotificationRulesEngine();
    final now = DateTime(2026, 7, 21, 9);

    test('أول جدولة لا تُحسب تجاهلًا', () {
      const rule =
          NotificationRule(category: NotificationCategory.studyStart);
      final updated = engine.accountOnSchedule(rule, now);
      expect(updated.ignoredCount, 0);
      expect(updated.lastTriggeredAt, now);
    });

    test('تنبيه أُرسل بلا تفاعل بعده = تجاهل', () {
      final rule = NotificationRule(
        category: NotificationCategory.studyStart,
        lastTriggeredAt: now.subtract(const Duration(days: 1)),
      );
      final updated = engine.accountOnSchedule(rule, now);
      expect(updated.ignoredCount, 1);
    });

    test('التفاعل بعد الإرسال يمنع احتساب التجاهل', () {
      final rule = NotificationRule(
        category: NotificationCategory.studyStart,
        lastTriggeredAt: now.subtract(const Duration(days: 1)),
        lastEngagedAt: now.subtract(const Duration(hours: 20)),
      );
      final updated = engine.accountOnSchedule(rule, now);
      expect(updated.ignoredCount, 0);
    });

    test('markEngaged يصفّر العداد ويسجل الوقت', () {
      final engaged = engine.markEngaged(
        const NotificationRule(
            category: NotificationCategory.studyStart, ignoredCount: 4),
        at: now,
      );
      expect(engaged.ignoredCount, 0);
      expect(engaged.lastEngagedAt, now);
    });
  });

  group('طريق الحصى', () {
    const logic = PebblePathLogic();

    test('قبل أول حجر: لا محطة، والقادمة هي الأولى', () {
      expect(logic.reached(0), isNull);
      expect(logic.next(0)!.$1, 1);
    });

    test('المحطات تتقدم بهدوء ولا تنكسر أبدًا', () {
      expect(logic.reached(5)!.$1, 5);
      expect(logic.next(5)!.$1, 10);
      expect(logic.reached(120)!.$1, 100);
      expect(logic.next(120)!.$1, 200);
      expect(logic.next(500), isNull);
      expect(logic.reached(500)!.$1, 200);
    });
  });

  group('النصوص الدينية الجديدة', () {
    test('كل نص تدبر له مصدر مذكور', () {
      for (final t in calmingTexts.where((t) => t.hasTadabbur)) {
        expect(t.tadabburSource, isNotNull);
        expect(t.tadabburSource!.contains('مصحف التدبّر'), isTrue);
      }
      expect(calmingTexts.where((t) => t.hasTadabbur).length,
          greaterThanOrEqualTo(3));
    });

    test('آيات بوابة القرآن كلها من نوع آية وبمصدر', () {
      expect(gateAyat.length, greaterThanOrEqualTo(5));
      for (final ayah in gateAyat) {
        expect(ayah.kind, SacredKind.ayah);
        expect(ayah.source.contains('سورة'), isTrue);
      }
    });
  });

  group('FocusSession v2', () {
    test('roundtrip يحفظ صورة الملاحظات', () {
      const s = FocusSession(
        subject: 'كيمياء',
        task: '',
        tinyStep: 'صفحة واحدة',
        plannedMinutes: 10,
        notesImagePath: '/tmp/notes.jpg',
      );
      final restored = FocusSession.fromMap(s.toMap());
      expect(restored.notesImagePath, '/tmp/notes.jpg');
    });
  });
}
