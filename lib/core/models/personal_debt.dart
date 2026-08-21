class PersonalDebt {
  const PersonalDebt({
    required this.id,
    required this.homeId,
    required this.direction,
    required this.counterpartyName,
    required this.principalAmount,
    required this.remainingAmount,
    this.dueDate,
    this.interestRate,
    required this.isSettled,
    this.note,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String homeId;

  /// `i_owe` or `owed_to_me`
  final String direction;
  final String counterpartyName;
  final double principalAmount;
  final double remainingAmount;
  final DateTime? dueDate;
  final double? interestRate;
  final bool isSettled;
  final String? note;
  final String createdBy;
  final DateTime createdAt;

  bool get iOwe => direction == "i_owe";

  factory PersonalDebt.fromJson(Map<String, dynamic> json) {
    return PersonalDebt(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      direction: json["direction"] as String,
      counterpartyName: json["counterparty_name"] as String,
      principalAmount: (json["principal_amount"] as num).toDouble(),
      remainingAmount: (json["remaining_amount"] as num).toDouble(),
      dueDate:
          json["due_date"] == null
              ? null
              : DateTime.parse(json["due_date"] as String),
      interestRate: (json["interest_rate"] as num?)?.toDouble(),
      isSettled: json["is_settled"] as bool? ?? false,
      note: json["note"] as String?,
      createdBy: json["created_by"] as String,
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }
}

class PersonalDebtPayment {
  const PersonalDebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paidDate,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String debtId;
  final double amount;
  final DateTime paidDate;
  final String? note;
  final DateTime createdAt;

  factory PersonalDebtPayment.fromJson(Map<String, dynamic> json) {
    return PersonalDebtPayment(
      id: json["id"] as String,
      debtId: json["debt_id"] as String,
      amount: (json["amount"] as num).toDouble(),
      paidDate: DateTime.parse(json["paid_date"] as String),
      note: json["note"] as String?,
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }
}
