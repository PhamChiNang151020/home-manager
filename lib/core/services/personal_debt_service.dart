import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/personal_debt.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class PersonalDebtService {
  PersonalDebtService(this._client);

  final SupabaseClient _client;

  Future<List<PersonalDebt>> list(String homeId) async {
    AppLog.d("list personal debts for $homeId");
    final rows = await _client
        .from("personal_debts")
        .select()
        .eq("home_id", homeId)
        .order("created_at", ascending: false);
    return (rows as List)
        .map(
          (row) => PersonalDebt.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<PersonalDebt> create({
    required String homeId,
    required String direction,
    required String counterpartyName,
    required double principalAmount,
    DateTime? dueDate,
    double? interestRate,
    String? note,
    required String createdBy,
  }) async {
    final row =
        await _client
            .from("personal_debts")
            .insert({
              "home_id": homeId,
              "direction": direction,
              "counterparty_name": counterpartyName,
              "principal_amount": principalAmount,
              "remaining_amount": principalAmount,
              "due_date": dueDate?.toIso8601String().split("T").first,
              "interest_rate": interestRate,
              "note": note,
              "created_by": createdBy,
            })
            .select()
            .single();
    return PersonalDebt.fromJson(row);
  }

  Future<PersonalDebt> updateDebt({
    required String id,
    required String direction,
    required String counterpartyName,
    DateTime? dueDate,
    double? interestRate,
    String? note,
  }) async {
    final row =
        await _client
            .from("personal_debts")
            .update({
              "direction": direction,
              "counterparty_name": counterpartyName,
              "due_date": dueDate?.toIso8601String().split("T").first,
              "interest_rate": interestRate,
              "note": note,
            })
            .eq("id", id)
            .select()
            .single();
    return PersonalDebt.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from("personal_debts").delete().eq("id", id);
  }

  Future<List<PersonalDebtPayment>> listPayments(String debtId) async {
    final rows = await _client
        .from("personal_debt_payments")
        .select()
        .eq("debt_id", debtId)
        .order("paid_date", ascending: false);
    return (rows as List)
        .map(
          (row) => PersonalDebtPayment.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<PersonalDebtPayment> addPayment({
    required String debtId,
    required double amount,
    required DateTime paidDate,
    String? note,
  }) async {
    final row = await _client.rpc(
      "add_personal_debt_payment",
      params: {
        "p_debt_id": debtId,
        "p_amount": amount,
        "p_paid_date": paidDate.toIso8601String().split("T").first,
        "p_note": note,
      },
    );
    // RPC returns payment row or we re-fetch; support both shapes.
    if (row is Map) {
      return PersonalDebtPayment.fromJson(Map<String, dynamic>.from(row));
    }
    final payments = await listPayments(debtId);
    return payments.first;
  }
}
