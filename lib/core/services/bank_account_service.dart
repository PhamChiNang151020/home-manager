import "package:home_manager/core/domain/electricity_period_edit.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class BankAccountService {
  BankAccountService(this._client);

  final SupabaseClient _client;

  static String monthKey(DateTime month) =>
      ElectricityPeriodEdit.monthKey(month);

  Future<List<BankAccount>> listAccounts(String homeId) async {
    AppLog.d("list bank accounts for $homeId");
    final rows = await _client
        .from("bank_accounts")
        .select()
        .eq("home_id", homeId)
        .order("created_at", ascending: false);
    return (rows as List)
        .map(
          (row) => BankAccount.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<BankAccount> upsertAccount({
    required String homeId,
    required String bankName,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
    String? note,
    String? editingId,
  }) async {
    final payload = <String, dynamic>{
      "home_id": homeId,
      "bank_name": bankName,
      "credit_limit": creditLimit,
      "statement_day": statementDay,
      "due_day": dueDay,
      "note": note,
    };
    if (editingId != null) {
      payload["id"] = editingId;
    }
    final row =
        await _client.from("bank_accounts").upsert(payload).select().single();
    return BankAccount.fromJson(row);
  }

  Future<void> deleteAccount(String id) async {
    await _client.from("bank_accounts").delete().eq("id", id);
  }

  Future<List<BankAccountPeriod>> listPeriods(String bankAccountId) async {
    final rows = await _client
        .from("bank_account_periods")
        .select()
        .eq("bank_account_id", bankAccountId)
        .order("period_month", ascending: false);
    return (rows as List)
        .map(
          (row) =>
              BankAccountPeriod.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<BankAccountPeriod?> latestPeriod(String bankAccountId) async {
    final rows = await _client
        .from("bank_account_periods")
        .select()
        .eq("bank_account_id", bankAccountId)
        .order("period_month", ascending: false)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return BankAccountPeriod.fromJson(
      Map<String, dynamic>.from(list.first as Map),
    );
  }

  Future<void> setPaid(String id, {required bool isPaid}) async {
    await _client
        .from("bank_account_periods")
        .update({"is_paid": isPaid})
        .eq("id", id);
  }

  Future<BankAccountPeriod> upsertPeriod({
    required String bankAccountId,
    required DateTime periodMonth,
    required double balanceUsed,
    required double paymentDue,
    double paymentMade = 0,
    bool? isPaid,
    String? note,
    String? editingId,
    DateTime? editingOriginalMonth,
    DateTime? recordedAt,
  }) async {
    final payload = <String, dynamic>{
      "bank_account_id": bankAccountId,
      "period_month": monthKey(periodMonth),
      "balance_used": balanceUsed,
      "payment_due": paymentDue,
      "payment_made": paymentMade,
      "note": note,
      "recorded_at": (recordedAt ?? DateTime.now()).toUtc().toIso8601String(),
    };
    if (isPaid != null) payload["is_paid"] = isPaid;

    final row =
        await _client
            .from("bank_account_periods")
            .upsert(payload, onConflict: "bank_account_id,period_month")
            .select()
            .single();

    final monthChanged = ElectricityPeriodEdit.shouldDeleteOriginalPeriod(
      editingId: editingId,
      editingOriginalMonth: editingOriginalMonth,
      periodMonth: periodMonth,
    );
    if (monthChanged) {
      await deletePeriod(editingId!);
    }

    return BankAccountPeriod.fromJson(row);
  }

  Future<void> deletePeriod(String id) async {
    await _client.from("bank_account_periods").delete().eq("id", id);
  }
}
