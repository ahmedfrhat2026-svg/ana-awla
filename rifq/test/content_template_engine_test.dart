import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/core/content/content_template_engine.dart';
import 'package:rifq/core/db/models.dart';

void main() {
  const engine = LocalContentTemplateEngine();
  const gate = PrivacyGate();

  SmallWin win({
    WinCategory category = WinCategory.study,
    PrivacyLevel privacy = PrivacyLevel.public,
    String title = 'ذاكرت عشر دقايق',
    String details = 'بدأت رغم قلة الحماس',
  }) =>
      SmallWin(
        id: 1,
        date: '2026-07-21',
        title: title,
        details: details,
        category: category,
        privacyLevel: privacy,
      );

  group('ContentTemplateEngine', () {
    test('يولّد كل الصيغ بدون أخطاء وبنص غير فارغ', () {
      final input = ContentInput(wins: [win()], lesson: 'ابدأ قبل الاستعداد');
      for (final format in ContentFormat.values) {
        final draft = engine.build(format, input);
        expect(draft.body, isNotEmpty, reason: format.name);
        expect(draft.format, format);
        expect(draft.status, DraftStatus.draft);
      }
    });

    test('الإنجاز الخاص لا يظهر في المحتوى أبدًا', () {
      final input = ContentInput(wins: [
        win(
            category: WinCategory.worship,
            privacy: PrivacyLevel.private,
            title: 'صليت الفجر في وقته'),
      ]);
      final draft = engine.build(ContentFormat.caption, input);
      expect(draft.body.contains('صليت الفجر'), isFalse);
      expect(input.shareableWins, isEmpty);
    });

    test('مستوى lessonOnly يعرض الدرس بدل التفاصيل الشخصية', () {
      final input = ContentInput(wins: [
        win(
            privacy: PrivacyLevel.lessonOnly,
            title: 'تفاصيل شخصية جدًا',
            details: 'الدرس: البداية الصغيرة كافية'),
      ]);
      final draft = engine.build(ContentFormat.story, input);
      expect(draft.body.contains('تفاصيل شخصية جدًا'), isFalse);
      expect(draft.body.contains('البداية الصغيرة كافية'), isTrue);
    });

    test('Carousel يحتوي عنوانًا وخاتمة وبحد أقصى 5 شرائح', () {
      final input = ContentInput(
        wins: [win(), win(), win(), win()],
        reflection: 'ملاحظة',
        lesson: '3 حاجات ساعدتني',
      );
      final draft = engine.build(ContentFormat.carousel, input);
      final slides = draft.body.split('\n\n');
      expect(slides.length, lessThanOrEqualTo(6));
      expect(draft.body.contains('الشريحة 1'), isTrue);
      expect(draft.body.contains('الخاتمة'), isTrue);
    });

    test('المحرك deterministic — نفس المدخلات تعطي نفس الناتج', () {
      final input = ContentInput(wins: [win()], lesson: 'درس');
      final a = engine.build(ContentFormat.caption, input);
      final b = engine.build(ContentFormat.caption, input);
      expect(a.body, b.body);
    });
  });

  group('PrivacyGate', () {
    test('الفئات الحساسة خاصة افتراضيًا عند الإنشاء', () {
      for (final category in [
        WinCategory.worship,
        WinCategory.charity,
        WinCategory.privateFamily,
        WinCategory.health,
        WinCategory.financial,
      ]) {
        final w = SmallWin.create(
          date: '2026-07-21',
          title: 'حساس',
          category: category,
          privacyLevel: PrivacyLevel.public, // حتى لو طُلبت public
        );
        expect(w.privacyLevel, PrivacyLevel.private, reason: category.name);
        expect(gate.canShare(w), isFalse);
      }
    });

    test('الفئات العادية يمكن مشاركتها', () {
      final w = SmallWin.create(
        date: '2026-07-21',
        title: 'عادي',
        category: WinCategory.study,
        privacyLevel: PrivacyLevel.public,
      );
      expect(
          gate.canShare(w.copyWith(privacyLevel: PrivacyLevel.public)), isTrue);
    });

    test('العنصر الحساس يُشارك فقط بعد اختيار صريح', () {
      final w = SmallWin.create(
        date: '2026-07-21',
        title: 'حساس',
        category: WinCategory.worship,
      );
      expect(gate.canShare(w), isFalse);
      final explicit = w.copyWith(privacyLevel: PrivacyLevel.lessonOnly);
      expect(gate.canShare(explicit), isTrue);
    });

    test('قرار keepPrivate يحفظ المسودة خاصة', () {
      final draft =
          engine.build(ContentFormat.caption, ContentInput(wins: [win()]));
      final result = gate.apply(draft, GateDecision.keepPrivate);
      expect(result.privacyLevel, PrivacyLevel.private);
      expect(result.status, DraftStatus.keptPrivate);
    });

    test('containsSensitive يكتشف العناصر الحساسة', () {
      expect(
        gate.containsSensitive(
            ContentInput(wins: [win(category: WinCategory.charity)])),
        isTrue,
      );
      expect(
        gate.containsSensitive(ContentInput(wins: [win()])),
        isFalse,
      );
    });
  });
}
