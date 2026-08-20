import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/services/water_service.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";

const _periodRow = {
  "id": "w1",
  "home_id": "h1",
  "period_month": "2026-03-01",
  "amount_vnd": 80000,
  "previous_m3": 10,
  "new_m3": 18,
  "consumption_m3": 8,
  "photo_path": null,
  "note": null,
  "recorded_at": "2026-03-15T10:30:00.000Z",
};

void main() {
  late MockSupabaseClient client;
  late MockSupabaseQueryBuilder table;
  late WaterService service;

  setUpAll(() {
    registerSupabaseFallbacks();
  });

  setUp(() {
    resetMocktailState();
    client = MockSupabaseClient();
    table = MockSupabaseQueryBuilder();
    service = WaterService(client);
  });

  test("upsert omits is_paid when not sent", () async {
    final captured = <Map<String, dynamic>>[];
    stubPeriodUpsert(
      client: client,
      table: table,
      row: _periodRow,
      capturedPayloads: captured,
      tableName: "water_periods",
    );
    stubPeriodDelete(table: table, deletedIds: <String>[]);

    await service.upsert(
      homeId: "h1",
      periodMonth: DateTime(2026, 3),
      amountVnd: 80000,
      editingId: "w1",
      editingOriginalMonth: DateTime(2026, 3),
    );

    expect(captured, isNotEmpty);
    expect(captured.first.containsKey("is_paid"), isFalse);
  });

  test("upsert deletes original row when edit changes month", () async {
    stubPeriodUpsert(
      client: client,
      table: table,
      row: _periodRow,
      tableName: "water_periods",
    );
    final deletedIds = <String>[];
    stubPeriodDelete(table: table, deletedIds: deletedIds);

    await service.upsert(
      homeId: "h1",
      periodMonth: DateTime(2026, 4),
      amountVnd: 80000,
      editingId: "w1",
      editingOriginalMonth: DateTime(2026, 3),
    );

    expect(deletedIds, ["w1"]);
  });
}
