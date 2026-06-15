enum NeedType { necessary, niceToHave, impulse, unset }

enum RegretLevel { happy, neutral, regret, unset }

enum WaitingStatus { pending, bought, saved }

String needTypeToStr(NeedType t) => t.name;
NeedType needTypeFromStr(String? s) =>
    NeedType.values.firstWhere((e) => e.name == s, orElse: () => NeedType.unset);

String regretToStr(RegretLevel r) => r.name;
RegretLevel regretFromStr(String? s) =>
    RegretLevel.values.firstWhere((e) => e.name == s, orElse: () => RegretLevel.unset);

String waitingToStr(WaitingStatus s) => s.name;
WaitingStatus waitingFromStr(String? s) =>
    WaitingStatus.values.firstWhere((e) => e.name == s, orElse: () => WaitingStatus.pending);

class Expense {
  final int? id;
  final DateTime date;
  final double amount;
  final String currency;
  final String? merchant;
  final String? category;
  final String? paymentMethod;
  final String? note;
  final NeedType needType;
  final RegretLevel regretLevel;
  final DateTime createdAt;

  const Expense({
    this.id,
    required this.date,
    required this.amount,
    this.currency = 'EGP',
    this.merchant,
    this.category,
    this.paymentMethod,
    this.note,
    this.needType = NeedType.unset,
    this.regretLevel = RegretLevel.unset,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'currency': currency,
        'merchant': merchant,
        'category': category,
        'paymentMethod': paymentMethod,
        'note': note,
        'needType': needTypeToStr(needType),
        'regretLevel': regretToStr(regretLevel),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, Object?> m) => Expense(
        id: m['id'] as int?,
        date: DateTime.parse(m['date'] as String),
        amount: (m['amount'] as num).toDouble(),
        currency: (m['currency'] as String?) ?? 'EGP',
        merchant: m['merchant'] as String?,
        category: m['category'] as String?,
        paymentMethod: m['paymentMethod'] as String?,
        note: m['note'] as String?,
        needType: needTypeFromStr(m['needType'] as String?),
        regretLevel: regretFromStr(m['regretLevel'] as String?),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  Expense copyWith({
    double? amount,
    String? merchant,
    String? category,
    String? paymentMethod,
    String? note,
    NeedType? needType,
    RegretLevel? regretLevel,
  }) =>
      Expense(
        id: id,
        date: date,
        amount: amount ?? this.amount,
        currency: currency,
        merchant: merchant ?? this.merchant,
        category: category ?? this.category,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        note: note ?? this.note,
        needType: needType ?? this.needType,
        regretLevel: regretLevel ?? this.regretLevel,
        createdAt: createdAt,
      );
}

class Saving {
  final int? id;
  final DateTime date;
  final double amount;
  final String? reason;
  final String? category;
  final DateTime createdAt;

  const Saving({
    this.id,
    required this.date,
    required this.amount,
    this.reason,
    this.category,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'reason': reason,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Saving.fromMap(Map<String, Object?> m) => Saving(
        id: m['id'] as int?,
        date: DateTime.parse(m['date'] as String),
        amount: (m['amount'] as num).toDouble(),
        reason: m['reason'] as String?,
        category: m['category'] as String?,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}

class WaitingItem {
  final int? id;
  final DateTime createdAt;
  final double amount;
  final String description;
  final WaitingStatus status;
  final DateTime? decidedAt;

  const WaitingItem({
    this.id,
    required this.createdAt,
    required this.amount,
    required this.description,
    this.status = WaitingStatus.pending,
    this.decidedAt,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'createdAt': createdAt.toIso8601String(),
        'amount': amount,
        'description': description,
        'status': waitingToStr(status),
        'decidedAt': decidedAt?.toIso8601String(),
      };

  factory WaitingItem.fromMap(Map<String, Object?> m) => WaitingItem(
        id: m['id'] as int?,
        createdAt: DateTime.parse(m['createdAt'] as String),
        amount: (m['amount'] as num).toDouble(),
        description: m['description'] as String,
        status: waitingFromStr(m['status'] as String?),
        decidedAt: (m['decidedAt'] as String?) != null
            ? DateTime.parse(m['decidedAt'] as String)
            : null,
      );

  DateTime get readyAt => createdAt.add(const Duration(hours: 24));
  bool get isReady => DateTime.now().isAfter(readyAt);
}

class Rule {
  final int? id;
  final String keyword;
  final String category;

  const Rule({this.id, required this.keyword, required this.category});

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'keyword': keyword,
        'category': category,
      };

  factory Rule.fromMap(Map<String, Object?> m) => Rule(
        id: m['id'] as int?,
        keyword: m['keyword'] as String,
        category: m['category'] as String,
      );
}
