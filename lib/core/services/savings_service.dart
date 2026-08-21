import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/savings.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SavingsService {
  SavingsService(this._client);

  final SupabaseClient _client;

  Future<List<Savings>> list(String homeId) async {
    AppLog.d("list savings for $homeId");
    final rows = await _client
        .from("savings")
        .select()
        .eq("home_id", homeId)
        .order("created_at", ascending: false);
    return (rows as List)
        .map((row) => Savings.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Savings> upsert({
    required String homeId,
    required String type,
    required String name,
    String? bankName,
    double? interestRate,
    int? termMonths,
    DateTime? maturityDate,
    double? targetAmount,
    double currentAmount = 0,
    String? note,
    String? editingId,
  }) async {
    final payload = <String, dynamic>{
      "home_id": homeId,
      "type": type,
      "name": name,
      "bank_name": bankName,
      "interest_rate": interestRate,
      "term_months": termMonths,
      "maturity_date": maturityDate?.toIso8601String().split("T").first,
      "target_amount": targetAmount,
      "current_amount": currentAmount,
      "note": note,
    };
    if (editingId != null) payload["id"] = editingId;
    final row = await _client.from("savings").upsert(payload).select().single();
    return Savings.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from("savings").delete().eq("id", id);
  }

  Future<List<SavingsContribution>> listContributions(String savingsId) async {
    final rows = await _client
        .from("savings_contributions")
        .select()
        .eq("savings_id", savingsId)
        .order("contributed_date", ascending: false);
    return (rows as List)
        .map(
          (row) => SavingsContribution.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<SavingsContribution> addContribution({
    required String savingsId,
    required double amount,
    required DateTime contributedDate,
    String? note,
  }) async {
    final row = await _client.rpc(
      "add_savings_contribution",
      params: {
        "p_savings_id": savingsId,
        "p_amount": amount,
        "p_contributed_date":
            contributedDate.toIso8601String().split("T").first,
        "p_note": note,
      },
    );
    if (row is Map) {
      return SavingsContribution.fromJson(Map<String, dynamic>.from(row));
    }
    final list = await listContributions(savingsId);
    return list.first;
  }
}
