import '../db/models.dart';

/// مدخلات صانع المحتوى الهادئ.
class ContentInput {
  const ContentInput({
    this.wins = const <SmallWin>[],
    this.reflection = '',
    this.lesson = '',
    this.audience = '',
    this.imagePath,
  });

  final List<SmallWin> wins;
  final String reflection;
  final String lesson;
  final String audience;
  final String? imagePath;

  /// الإنجازات القابلة للمشاركة فقط — الحساسة تُستبعد ما لم يختر المستخدم
  /// صراحةً مستوى مشاركة لها.
  List<SmallWin> get shareableWins => wins
      .where((w) =>
          w.privacyLevel == PrivacyLevel.public ||
          w.privacyLevel == PrivacyLevel.lessonOnly)
      .toList();
}

/// نتيجة بوابة النية والخصوصية.
enum GateDecision { keepPrivate, shareLessonOnly, sharePublic, saveDraft }

/// أسئلة Value Check — تأمل صادق قبل النشر، وليس Score تنافسيًا.
const List<String> valueCheckQuestions = [
  'هل هو صادق؟',
  'هل فيه فائدة لغيرك؟',
  'هل يحفظ خصوصيتك وخصوصية الآخرين؟',
  'هل ستنشره لو لم تظهر الأرقام؟',
  'هل يحتوي ادعاءً علميًا أو دينيًا يحتاج مصدرًا؟',
];

/// أسئلة بوابة النية — تُعرض قبل توليد أي محتوى.
const String intentionGateQuestion1 =
    'لو اختفت المشاهدات والإعجابات، هل ما زلت تريد نشر هذا؟';
const String intentionGateQuestion2 =
    'هل في هذا شيء الأفضل أن يبقى بينك وبين الله؟';

/// واجهة محرك القوالب — التنفيذ الحالي deterministic بالكامل بدون أي AI.
abstract interface class ContentTemplateEngine {
  ContentDraft build(ContentFormat format, ContentInput input);
}

/// محرك القوالب المحلي: يحوّل الإنجازات والتأملات إلى صيغ إنستجرام هادئة.
class LocalContentTemplateEngine implements ContentTemplateEngine {
  const LocalContentTemplateEngine();

  static const _signature = '\n\n#خطوة_صغيرة #حياة_أبطأ';

  @override
  ContentDraft build(ContentFormat format, ContentInput input) {
    final body = switch (format) {
      ContentFormat.story => _story(input),
      ContentFormat.caption => _caption(input),
      ContentFormat.carousel => _carousel(input),
      ContentFormat.reelScript => _reelScript(input),
      ContentFormat.weeklyHarvest => _weeklyHarvest(input),
    };
    return ContentDraft(
      sourceWinIds:
          input.shareableWins.map((w) => w.id).whereType<int>().toList(),
      format: format,
      title: _title(format, input),
      body: body,
      privacyLevel: PrivacyLevel.draft,
      status: DraftStatus.draft,
      imagePath: input.imagePath,
    );
  }

  String _title(ContentFormat format, ContentInput input) {
    final first = input.shareableWins.isNotEmpty
        ? input.shareableWins.first.title
        : (input.lesson.isNotEmpty ? input.lesson : 'لحظة هادئة');
    return switch (format) {
      ContentFormat.story => 'Story — $first',
      ContentFormat.caption => 'Caption — $first',
      ContentFormat.carousel => 'Carousel — $first',
      ContentFormat.reelScript => 'Reel — $first',
      ContentFormat.weeklyHarvest => 'حصاد الأسبوع',
    };
  }

  String _winLine(SmallWin w) =>
      w.privacyLevel == PrivacyLevel.lessonOnly && w.details.isNotEmpty
          ? w.details // «شارك الدرس دون التفاصيل الشخصية»
          : w.title;

  String _story(ContentInput i) {
    final win = i.shareableWins.isNotEmpty
        ? _winLine(i.shareableWins.first)
        : 'بدأت رغم إني ما كنتش متحمس';
    return 'الإنجاز البسيط اليوم:\n$win\n\n'
        '${i.lesson.isNotEmpty ? i.lesson : 'الخطوة الصغيرة كانت كافية كبداية.'}';
  }

  String _caption(ContentInput i) {
    final b = StringBuffer();
    if (i.shareableWins.isNotEmpty) {
      b.writeln(_winLine(i.shareableWins.first));
      b.writeln();
    }
    if (i.reflection.isNotEmpty) {
      b.writeln(i.reflection);
      b.writeln();
    }
    b.write(i.lesson.isNotEmpty
        ? i.lesson
        : 'مش محتاج تستنى الحماس. ابدأ قبل ما تحس إنك جاهز.');
    b.write(_signature);
    return b.toString();
  }

  String _carousel(ContentInput i) {
    final slides = <String>[];
    final headline =
        i.lesson.isNotEmpty ? i.lesson : 'حاجات صغيرة رجّعتني لنفسي';
    slides.add('الشريحة 1 — العنوان:\n$headline');
    var n = 2;
    for (final w in i.shareableWins.take(3)) {
      slides.add('الشريحة $n:\n${_winLine(w)}');
      n++;
    }
    if (i.reflection.isNotEmpty && slides.length < 5) {
      slides.add('الشريحة $n:\n${i.reflection}');
      n++;
    }
    slides.add('الشريحة $n — الخاتمة:\nبداية صغيرة أفضل من خطة مثالية.');
    return slides.join('\n\n');
  }

  String _reelScript(ContentInput i) {
    final win = i.shareableWins.isNotEmpty
        ? _winLine(i.shareableWins.first)
        : 'فتحت الكتاب وكتبت أول سطر';
    return 'Reel هادئ (15–30 ثانية)\n\n'
        'اللقطات:\n'
        '- وضع الهاتف بعيدًا.\n'
        '- $win.\n'
        '- كوب ماء.\n'
        '- إغلاق الدفتر بهدوء.\n\n'
        'التعليق الصوتي:\n'
        '"${i.lesson.isNotEmpty ? i.lesson : 'لم أحتج أن أستعيد شغفي كله. احتجت فقط أن أبدأ قبل أن أشعر أنني مستعد.'}"';
  }

  String _weeklyHarvest(ContentInput i) {
    final b = StringBuffer('حصاد الأسبوع 🌿\n\n');
    if (i.shareableWins.isEmpty) {
      b.writeln('أسبوع هادئ — الاستمرار نفسه كان الإنجاز.');
    } else {
      for (final w in i.shareableWins.take(3)) {
        b.writeln('• ${_winLine(w)}');
      }
    }
    if (i.lesson.isNotEmpty) b.write('\nدرس الأسبوع: ${i.lesson}\n');
    if (i.reflection.isNotEmpty) b.write('\n${i.reflection}\n');
    b.write('\nنية الأسبوع القادم: خطوة صغيرة واحدة تتكرر.');
    b.write(_signature);
    return b.toString();
  }
}

/// منطق بوابة الخصوصية: تحديد ما إذا كان يمكن المضي في المشاركة.
class PrivacyGate {
  const PrivacyGate();

  /// هل تحتوي المدخلات على عناصر حساسة (عبادة، صدقة، عائلة، صحة، مال)؟
  bool containsSensitive(ContentInput input) =>
      input.wins.any((w) => w.category.sensitiveByDefault);

  /// تطبيق قرار البوابة على مسودة.
  ContentDraft apply(ContentDraft draft, GateDecision decision) =>
      switch (decision) {
        GateDecision.keepPrivate => draft.copyWith(
            privacyLevel: PrivacyLevel.private,
            status: DraftStatus.keptPrivate),
        GateDecision.shareLessonOnly => draft.copyWith(
            privacyLevel: PrivacyLevel.lessonOnly, status: DraftStatus.draft),
        GateDecision.sharePublic => draft.copyWith(
            privacyLevel: PrivacyLevel.public, status: DraftStatus.draft),
        GateDecision.saveDraft => draft.copyWith(
            privacyLevel: PrivacyLevel.draft, status: DraftStatus.draft),
      };

  /// لا يُسمح بمشاركة عنصر حساس إلا إذا غيّر المستخدم خصوصيته صراحةً.
  bool canShare(SmallWin win) =>
      !win.category.sensitiveByDefault ||
      win.privacyLevel == PrivacyLevel.public ||
      win.privacyLevel == PrivacyLevel.lessonOnly;
}
