enum WalletKind { cash, bank, ewallet }

extension WalletKindX on WalletKind {
  String get storageKey => switch (this) {
    WalletKind.cash => "cash",
    WalletKind.bank => "bank",
    WalletKind.ewallet => "ewallet",
  };

  static WalletKind parse(String value) {
    return switch (value) {
      "bank" => WalletKind.bank,
      "ewallet" => WalletKind.ewallet,
      _ => WalletKind.cash,
    };
  }
}

class Wallet {
  const Wallet({
    required this.id,
    required this.homeId,
    required this.kind,
    required this.name,
    required this.balanceVnd,
    this.bankName,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String homeId;
  final WalletKind kind;
  final String name;
  final double balanceVnd;
  final String? bankName;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      kind: WalletKindX.parse(json["kind"] as String? ?? "cash"),
      name: json["name"] as String,
      balanceVnd: (json["balance_vnd"] as num?)?.toDouble() ?? 0,
      bankName: json["bank_name"] as String?,
      note: json["note"] as String?,
      createdAt:
          json["created_at"] is String
              ? DateTime.tryParse(json["created_at"] as String)
              : null,
      updatedAt:
          json["updated_at"] is String
              ? DateTime.tryParse(json["updated_at"] as String)
              : null,
    );
  }
}

enum WalletTxnKind { adjust, expense, transferOut, transferIn }

extension WalletTxnKindX on WalletTxnKind {
  String get storageKey => switch (this) {
    WalletTxnKind.adjust => "adjust",
    WalletTxnKind.expense => "expense",
    WalletTxnKind.transferOut => "transfer_out",
    WalletTxnKind.transferIn => "transfer_in",
  };

  static WalletTxnKind parse(String value) {
    return switch (value) {
      "expense" => WalletTxnKind.expense,
      "transfer_out" => WalletTxnKind.transferOut,
      "transfer_in" => WalletTxnKind.transferIn,
      _ => WalletTxnKind.adjust,
    };
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.homeId,
    required this.walletId,
    required this.kind,
    required this.signedAmount,
    required this.createdAt,
    this.note,
    this.expenseId,
    this.transferGroupId,
  });

  final String id;
  final String homeId;
  final String walletId;
  final WalletTxnKind kind;
  final double signedAmount;
  final DateTime createdAt;
  final String? note;
  final String? expenseId;
  final String? transferGroupId;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      walletId: json["wallet_id"] as String,
      kind: WalletTxnKindX.parse(json["kind"] as String? ?? "adjust"),
      signedAmount: (json["signed_amount"] as num).toDouble(),
      createdAt: DateTime.parse(json["created_at"] as String),
      note: json["note"] as String?,
      expenseId: json["expense_id"] as String?,
      transferGroupId: json["transfer_group_id"] as String?,
    );
  }
}
