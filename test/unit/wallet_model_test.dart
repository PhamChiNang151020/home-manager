import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/models/wallet.dart";

void main() {
  test("Wallet.fromJson parses kinds and balance", () {
    final wallet = Wallet.fromJson({
      "id": "w1",
      "home_id": "h1",
      "kind": "ewallet",
      "name": "MoMo",
      "balance_vnd": 150000,
      "bank_name": null,
    });

    expect(wallet.kind, WalletKind.ewallet);
    expect(wallet.balanceVnd, 150000);
    expect(wallet.name, "MoMo");
  });

  test("WalletTransaction.fromJson parses signed amount", () {
    final txn = WalletTransaction.fromJson({
      "id": "t1",
      "home_id": "h1",
      "wallet_id": "w1",
      "kind": "expense",
      "signed_amount": -20000,
      "created_at": "2026-08-26T10:00:00.000Z",
      "expense_id": "e1",
    });

    expect(txn.kind, WalletTxnKind.expense);
    expect(txn.signedAmount, -20000);
    expect(txn.expenseId, "e1");
  });
}
