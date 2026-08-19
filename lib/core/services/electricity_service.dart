import "dart:typed_data";

import "package:home_manager/core/models/electricity_period.dart";
import "package:intl/intl.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class ElectricityService {
  ElectricityService(this._client);

  final SupabaseClient _client;

  static String monthKey(DateTime month) =>
      DateFormat("yyyy-MM-01").format(DateTime(month.year, month.month));

  Future<List<ElectricityPeriod>> list(String homeId) async {
    final rows = await _client
        .from("electricity_periods")
        .select()
        .eq("home_id", homeId)
        .order("period_month", ascending: false);
    return (rows as List)
        .map(
          (row) => ElectricityPeriod.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<ElectricityPeriod?> latest(String homeId) async {
    final rows = await _client
        .from("electricity_periods")
        .select()
        .eq("home_id", homeId)
        .order("period_month", ascending: false)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) {
      return null;
    }
    return ElectricityPeriod.fromJson(Map<String, dynamic>.from(list.first as Map));
  }

  Future<ElectricityPeriod> upsert({
    required String homeId,
    required DateTime periodMonth,
    required double amountVnd,
    double? previousKwh,
    double? newKwh,
    double? consumptionKwh,
    String? photoPath,
    String? note,
  }) async {
    final row = await _client
        .from("electricity_periods")
        .upsert({
          "home_id": homeId,
          "period_month": monthKey(periodMonth),
          "amount_vnd": amountVnd,
          "previous_kwh": previousKwh,
          "new_kwh": newKwh,
          "consumption_kwh": consumptionKwh,
          "photo_path": photoPath,
          "note": note,
          "recorded_at": DateTime.now().toUtc().toIso8601String(),
        }, onConflict: "home_id,period_month")
        .select()
        .single();
    return ElectricityPeriod.fromJson(row);
  }
}

class BillPhotoService {
  BillPhotoService(this._client);

  final SupabaseClient _client;
  static const bucket = "bill-photos";

  String pathFor({required String homeId, required DateTime month}) {
    final stamp = DateFormat("yyyy-MM").format(month);
    return "homes/$homeId/$stamp.jpg";
  }

  Future<String> upload({
    required String homeId,
    required DateTime month,
    required Uint8List bytes,
  }) async {
    final path = pathFor(homeId: homeId, month: month);
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: "image/jpeg",
            upsert: true,
          ),
        );
    return path;
  }

  Future<String?> signedUrl(String? path) async {
    if (path == null || path.isEmpty) {
      return null;
    }
    return _client.storage.from(bucket).createSignedUrl(path, 3600);
  }
}
