/// نماذج البيانات الأساسية لتطبيق رِفْق — كلها immutable.
library;

/// مستوى خصوصية أي عنصر قابل للمشاركة.
enum PrivacyLevel { private, lessonOnly, public, draft }

/// فئات الإنجازات — الفئات الحساسة تكون خاصة افتراضيًا ولا تُشارك إلا باختيار صريح.
enum WinCategory {
  study,
  habit,
  slowLiving,
  meaning,
  worship,
  charity,
  privateFamily,
  health,
  financial,
  other;

  /// الفئات التي يجب أن تبقى خاصة افتراضيًا.
  bool get sensitiveByDefault => switch (this) {
        WinCategory.worship ||
        WinCategory.charity ||
        WinCategory.privateFamily ||
        WinCategory.health ||
        WinCategory.financial =>
          true,
        _ => false,
      };
}

/// شخصية الرفيق.
enum CompanionPersona { gentle, practical, balancedFaith }

/// حالة جلسة التركيز.
enum FocusStatus { planned, running, paused, completed, endedEarly }

/// صيغ المحتوى في صانع المحتوى الهادئ.
enum ContentFormat { story, caption, carousel, reelScript, weeklyHarvest }

/// حالة المسودة.
enum DraftStatus { draft, keptPrivate, shared, notNow }

/// فئات التنبيهات.
enum NotificationCategory {
  morningGrounding,
  studyStart,
  returnFromScrolling,
  eveningHarvest,
  weeklyReflection,
  compassionAfterMiss,
}

/// أنواع الفتور في «بروتوكول الفتور».
enum FatigueKind {
  exhausted,
  lostMotivation,
  backToScrolling,
  feelingBehind,
  planTooBig,
  unknown,
}

String _e(Enum v) => v.name;
T _d<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((v) => v.name == name, orElse: () => fallback);

class UserSettings {
  const UserSettings({
    this.id = 1,
    this.locale = 'ar',
    this.theme = 'system',
    this.companionName = 'رفيق',
    this.companionPersona = CompanionPersona.gentle,
    this.notificationsPerDay = 3,
    this.quietHoursStart = 22,
    this.quietHoursEnd = 8,
    this.onboardingDone = false,
    this.fatigueModeUntil,
    this.goals = const <String>[],
    this.createdAt,
  });

  final int id;
  final String locale;
  final String theme;
  final String companionName;
  final CompanionPersona companionPersona;
  final int notificationsPerDay;
  final int quietHoursStart;
  final int quietHoursEnd;
  final bool onboardingDone;

  /// عند تفعيل «وضع الفتور» يظل التطبيق في وضع الرحمة حتى هذا التاريخ.
  final DateTime? fatigueModeUntil;
  final List<String> goals;
  final DateTime? createdAt;

  bool get fatigueModeActive =>
      fatigueModeUntil != null && DateTime.now().isBefore(fatigueModeUntil!);

  UserSettings copyWith({
    String? locale,
    String? theme,
    String? companionName,
    CompanionPersona? companionPersona,
    int? notificationsPerDay,
    int? quietHoursStart,
    int? quietHoursEnd,
    bool? onboardingDone,
    DateTime? fatigueModeUntil,
    bool clearFatigueMode = false,
    List<String>? goals,
  }) =>
      UserSettings(
        id: id,
        locale: locale ?? this.locale,
        theme: theme ?? this.theme,
        companionName: companionName ?? this.companionName,
        companionPersona: companionPersona ?? this.companionPersona,
        notificationsPerDay: notificationsPerDay ?? this.notificationsPerDay,
        quietHoursStart: quietHoursStart ?? this.quietHoursStart,
        quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        fatigueModeUntil:
            clearFatigueMode ? null : (fatigueModeUntil ?? this.fatigueModeUntil),
        goals: goals ?? this.goals,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'locale': locale,
        'theme': theme,
        'companionName': companionName,
        'companionPersona': _e(companionPersona),
        'notificationsPerDay': notificationsPerDay,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'onboardingDone': onboardingDone ? 1 : 0,
        'fatigueModeUntil': fatigueModeUntil?.toIso8601String(),
        'goals': goals.join('|'),
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory UserSettings.fromMap(Map<String, Object?> m) => UserSettings(
        id: m['id'] as int? ?? 1,
        locale: m['locale'] as String? ?? 'ar',
        theme: m['theme'] as String? ?? 'system',
        companionName: m['companionName'] as String? ?? 'رفيق',
        companionPersona: _d(CompanionPersona.values, m['companionPersona'],
            CompanionPersona.gentle),
        notificationsPerDay: m['notificationsPerDay'] as int? ?? 3,
        quietHoursStart: m['quietHoursStart'] as int? ?? 22,
        quietHoursEnd: m['quietHoursEnd'] as int? ?? 8,
        onboardingDone: (m['onboardingDone'] as int? ?? 0) == 1,
        fatigueModeUntil: m['fatigueModeUntil'] == null
            ? null
            : DateTime.tryParse(m['fatigueModeUntil'] as String),
        goals: (m['goals'] as String? ?? '')
            .split('|')
            .where((s) => s.isNotEmpty)
            .toList(),
        createdAt: m['createdAt'] == null
            ? null
            : DateTime.tryParse(m['createdAt'] as String),
      );
}

class DailyCheckIn {
  const DailyCheckIn({
    this.id,
    required this.date,
    this.mood = 3,
    this.energy = 3,
    this.note = '',
    this.createdAt,
  });

  final int? id;
  final String date; // yyyy-MM-dd
  final int mood;
  final int energy;
  final String note;
  final DateTime? createdAt;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'mood': mood,
        'energy': energy,
        'note': note,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory DailyCheckIn.fromMap(Map<String, Object?> m) => DailyCheckIn(
        id: m['id'] as int?,
        date: m['date'] as String,
        mood: m['mood'] as int? ?? 3,
        energy: m['energy'] as int? ?? 3,
        note: m['note'] as String? ?? '',
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
      );
}

class SmallWin {
  const SmallWin({
    this.id,
    required this.date,
    required this.title,
    this.details = '',
    this.category = WinCategory.other,
    this.privacyLevel = PrivacyLevel.private,
    this.imagePath,
    this.createdAt,
  });

  final int? id;
  final String date;
  final String title;
  final String details;
  final WinCategory category;
  final PrivacyLevel privacyLevel;
  final String? imagePath;
  final DateTime? createdAt;

  /// إنشاء إنجاز بالخصوصية الافتراضية الصحيحة حسب الفئة:
  /// الفئات الحساسة تكون خاصة دائمًا حتى يغيّر المستخدم ذلك صراحة.
  factory SmallWin.create({
    required String date,
    required String title,
    String details = '',
    WinCategory category = WinCategory.other,
    PrivacyLevel? privacyLevel,
    String? imagePath,
  }) {
    final level = category.sensitiveByDefault
        ? PrivacyLevel.private
        : (privacyLevel ?? PrivacyLevel.private);
    return SmallWin(
      date: date,
      title: title,
      details: details,
      category: category,
      privacyLevel: level,
      imagePath: imagePath,
    );
  }

  SmallWin copyWith({PrivacyLevel? privacyLevel, String? details}) => SmallWin(
        id: id,
        date: date,
        title: title,
        details: details ?? this.details,
        category: category,
        privacyLevel: privacyLevel ?? this.privacyLevel,
        imagePath: imagePath,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'title': title,
        'details': details,
        'category': _e(category),
        'privacyLevel': _e(privacyLevel),
        'imagePath': imagePath,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory SmallWin.fromMap(Map<String, Object?> m) => SmallWin(
        id: m['id'] as int?,
        date: m['date'] as String,
        title: m['title'] as String,
        details: m['details'] as String? ?? '',
        category: _d(WinCategory.values, m['category'], WinCategory.other),
        privacyLevel:
            _d(PrivacyLevel.values, m['privacyLevel'], PrivacyLevel.private),
        imagePath: m['imagePath'] as String?,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
      );
}

class FocusSession {
  const FocusSession({
    this.id,
    required this.subject,
    required this.task,
    required this.tinyStep,
    required this.plannedMinutes,
    this.actualMinutes = 0,
    this.energyBefore = 3,
    this.status = FocusStatus.planned,
    this.retrievalAnswer = '',
    this.unclearPoint = '',
    this.examQuestion = '',
    this.nextStep = '',
    this.notesImagePath,
    this.startedAt,
    this.endedAt,
  });

  final int? id;
  final String subject;
  final String task;
  final String tinyStep;
  final int plannedMinutes;
  final int actualMinutes;
  final int energyBefore;
  final FocusStatus status;
  final String retrievalAnswer;
  final String unclearPoint;
  final String examQuestion;
  final String nextStep;

  /// صورة اختيارية لما كتبته بخط يدك في الجلسة.
  final String? notesImagePath;
  final DateTime? startedAt;
  final DateTime? endedAt;

  /// جملة «إذا – فسوف» (Implementation Intention).
  String implementationIntention(String timeOrSituation) =>
      'إذا $timeOrSituation، فسوف $tinyStep.';

  FocusSession copyWith({
    int? actualMinutes,
    FocusStatus? status,
    String? retrievalAnswer,
    String? unclearPoint,
    String? examQuestion,
    String? nextStep,
    String? notesImagePath,
    DateTime? startedAt,
    DateTime? endedAt,
  }) =>
      FocusSession(
        id: id,
        subject: subject,
        task: task,
        tinyStep: tinyStep,
        plannedMinutes: plannedMinutes,
        actualMinutes: actualMinutes ?? this.actualMinutes,
        energyBefore: energyBefore,
        status: status ?? this.status,
        retrievalAnswer: retrievalAnswer ?? this.retrievalAnswer,
        unclearPoint: unclearPoint ?? this.unclearPoint,
        examQuestion: examQuestion ?? this.examQuestion,
        nextStep: nextStep ?? this.nextStep,
        notesImagePath: notesImagePath ?? this.notesImagePath,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'subject': subject,
        'task': task,
        'tinyStep': tinyStep,
        'plannedMinutes': plannedMinutes,
        'actualMinutes': actualMinutes,
        'energyBefore': energyBefore,
        'status': _e(status),
        'retrievalAnswer': retrievalAnswer,
        'unclearPoint': unclearPoint,
        'examQuestion': examQuestion,
        'nextStep': nextStep,
        'notesImagePath': notesImagePath,
        'startedAt': startedAt?.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
      };

  factory FocusSession.fromMap(Map<String, Object?> m) => FocusSession(
        id: m['id'] as int?,
        subject: m['subject'] as String,
        task: m['task'] as String? ?? '',
        tinyStep: m['tinyStep'] as String? ?? '',
        plannedMinutes: m['plannedMinutes'] as int? ?? 10,
        actualMinutes: m['actualMinutes'] as int? ?? 0,
        energyBefore: m['energyBefore'] as int? ?? 3,
        status: _d(FocusStatus.values, m['status'], FocusStatus.planned),
        retrievalAnswer: m['retrievalAnswer'] as String? ?? '',
        unclearPoint: m['unclearPoint'] as String? ?? '',
        examQuestion: m['examQuestion'] as String? ?? '',
        nextStep: m['nextStep'] as String? ?? '',
        notesImagePath: m['notesImagePath'] as String?,
        startedAt: DateTime.tryParse(m['startedAt'] as String? ?? ''),
        endedAt: DateTime.tryParse(m['endedAt'] as String? ?? ''),
      );
}

class ResetSession {
  const ResetSession({
    this.id,
    this.trigger = 'manual',
    this.selectedNeed = '',
    this.breathingDurationSeconds = 90,
    this.tinyAction = '',
    this.completed = false,
    this.createdAt,
  });

  final int? id;
  final String trigger;
  final String selectedNeed;
  final int breathingDurationSeconds;
  final String tinyAction;
  final bool completed;
  final DateTime? createdAt;

  ResetSession copyWith({
    String? selectedNeed,
    int? breathingDurationSeconds,
    String? tinyAction,
    bool? completed,
  }) =>
      ResetSession(
        id: id,
        trigger: trigger,
        selectedNeed: selectedNeed ?? this.selectedNeed,
        breathingDurationSeconds:
            breathingDurationSeconds ?? this.breathingDurationSeconds,
        tinyAction: tinyAction ?? this.tinyAction,
        completed: completed ?? this.completed,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'trigger': trigger,
        'selectedNeed': selectedNeed,
        'breathingDuration': breathingDurationSeconds,
        'tinyAction': tinyAction,
        'completed': completed ? 1 : 0,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory ResetSession.fromMap(Map<String, Object?> m) => ResetSession(
        id: m['id'] as int?,
        trigger: m['trigger'] as String? ?? 'manual',
        selectedNeed: m['selectedNeed'] as String? ?? '',
        breathingDurationSeconds: m['breathingDuration'] as int? ?? 90,
        tinyAction: m['tinyAction'] as String? ?? '',
        completed: (m['completed'] as int? ?? 0) == 1,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
      );
}

class Reflection {
  const Reflection({
    this.id,
    required this.date,
    this.learned = '',
    this.gratitude = '',
    this.releaseThought = '',
    this.moodAfter = 3,
    this.createdAt,
  });

  final int? id;
  final String date;
  final String learned;
  final String gratitude;
  final String releaseThought;
  final int moodAfter;
  final DateTime? createdAt;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'date': date,
        'learned': learned,
        'gratitude': gratitude,
        'releaseThought': releaseThought,
        'moodAfter': moodAfter,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory Reflection.fromMap(Map<String, Object?> m) => Reflection(
        id: m['id'] as int?,
        date: m['date'] as String,
        learned: m['learned'] as String? ?? '',
        gratitude: m['gratitude'] as String? ?? '',
        releaseThought: m['releaseThought'] as String? ?? '',
        moodAfter: m['moodAfter'] as int? ?? 3,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
      );
}

class ContentDraft {
  const ContentDraft({
    this.id,
    this.sourceWinIds = const <int>[],
    required this.format,
    required this.title,
    required this.body,
    this.privacyLevel = PrivacyLevel.draft,
    this.status = DraftStatus.draft,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final List<int> sourceWinIds;
  final ContentFormat format;
  final String title;
  final String body;
  final PrivacyLevel privacyLevel;
  final DraftStatus status;
  final String? imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContentDraft copyWith({
    String? title,
    String? body,
    PrivacyLevel? privacyLevel,
    DraftStatus? status,
    String? imagePath,
  }) =>
      ContentDraft(
        id: id,
        sourceWinIds: sourceWinIds,
        format: format,
        title: title ?? this.title,
        body: body ?? this.body,
        privacyLevel: privacyLevel ?? this.privacyLevel,
        status: status ?? this.status,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'sourceWinIds': sourceWinIds.join(','),
        'format': _e(format),
        'title': title,
        'body': body,
        'privacyLevel': _e(privacyLevel),
        'status': _e(status),
        'imagePath': imagePath,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
        'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
      };

  factory ContentDraft.fromMap(Map<String, Object?> m) => ContentDraft(
        id: m['id'] as int?,
        sourceWinIds: (m['sourceWinIds'] as String? ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList(),
        format: _d(ContentFormat.values, m['format'], ContentFormat.caption),
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        privacyLevel:
            _d(PrivacyLevel.values, m['privacyLevel'], PrivacyLevel.draft),
        status: _d(DraftStatus.values, m['status'], DraftStatus.draft),
        imagePath: m['imagePath'] as String?,
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? ''),
      );
}

class IntentSession {
  const IntentSession({
    this.id,
    this.targetApp = 'instagram',
    required this.intention,
    required this.plannedMinutes,
    this.startedAt,
    this.returnedAt,
    this.extraMinutes = 0,
    this.outcome = '',
  });

  final int? id;
  final String targetApp;
  final String intention;
  final int plannedMinutes;
  final DateTime? startedAt;
  final DateTime? returnedAt;
  final int extraMinutes;
  final String outcome;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'targetApp': targetApp,
        'intention': intention,
        'plannedMinutes': plannedMinutes,
        'startedAt': (startedAt ?? DateTime.now()).toIso8601String(),
        'returnedAt': returnedAt?.toIso8601String(),
        'extraMinutes': extraMinutes,
        'outcome': outcome,
      };

  factory IntentSession.fromMap(Map<String, Object?> m) => IntentSession(
        id: m['id'] as int?,
        targetApp: m['targetApp'] as String? ?? 'instagram',
        intention: m['intention'] as String? ?? '',
        plannedMinutes: m['plannedMinutes'] as int? ?? 10,
        startedAt: DateTime.tryParse(m['startedAt'] as String? ?? ''),
        returnedAt: DateTime.tryParse(m['returnedAt'] as String? ?? ''),
        extraMinutes: m['extraMinutes'] as int? ?? 0,
        outcome: m['outcome'] as String? ?? '',
      );
}

class NotificationRule {
  const NotificationRule({
    this.id,
    required this.category,
    this.enabled = true,
    this.preferredHour = 9,
    this.preferredMinute = 0,
    this.ignoredCount = 0,
    this.lastTriggeredAt,
    this.lastEngagedAt,
  });

  final int? id;
  final NotificationCategory category;
  final bool enabled;
  final int preferredHour;
  final int preferredMinute;
  final int ignoredCount;
  final DateTime? lastTriggeredAt;

  /// آخر مرة تفاعل فيها المستخدم مع تنبيه من هذه الفئة (ضغط عليه).
  final DateTime? lastEngagedAt;

  /// بعد ثلاث تجاهلات متتالية تقل وتيرة هذه الفئة (يومًا بعد يوم بدل يوميًا).
  bool get reducedFrequency => ignoredCount >= 3;

  NotificationRule copyWith({
    bool? enabled,
    int? preferredHour,
    int? preferredMinute,
    int? ignoredCount,
    DateTime? lastTriggeredAt,
    DateTime? lastEngagedAt,
  }) =>
      NotificationRule(
        id: id,
        category: category,
        enabled: enabled ?? this.enabled,
        preferredHour: preferredHour ?? this.preferredHour,
        preferredMinute: preferredMinute ?? this.preferredMinute,
        ignoredCount: ignoredCount ?? this.ignoredCount,
        lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
        lastEngagedAt: lastEngagedAt ?? this.lastEngagedAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'category': _e(category),
        'enabled': enabled ? 1 : 0,
        'preferredHour': preferredHour,
        'preferredMinute': preferredMinute,
        'ignoredCount': ignoredCount,
        'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
        'lastEngagedAt': lastEngagedAt?.toIso8601String(),
      };

  factory NotificationRule.fromMap(Map<String, Object?> m) => NotificationRule(
        id: m['id'] as int?,
        category: _d(NotificationCategory.values, m['category'],
            NotificationCategory.morningGrounding),
        enabled: (m['enabled'] as int? ?? 1) == 1,
        preferredHour: m['preferredHour'] as int? ?? 9,
        preferredMinute: m['preferredMinute'] as int? ?? 0,
        ignoredCount: m['ignoredCount'] as int? ?? 0,
        lastTriggeredAt: DateTime.tryParse(m['lastTriggeredAt'] as String? ?? ''),
        lastEngagedAt: DateTime.tryParse(m['lastEngagedAt'] as String? ?? ''),
      );
}
