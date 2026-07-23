/// منطق حديقة القيم — كل قيمة نبتة تنمو من أفعال ذات معنى، وتبطّأ عند
/// الإهمال لكنها لا تموت أبدًا. لا عقوبة ولا حالة فشل. البيانات في
/// core/db/models.dart؛ هنا التسميات والنمو والملاحظة الوصفية فقط.
library;

import '../../core/db/models.dart';

extension ValueKindLabel on ValueKind {
  String get label => switch (this) {
        ValueKind.knowledge => 'العلم',
        ValueKind.health => 'الصحة',
        ValueKind.faith => 'الإيمان',
        ValueKind.family => 'الأسرة',
        ValueKind.calm => 'الهدوء',
        ValueKind.creativity => 'الإبداع',
        ValueKind.service => 'خدمة الناس',
        ValueKind.work => 'العمل',
      };

  /// أمثلة أفعال ذات معنى تخدم القيمة — القيمة الواحدة يخدمها فعل متنوّع.
  String get exampleActions => switch (this) {
        ValueKind.knowledge => 'صفحة كتاب، سؤال محلول، فكرة دوّنتها',
        ValueKind.health => 'مشي، ماء، نوم مبكر، وجبة هادئة',
        ValueKind.faith => 'ذِكر، صلاة في وقتها، لحظة تأمل',
        ValueKind.family => 'مكالمة، زيارة، اعتذار، وقت حاضر',
        ValueKind.calm => 'تنفّس، مساحة فارغة، وقت بلا شاشة',
        ValueKind.creativity => 'رسم، كتابة، تجربة جديدة',
        ValueKind.service => 'مساعدة، صدقة، كلمة طيبة',
        ValueKind.work => 'مهمة صغيرة، خطوة في مشروع',
      };
}

/// مرحلة نمو النبتة — من بذرة إلى مزدهرة.
enum GrowthStage { seed, sprout, growing, established, flourishing }

/// حالة النبتة المرئية: مرحلة + هل هي في راحة (paused) أم تنمو؟
class ValueGrowth {
  const ValueGrowth({required this.stage, required this.resting});

  final GrowthStage stage;

  /// «راحة»: لم تُخدم القيمة مؤخرًا — النمو يتوقف، لكن النبتة تبقى كما هي.
  /// لا موت، ولا تراجع، ولا حالة فشل.
  final bool resting;

  int get leaves => switch (stage) {
        GrowthStage.seed => 0,
        GrowthStage.sprout => 1,
        GrowthStage.growing => 3,
        GrowthStage.established => 5,
        GrowthStage.flourishing => 7,
      };
}

/// عدد الأيام بلا خدمة تُعتبر بعده النبتة «في راحة».
const int valueRestingAfterDays = 10;

extension LifeValueGrowth on LifeValue {
  /// حساب حالة النمو — منطق نقي قابل للاختبار.
  ValueGrowth growth({DateTime? now}) {
    final ref = now ?? DateTime.now();
    final stage = switch (actionCount) {
      0 => GrowthStage.seed,
      >= 1 && <= 2 => GrowthStage.sprout,
      >= 3 && <= 6 => GrowthStage.growing,
      >= 7 && <= 14 => GrowthStage.established,
      _ => GrowthStage.flourishing,
    };
    final anchor = lastActedAt ?? chosenAt;
    final resting = anchor == null ||
        ref.difference(anchor).inDays >= valueRestingAfterDays;
    return ValueGrowth(stage: stage, resting: resting);
  }
}

/// ملخّص وصفي للبوصلة — أين كان المستخدم قريبًا وأين احتاج مساحة.
/// لغة رحيمة لا نِسَب مئوية: «أعطيت العلم مساحة، بينما احتاج جسدك راحة أكبر».
String compassObservation(List<LifeValue> values, {DateTime? now}) {
  if (values.isEmpty) {
    return 'لم تختر قيمك بعد. اختر ما تريد أن تمنحه مساحة، لا ما يبدو مثاليًا.';
  }
  final ref = now ?? DateTime.now();
  final weekAgo = ref.subtract(const Duration(days: 7));
  final active = values
      .where((v) => v.lastActedAt != null && v.lastActedAt!.isAfter(weekAgo))
      .toList()
    ..sort((a, b) => b.actionCount.compareTo(a.actionCount));
  final resting = values.where((v) => v.growth(now: ref).resting).toList();

  if (active.isEmpty) {
    return 'أسبوع هادئ في الحديقة. أصغر فعل واحد يكفي ليعود النمو برفق.';
  }
  final nearest = active.first.kind.label;
  if (resting.isNotEmpty) {
    final far = resting.first.kind.label;
    return 'أعطيت $nearest مساحة هذا الأسبوع، بينما احتاجت $far وقتًا أكثر.';
  }
  return 'كنت قريبًا من $nearest هذا الأسبوع. الحديقة تنمو على مهلها.';
}
