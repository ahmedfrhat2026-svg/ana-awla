import 'package:flutter_test/flutter_test.dart';

import 'package:ana_awla/db/models.dart';
import 'package:ana_awla/services/parser.dart';

void main() {
  final rules = [
    const Rule(keyword: 'أوبر', category: 'مواصلات'),
    const Rule(keyword: 'قهوة', category: 'قهوة'),
    const Rule(keyword: 'كارفور', category: 'بقالة'),
    const Rule(keyword: 'غدا', category: 'أكل'),
  ];
  final parser = ArabicExpenseParser(rules);

  test('قهوة 85 → amount + category', () {
    final r = parser.parse('قهوة 85');
    expect(r, isNotNull);
    expect(r!.amount, 85);
    expect(r.category, 'قهوة');
  });

  test('أوبر 140 كاش → amount + category + payment', () {
    final r = parser.parse('أوبر 140 كاش');
    expect(r, isNotNull);
    expect(r!.amount, 140);
    expect(r.category, 'مواصلات');
    expect(r.paymentMethod, 'كاش');
  });

  test('كارفور 320 فيزا → بقالة + فيزا', () {
    final r = parser.parse('كارفور 320 فيزا');
    expect(r, isNotNull);
    expect(r!.amount, 320);
    expect(r.category, 'بقالة');
    expect(r.paymentMethod, 'فيزا');
  });

  test('غدا 250 → أكل', () {
    final r = parser.parse('غدا 250');
    expect(r, isNotNull);
    expect(r!.amount, 250);
    expect(r.category, 'أكل');
  });

  test('Arabic digits ١٢٠ تُحوَّل لـ 120', () {
    final r = parser.parse('قهوة ١٢٠');
    expect(r, isNotNull);
    expect(r!.amount, 120);
  });

  test('بدون رقم → null', () {
    expect(parser.parse('قهوة'), isNull);
    expect(parser.parse(''), isNull);
  });

  test('عشرية: 12.50 و 12,50', () {
    expect(parser.parse('قهوة 12.50')!.amount, 12.5);
    expect(parser.parse('قهوة 12,50')!.amount, 12.5);
  });
}
