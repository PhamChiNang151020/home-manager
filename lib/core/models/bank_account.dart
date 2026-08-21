class BankAccount {
  const BankAccount({
    required this.id,
    required this.homeId,
    required this.bankName,
    required this.creditLimit,
    required this.statementDay,
    required this.dueDay,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String homeId;
  final String bankName;
  final double creditLimit;
  final int statementDay;
  final int dueDay;
  final String? note;
  final DateTime createdAt;

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      bankName: json["bank_name"] as String,
      creditLimit: (json["credit_limit"] as num).toDouble(),
      statementDay: json["statement_day"] as int,
      dueDay: json["due_day"] as int,
      note: json["note"] as String?,
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }
}

class BankAccountPeriod {
  const BankAccountPeriod({
    required this.id,
    required this.bankAccountId,
    required this.periodMonth,
    required this.balanceUsed,
    required this.paymentDue,
    required this.paymentMade,
    required this.isPaid,
    this.note,
    required this.recordedAt,
  });

  final String id;
  final String bankAccountId;
  final DateTime periodMonth;
  final double balanceUsed;
  final double paymentDue;
  final double paymentMade;
  final bool isPaid;
  final String? note;
  final DateTime recordedAt;

  BankAccountPeriod copyWith({bool? isPaid}) {
    return BankAccountPeriod(
      id: id,
      bankAccountId: bankAccountId,
      periodMonth: periodMonth,
      balanceUsed: balanceUsed,
      paymentDue: paymentDue,
      paymentMade: paymentMade,
      isPaid: isPaid ?? this.isPaid,
      note: note,
      recordedAt: recordedAt,
    );
  }

  factory BankAccountPeriod.fromJson(Map<String, dynamic> json) {
    return BankAccountPeriod(
      id: json["id"] as String,
      bankAccountId: json["bank_account_id"] as String,
      periodMonth: DateTime.parse(json["period_month"] as String),
      balanceUsed: (json["balance_used"] as num).toDouble(),
      paymentDue: (json["payment_due"] as num).toDouble(),
      paymentMade: (json["payment_made"] as num?)?.toDouble() ?? 0,
      isPaid: json["is_paid"] as bool? ?? false,
      note: json["note"] as String?,
      recordedAt: DateTime.parse(
        json["recorded_at"] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }
}
