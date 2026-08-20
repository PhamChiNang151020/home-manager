import "package:home_manager/core/domain/water_period_edit.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/water_period.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class WaterService {
  WaterService(this._client);

  final SupabaseClient _client;

  static String monthKey(DateTime month) => WaterPeriodEdit.monthKey(month);

  Future<List<WaterPeriod>> list(String homeId) async {
    AppLog.d("list water periods for $homeId");
    final rows = await _client
        .from("water_periods")
        .select()
        .eq("home_id", homeId)
        .order("period_month", ascending: false);
    return (rows as List)
        .map(
          (row) => WaterPeriod.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<WaterPeriod?> latest(String homeId) async {
    final rows = await _client
        .from("water_periods")
        .select()
        .eq("home_id", homeId)
        .order("period_month", ascending: false)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) {
      return null;
    }
    return WaterPeriod.fromJson(Map<String, dynamic>.from(list.first as Map));
  }

  Future<void> setPaid(String id, {required bool isPaid}) async {
    AppLog.d("setPaid water $id -> $isPaid");
    await _client
        .from("water_periods")
        .update({"is_paid": isPaid})
        .eq("id", id);
  }

  Future<WaterPeriod> upsert({
    required String homeId,
    required DateTime periodMonth,
    required double amountVnd,
    double? previousM3,
    double? newM3,
    double? consumptionM3,
    String? photoPath,
    String? note,
    bool? isPaid,
    String? editingId,
    DateTime? editingOriginalMonth,
    DateTime? recordedAt,
  }) async {
    final payload = <String, dynamic>{
      "home_id": homeId,
      "period_month": monthKey(periodMonth),
      "amount_vnd": amountVnd,
      "previous_m3": previousM3,
      "new_m3": newM3,
      "consumption_m3": consumptionM3,
      "photo_path": photoPath,
      "note": note,
      "recorded_at": (recordedAt ?? DateTime.now()).toUtc().toIso8601String(),
    };
    if (isPaid != null) {
      payload["is_paid"] = isPaid;
    }

    final row =
        await _client
            .from("water_periods")
            .upsert(payload, onConflict: "home_id,period_month")
            .select()
            .single();

    final monthChanged = WaterPeriodEdit.shouldDeleteOriginalPeriod(
      editingId: editingId,
      editingOriginalMonth: editingOriginalMonth,
      periodMonth: periodMonth,
    );
    if (monthChanged) {
      await delete(editingId!);
    }

    return WaterPeriod.fromJson(row);
  }

  Future<void> delete(String id) async {
    AppLog.d("delete water period $id");
    await _client.from("water_periods").delete().eq("id", id);
  }
}
