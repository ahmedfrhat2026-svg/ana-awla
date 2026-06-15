import '../db/models.dart';

class ParsedInput {
  final double amount;
  final String? merchant;
  final String? category;
  final String? paymentMethod;
  final String? note;

  const ParsedInput({
    required this.amount,
    this.merchant,
    this.category,
    this.paymentMethod,
    this.note,
  });
}

class ArabicExpenseParser {
  final List<Rule> rules;
  ArabicExpenseParser(this.rules);

  static const _arabicDigits = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    '٫': '.', '،': ',',
  };

  static String normalizeDigits(String s) {
    final b = StringBuffer();
    for (final ch in s.characters) {
      b.write(_arabicDigits[ch] ?? ch);
    }
    return b.toString();
  }

  static const _paymentKeywords = <String, String>{
    'كاش': 'كاش',
    'نقدي': 'كاش',
    'نقد': 'كاش',
    'فيزا': 'فيزا',
    'كارت': 'فيزا',
    'بطاقة': 'فيزا',
    'بنك': 'فيزا',
    'انستاباي': 'انستاباي',
    'إنستاباي': 'انستاباي',
    'instapay': 'انستاباي',
    'فودافون كاش': 'فودافون كاش',
    'محفظة': 'محفظة',
  };

  ParsedInput? parse(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return null;

    var text = normalizeDigits(raw);

    String? paymentMethod;
    for (final entry in _paymentKeywords.entries) {
      final pattern = RegExp(
        r'(?:^|\s)' + RegExp.escape(entry.key) + r'(?:\s|$)',
        caseSensitive: false,
      );
      if (pattern.hasMatch(text)) {
        paymentMethod = entry.value;
        text = text.replaceAll(pattern, ' ');
        break;
      }
    }

    final numMatches = RegExp(r'\d+(?:[.,]\d+)?').allMatches(text).toList();
    if (numMatches.isEmpty) return null;
    final last = numMatches.last;
    final amountStr = last.group(0)!.replaceAll(',', '.');
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return null;

    text = (text.substring(0, last.start) + text.substring(last.end)).trim();
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    text = text.replaceAll(RegExp(r'^(عشان|على|في|من|ل|بـ|ب)\s+'), '');

    String? category;
    String? merchant;
    if (text.isNotEmpty) {
      final lower = text.toLowerCase();
      for (final r in rules) {
        if (lower.contains(r.keyword.toLowerCase())) {
          category = r.category;
          break;
        }
      }
      merchant = text;
    }

    return ParsedInput(
      amount: amount,
      merchant: merchant,
      category: category,
      paymentMethod: paymentMethod,
      note: null,
    );
  }
}
