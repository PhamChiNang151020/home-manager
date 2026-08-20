import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";

const _periodRow = {
  "id": "p1",
  "home_id": "h1",
  "period_month": "2026-03-01",
  "amount_vnd": 70000,
  "previous_kwh": 100,
  "new_kwh": 120,
  "consumption_kwh": 20,
  "photo_path": null,
  "note": null,
  "recorded_at": "2026-03-15T10:30:00.000Z",
};

void main() {
  late MockSupabaseClient client;
  late MockSupabaseQueryBuilder table;
  late ElectricityService service;

  setUpAll(() {
    registerSupabaseFallbacks();
  });

  setUp(() {
    resetMocktailState();
    client = MockSupabaseClient();
    table = MockSupabaseQueryBuilder();
    service = ElectricityService(client);
  });

  test(
    "upsert returns parsed period without delete when month unchanged",
    () async {
      stubPeriodUpsert(client: client, table: table, row: _periodRow);
      final deletedIds = <String>[];
      stubPeriodDelete(table: table, deletedIds: deletedIds);

      final period = await service.upsert(
        homeId: "h1",
        periodMonth: DateTime(2026, 3),
        amountVnd: 70000,
        editingId: "p1",
        editingOriginalMonth: DateTime(2026, 3),
      );

      expect(period.id, "p1");
      expect(deletedIds, isEmpty);
    },
  );

  test("upsert deletes original row when edit changes month", () async {
    stubPeriodUpsert(client: client, table: table, row: _periodRow);
    final deletedIds = <String>[];
    stubPeriodDelete(table: table, deletedIds: deletedIds);

    await service.upsert(
      homeId: "h1",
      periodMonth: DateTime(2026, 4),
      amountVnd: 70000,
      editingId: "p1",
      editingOriginalMonth: DateTime(2026, 3),
    );

    expect(deletedIds, ["p1"]);
  });

  test("upsert does not delete when creating new period", () async {
    stubPeriodUpsert(client: client, table: table, row: _periodRow);
    final deletedIds = <String>[];
    stubPeriodDelete(table: table, deletedIds: deletedIds);

    await service.upsert(
      homeId: "h1",
      periodMonth: DateTime(2026, 5),
      amountVnd: 80000,
    );

    expect(deletedIds, isEmpty);
  });

  test("delete calls supabase delete eq id", () async {
    when(() => client.from("electricity_periods")).thenAnswer((_) => table);
    final deletedIds = <String>[];
    stubPeriodDelete(table: table, deletedIds: deletedIds);

    await service.delete("p99");

    expect(deletedIds, ["p99"]);
  });

  test("upsert omits is_paid when editing without sending isPaid", () async {
    final captured = <Map<String, dynamic>>[];
    stubPeriodUpsert(
      client: client,
      table: table,
      row: _periodRow,
      capturedPayloads: captured,
    );
    stubPeriodDelete(table: table, deletedIds: <String>[]);

    await service.upsert(
      homeId: "h1",
      periodMonth: DateTime(2026, 3),
      amountVnd: 70000,
      editingId: "p1",
      editingOriginalMonth: DateTime(2026, 3),
    );

    expect(captured, isNotEmpty);
    expect(captured.first.containsKey("is_paid"), isFalse);
  });

  test("upsert includes is_paid when explicitly provided", () async {
    final captured = <Map<String, dynamic>>[];
    stubPeriodUpsert(
      client: client,
      table: table,
      row: {..._periodRow, "is_paid": true},
      capturedPayloads: captured,
    );
    stubPeriodDelete(table: table, deletedIds: <String>[]);

    await service.upsert(
      homeId: "h1",
      periodMonth: DateTime(2026, 3),
      amountVnd: 70000,
      isPaid: true,
    );

    expect(captured.first["is_paid"], isTrue);
  });
}
