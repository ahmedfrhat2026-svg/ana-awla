import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models.dart';
import '../../core/providers.dart';

/// نموذج عرض للحظة عودة — مشتق من [ResetSession] المكتملة.
/// المرآة تحتفظ بلحظات الرجوع بعد الانقطاع، لا بعدد أيام الالتزام.
class ReturnMoment {
  const ReturnMoment({
    required this.when,
    required this.returnedTo,
    required this.tinyAction,
  });

  final DateTime when;

  /// ما الذي كان المستخدم عائدًا إليه (الاحتياج المختار).
  final String returnedTo;

  /// أصغر خطوة أرضية اختارها للعودة.
  final String tinyAction;

  factory ReturnMoment.fromReset(ResetSession s) => ReturnMoment(
        when: s.createdAt ?? DateTime.now(),
        returnedTo: s.selectedNeed.isEmpty ? 'نفسك' : s.selectedNeed,
        tinyAction: s.tinyAction,
      );
}

/// ملخّص وصفي للمرآة — لا رقم يطارده المستخدم، بل قصّة قصيرة صادقة.
class ReturnsSummary {
  const ReturnsSummary({
    required this.total,
    required this.thisWeek,
    required this.sentence,
    required this.moments,
  });

  final int total;
  final int thisWeek;
  final String sentence;
  final List<ReturnMoment> moments;
}

/// يبني الملخّص الوصفي من لحظات العودة — الرقم متاح لكنه ليس البطل.
ReturnsSummary buildReturnsSummary(List<ReturnMoment> moments,
    {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final weekAgo = ref.subtract(const Duration(days: 7));
  final thisWeek = moments.where((m) => m.when.isAfter(weekAgo)).length;
  final total = moments.length;

  final String sentence;
  if (total == 0) {
    sentence =
        'لا توجد لحظات هنا بعد. أول مرة تعود فيها من التوهان، سيبقى أثرها.';
  } else if (thisWeek == 0) {
    sentence =
        'لم تحتج للعودة هذا الأسبوع. المساحة هنا كلما تُهت واحتجت أن ترجع.';
  } else if (thisWeek == 1) {
    sentence = 'هذا الأسبوع، وجدت طريقك للعودة مرة. العودة نفسها هي المهارة.';
  } else {
    sentence = 'رغم ما مررت به، عدت إلى ما يهمك أكثر من مرة هذا الأسبوع. '
        'النجاح ليس ألا تقع، بل أن تصبح العودة أسرع وأهدأ.';
  }

  return ReturnsSummary(
    total: total,
    thisWeek: thisWeek,
    sentence: sentence,
    moments: moments,
  );
}

const _arWeekdays = [
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];
const _arMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// تنسيق تاريخ عربي محلي بلا اعتماد على بيانات locale (يعمل دون إنترنت).
String arabicDate(DateTime d) =>
    '${_arWeekdays[d.weekday - 1]} ${d.day} ${_arMonths[d.month - 1]}';

/// مزوّد لحظات العودة — يقرأ جلسات العودة المكتملة، الأحدث أولًا.
final returnsSummaryProvider =
    FutureProvider.autoDispose<ReturnsSummary>((ref) async {
  final sessions = await ref.watch(resetRepoProvider).recent(limit: 200);
  final moments = sessions
      .where((s) => s.completed)
      .map(ReturnMoment.fromReset)
      .toList()
    ..sort((a, b) => b.when.compareTo(a.when));
  return buildReturnsSummary(moments);
});
