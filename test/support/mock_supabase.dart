import "dart:async";

import "package:mocktail/mocktail.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

/// Completes with [value] when awaited after `.select().single()`.
class ImmediatePostgrestMap extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  ImmediatePostgrestMap(this._value);

  final PostgrestMap _value;

  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestMap) onValue, {
    Function? onError,
  }) {
    return Future.value(_value).then(onValue, onError: onError);
  }
}

/// Completes when awaited after `.delete().eq(...)`.
class CompletingDeleteEq extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  CompletingDeleteEq(this.periodId, this.deletedIds);

  final String periodId;
  final List<String> deletedIds;

  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestList) onValue, {
    Function? onError,
  }) {
    deletedIds.add(periodId);
    return Future.value(
      <Map<String, dynamic>>[],
    ).then(onValue, onError: onError);
  }
}

void registerSupabaseFallbacks() {
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(DateTime(2026));
}

void stubPeriodUpsert({
  required MockSupabaseClient client,
  required MockSupabaseQueryBuilder table,
  required Map<String, dynamic> row,
  List<Map<String, dynamic>>? capturedPayloads,
  String tableName = "electricity_periods",
}) {
  final upsertBuilder = MockPostgrestFilterBuilder();
  final selectBuilder = MockPostgrestFilterBuilder();

  when(() => client.from(tableName)).thenAnswer((_) => table);
  when(
    () => table.upsert(any(), onConflict: any(named: "onConflict")),
  ).thenAnswer((invocation) {
    final payload = invocation.positionalArguments[0];
    if (capturedPayloads != null && payload is Map) {
      capturedPayloads.add(Map<String, dynamic>.from(payload));
    }
    return upsertBuilder;
  });
  when(() => upsertBuilder.select()).thenAnswer((_) => selectBuilder);
  when(
    () => selectBuilder.single(),
  ).thenAnswer((_) => ImmediatePostgrestMap(row));
}

void stubPeriodDelete({
  required MockSupabaseQueryBuilder table,
  required List<String> deletedIds,
}) {
  final deleteBuilder = MockPostgrestFilterBuilder();
  when(() => table.delete()).thenAnswer((_) => deleteBuilder);
  when(() => deleteBuilder.eq("id", any())).thenAnswer((invocation) {
    final id = invocation.positionalArguments[1] as String;
    return CompletingDeleteEq(id, deletedIds);
  });
}
