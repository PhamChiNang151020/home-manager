import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class WalletService {
  WalletService(this._client);

  final SupabaseClient _client;

  Future<List<Wallet>> list(String homeId) async {
    AppLog.d("list wallets for $homeId");
    final rows = await _client
        .from("wallets")
        .select()
        .eq("home_id", homeId)
        .order("created_at");
    return (rows as List)
        .map((row) => Wallet.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Wallet> create({
    required String homeId,
    required WalletKind kind,
    required String name,
    String? bankName,
    String? note,
    double initialBalance = 0,
  }) async {
    final uid = _client.auth.currentUser?.id;
    final row =
        await _client
            .from("wallets")
            .insert({
              "home_id": homeId,
              "kind": kind.storageKey,
              "name": name.trim(),
              "bank_name": bankName?.trim().isEmpty == true ? null : bankName,
              "note": note?.trim().isEmpty == true ? null : note,
              "balance_vnd": 0,
              "created_by": uid,
            })
            .select()
            .single();
    var wallet = Wallet.fromJson(row);
    if (initialBalance > 0) {
      wallet = await adjust(
        walletId: wallet.id,
        signedAmount: initialBalance,
        note: "Số dư ban đầu",
      );
    }
    return wallet;
  }

  Future<Wallet> updateMeta({
    required String id,
    required String name,
    required WalletKind kind,
    String? bankName,
    String? note,
  }) async {
    final row =
        await _client
            .from("wallets")
            .update({
              "name": name.trim(),
              "kind": kind.storageKey,
              "bank_name": bankName?.trim().isEmpty == true ? null : bankName,
              "note": note?.trim().isEmpty == true ? null : note,
              "updated_at": DateTime.now().toUtc().toIso8601String(),
            })
            .eq("id", id)
            .select()
            .single();
    return Wallet.fromJson(row);
  }

  Future<void> delete(String id) async {
    AppLog.i("delete wallet $id");
    await _client.from("wallets").delete().eq("id", id);
  }

  Future<Wallet> adjust({
    required String walletId,
    required double signedAmount,
    String? note,
  }) async {
    final result = await _client.rpc(
      "wallet_adjust",
      params: {
        "p_wallet_id": walletId,
        "p_signed_amount": signedAmount,
        "p_note": note,
      },
    );
    return Wallet.fromJson(Map<String, dynamic>.from(result as Map));
  }

  Future<void> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String? note,
  }) async {
    await _client.rpc(
      "wallet_transfer",
      params: {
        "p_from_wallet_id": fromWalletId,
        "p_to_wallet_id": toWalletId,
        "p_amount": amount,
        "p_note": note,
      },
    );
  }

  Future<List<WalletTransaction>> listTransactions(
    String walletId, {
    int limit = 50,
  }) async {
    final rows = await _client
        .from("wallet_transactions")
        .select()
        .eq("wallet_id", walletId)
        .order("created_at", ascending: false)
        .limit(limit);
    return (rows as List)
        .map(
          (row) =>
              WalletTransaction.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<void> applyExpense({
    required String expenseId,
    required String walletId,
    required double amount,
  }) async {
    await _client.rpc(
      "wallet_apply_expense",
      params: {
        "p_expense_id": expenseId,
        "p_wallet_id": walletId,
        "p_amount": amount,
      },
    );
  }

  Future<void> revertExpense(String expenseId) async {
    await _client.rpc(
      "wallet_revert_expense",
      params: {"p_expense_id": expenseId},
    );
  }
}
