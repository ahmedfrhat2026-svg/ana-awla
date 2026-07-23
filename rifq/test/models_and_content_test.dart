import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/content/sacred_texts.dart';
import 'package:rifq/core/content/seed_texts.dart';
import 'package:rifq/core/db/models.dart';
import 'package:rifq/core/privacy/safety_check.dart';

void main() {
  group('النماذج', () {
    test('FocusSession: جملة إذا–فسوف', () {
      const s = FocusSession(
        subject: 'فسيولوجي',
        task: 'المحاضرة الثالثة',
        tinyStep: 'أفتح المحاضرة وأذاكر عشر دقائق فقط',
        plannedMinutes: 10,
      );
      expect(
        s.implementationIntention('جلست على المكتب الساعة 7'),
        'إذا جلست على المكتب الساعة 7، فسوف أفتح المحاضرة وأذاكر عشر دقائق فقط.',
      );
    });

    test('roundtrip: toMap ثم fromMap يحفظ القيم', () {
      final win = SmallWin.create(
        date: '2026-07-21',
        title: 'فتحت الكتاب',
        category: WinCategory.study,
        privacyLevel: PrivacyLevel.public,
      );
      final restored = SmallWin.fromMap({...win.toMap(), 'id': 5});
      expect(restored.id, 5);
      expect(restored.title, win.title);
      expect(restored.category, win.category);
      expect(restored.privacyLevel, win.privacyLevel);

      const rule = NotificationRule(
        id: 2,
        category: NotificationCategory.studyStart,
        preferredHour: 16,
        preferredMinute: 30,
        ignoredCount: 2,
      );
      final restoredRule = NotificationRule.fromMap(rule.toMap());
      expect(restoredRule.category, rule.category);
      expect(restoredRule.preferredMinute, 30);
      expect(restoredRule.ignoredCount, 2);
    });

    test('وضع الفتور: نشط حتى تاريخه ثم ينتهي', () {
      final active = UserSettings(
          fatigueModeUntil: DateTime.now().add(const Duration(days: 1)));
      final expired = UserSettings(
          fatigueModeUntil: DateTime.now().subtract(const Duration(days: 1)));
      expect(active.fatigueModeActive, isTrue);
      expect(expired.fatigueModeActive, isFalse);
      expect(const UserSettings().fatigueModeActive, isFalse);
    });
  });

  group('المحتوى الأولي', () {
    test('الأعداد المطلوبة موجودة', () {
      expect(tinyActions.length, 30);
      expect(gentleNotifications.length, 30);
      expect(studyNotifications.length, 20);
      expect(scrollReturnPrompts.length, 15);
      expect(eveningReflectionPrompts.length, 15);
      expect(fatigueGentleTexts.length, greaterThanOrEqualTo(10));
    });

    test('لا توجد لغة لوم في أي نص', () {
      const forbidden = ['فشلت', 'ضيعت يومك', 'كسول', 'فاشل'];
      final all = [
        ...tinyActions,
        ...gentleNotifications,
        ...studyNotifications,
        ...scrollReturnPrompts,
        ...eveningReflectionPrompts,
        ...fatigueGentleTexts,
      ];
      for (final text in all) {
        for (final word in forbidden) {
          expect(text.contains(word), isFalse,
              reason: 'وجدت «$word» في: $text');
        }
      }
    });

    test('كل نص ديني له مصدر موثّق', () {
      for (final sacred in calmingTexts) {
        expect(sacred.text, isNotEmpty);
        expect(sacred.source, isNotEmpty);
      }
      expect(appSpiritHadith.source.contains('متفق عليه'), isTrue);
    });
  });

  group('فحص الأمان المحلي', () {
    test('يكتشف الإشارات الواضحة', () {
      expect(containsSelfHarmSignal('مش عايز اعيش خلاص'), isTrue);
      expect(containsSelfHarmSignal('عايز أموت من التعب'), isTrue);
    });

    test('لا ينبّه على نصوص عادية', () {
      expect(containsSelfHarmSignal('ذاكرت وأنا تعبان بس كملت'), isFalse);
      expect(containsSelfHarmSignal(''), isFalse);
      expect(containsSelfHarmSignal('يوم صعب بس عدى'), isFalse);
    });
  });
}
