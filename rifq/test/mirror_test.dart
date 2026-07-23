import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/db/models.dart';
import 'package:rifq/features/mirror/return_moment.dart';

ReturnMoment _m(DateTime when,
        {String to = 'المذاكرة', String step = 'صفحة'}) =>
    ReturnMoment(when: when, returnedTo: to, tinyAction: step);

void main() {
  final now = DateTime(2026, 7, 23, 12);

  group('ملخّص متحف العودة', () {
    test('بلا لحظات: جملة رحيمة ولا رقم يطارد', () {
      final s = buildReturnsSummary(const [], now: now);
      expect(s.total, 0);
      expect(s.thisWeek, 0);
      expect(s.sentence.contains('لا توجد'), isTrue);
      // لا تُستخدم لغة إنجاز أو فشل.
      for (final bad in ['فشلت', 'نقاط', 'streak', '٪', '%']) {
        expect(s.sentence.contains(bad), isFalse);
      }
    });

    test('عودة واحدة هذا الأسبوع', () {
      final s = buildReturnsSummary(
        [_m(now.subtract(const Duration(days: 2)))],
        now: now,
      );
      expect(s.total, 1);
      expect(s.thisWeek, 1);
      expect(s.sentence.contains('مرة'), isTrue);
    });

    test('عدة عودات: يميّز الأسبوع عن الإجمالي، والجملة عن سرعة العودة', () {
      final s = buildReturnsSummary(
        [
          _m(now.subtract(const Duration(days: 1))),
          _m(now.subtract(const Duration(days: 3))),
          _m(now.subtract(const Duration(days: 20))), // خارج الأسبوع
        ],
        now: now,
      );
      expect(s.total, 3);
      expect(s.thisWeek, 2);
      expect(s.sentence.contains('أسرع وأهدأ'), isTrue);
    });

    test('عودات قديمة فقط: الأسبوع صفر بجملة مطمئنة', () {
      final s = buildReturnsSummary(
        [_m(now.subtract(const Duration(days: 30)))],
        now: now,
      );
      expect(s.total, 1);
      expect(s.thisWeek, 0);
      expect(s.sentence.contains('لم تحتج للعودة هذا الأسبوع'), isTrue);
    });
  });

  group('ReturnMoment.fromReset', () {
    test('يشتق الاحتياج والخطوة، ويتراجع لـ«نفسك» عند الفراغ', () {
      final empty = ReturnMoment.fromReset(
          const ResetSession(selectedNeed: '', tinyAction: ''));
      expect(empty.returnedTo, 'نفسك');
      final full = ReturnMoment.fromReset(
          const ResetSession(selectedNeed: 'أذاكر', tinyAction: 'افتح صفحة'));
      expect(full.returnedTo, 'أذاكر');
      expect(full.tinyAction, 'افتح صفحة');
    });
  });

  group('التاريخ العربي المحلي', () {
    test('ينسّق دون بيانات locale', () {
      // 2026-07-23 هو يوم خميس.
      expect(arabicDate(DateTime(2026, 7, 23)), 'الخميس 23 يوليو');
    });
  });
}
