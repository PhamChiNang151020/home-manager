class Savings {
  const Savings({
    required this.id,
    required this.homeId,
    required this.type,
    required this.name,
    this.bankName,
    this.interestRate,
    this.termMonths,
    this.maturityDate,
    this.targetAmount,
    required this.currentAmount,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String homeId;

  /// `term_deposit` or `goal`
  final String type;
  final String name;
  final String? bankName;
  final double? interestRate;
  final int? termMonths;
  final DateTime? maturityDate;
  final double? targetAmount;
  final double currentAmount;
  final String? note;
  final DateTime createdAt;

  bool get isGoal => type == "goal";
  bool get isTermDeposit => type == "term_deposit";

  double get progress {
    final target = targetAmount;
    if (target == null || target <= 0) return 0;
    return (currentAmount / target).clamp(0.0, 1.0);
  }

  factory Savings.fromJson(Map<String, dynamic> json) {
    return Savings(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      type: json["type"] as String,
      name: json["name"] as String,
      bankName: json["bank_name"] as String?,
      interestRate: (json["interest_rate"] as num?)?.toDouble(),
      termMonths: json["term_months"] as int?,
      maturityDate:
          json["maturity_date"] == null
              ? null
              : DateTime.parse(json["maturity_date"] as String),
      targetAmount: (json["target_amount"] as num?)?.toDouble(),
      currentAmount: (json["current_amount"] as num?)?.toDouble() ?? 0,
      note: json["note"] as String?,
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }
}

class SavingsContribution {
  const SavingsContribution({
    required this.id,
    required this.savingsId,
    required this.amount,
    required this.contributedDate,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String savingsId;
  final double amount;
  final DateTime contributedDate;
  final String? note;
  final DateTime createdAt;

  factory SavingsContribution.fromJson(Map<String, dynamic> json) {
    return SavingsContribution(
      id: json["id"] as String,
      savingsId: json["savings_id"] as String,
      amount: (json["amount"] as num).toDouble(),
      contributedDate: DateTime.parse(json["contributed_date"] as String),
      note: json["note"] as String?,
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }
}
