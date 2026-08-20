import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/income.dart";
import "package:intl/intl.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class IncomeService {
  IncomeService(this._client);

  final SupabaseClient _client;

  static String monthKey(DateTime month) =>
      DateFormat("yyyy-MM-01").format(DateTime(month.year, month.month));

  Future<List<Income>> list(String homeId, {DateTime? month}) async {
    AppLog.d("list incomes for $homeId");
    var query = _client
        .from("incomes")
        .select("*, profiles!user_id(display_name, email)")
        .eq("home_id", homeId);
    if (month != null) {
      query = query.eq("income_month", monthKey(month));
    }
    final rows = await query.order("created_at");
    return (rows as List)
        .map((row) => Income.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<Income> upsert({
    required String homeId,
    required String userId,
    required DateTime incomeMonth,
    required double amountVnd,
    String? source,
    String? note,
  }) async {
    final row =
        await _client
            .from("incomes")
            .upsert({
              "home_id": homeId,
              "user_id": userId,
              "income_month": monthKey(incomeMonth),
              "amount_vnd": amountVnd,
              "source": source,
              "note": note,
            }, onConflict: "home_id,user_id,income_month")
            .select("*, profiles!user_id(display_name, email)")
            .single();
    return Income.fromJson(row);
  }

  Future<void> delete(String id) async {
    await _client.from("incomes").delete().eq("id", id);
  }
}
