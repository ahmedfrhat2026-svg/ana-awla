import 'package:flutter_test/flutter_test.dart';
import 'package:rifq/features/sanctuary/emotion_paths.dart';

void main() {
  group('مسارات المشاعر', () {
    test('كل حالة لها تسمية واستجابة بأفعال', () {
      for (final e in Emotion.values) {
        expect(e.label, isNotEmpty);
        final r = responseFor(e);
        expect(r.opening, isNotEmpty);
        expect(r.actions, isNotEmpty);
      }
    });

    test('لكل حالة مسار مختلف (الأفعال ليست متطابقة)', () {
      final signatures =
          Emotion.values.map((e) => responseFor(e).actions.join('|')).toSet();
      // ثماني حالات، ثماني مجموعات أفعال متمايزة.
      expect(signatures.length, Emotion.values.length);
    });

    test('المرهق: راحة لا دفع للإنتاجية', () {
      final r = responseFor(Emotion.tired);
      final all = '${r.opening} ${r.actions.join(' ')}';
      expect(all.contains('راحة') || all.contains('نم'), isTrue);
      for (final push in ['أنجز', 'ذاكر ساعتين', 'اشتغل أكتر']) {
        expect(all.contains(push), isFalse);
      }
    });

    test('الحزين: لغة دعم وتواصل، لا أمر بالعمل', () {
      final r = responseFor(Emotion.sad);
      expect(r.needsSupport, isTrue);
      expect(r.suggestVoiceNote, isTrue);
      final all = r.actions.join(' ');
      expect(all.contains('كلّم') || all.contains('سمِّ'), isTrue);
    });

    test('الخائف: يفصل الحقيقة عن التوقّع ويؤجّل ما لا رجعة فيه', () {
      final r = responseFor(Emotion.afraid);
      final all = r.actions.join(' ');
      expect(all.contains('توقّع') || all.contains('الحقيقة'), isTrue);
      expect(all.contains('رجعة') || all.contains('أجّل'), isTrue);
    });

    test('لا أعرف: يبدأ بفحص جسدي بسيط', () {
      final r = responseFor(Emotion.unknown);
      final all = r.actions.join(' ');
      expect(all.contains('نمت') || all.contains('ماء') || all.contains('أكلت'),
          isTrue);
    });

    test('لا لغة لوم في أي استجابة', () {
      for (final e in Emotion.values) {
        final all =
            '${responseFor(e).opening} ${responseFor(e).actions.join(' ')}';
        for (final bad in ['فشلت', 'كسول', 'ضيعت']) {
          expect(all.contains(bad), isFalse, reason: e.label);
        }
      }
    });
  });
}
