import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";

void main() {
  late MockSupabaseClient client;
  late HomeService service;

  setUpAll(() {
    registerSupabaseFallbacks();
  });

  setUp(() {
    resetMocktailState();
    client = MockSupabaseClient();
    service = HomeService(client);
  });

  test("leaveHome sends home id only for a member", () async {
    when(
      () => client.rpc(any(), params: any(named: "params")),
    ).thenAnswer((_) => ImmediateRpcResult(null));

    await service.leaveHome(homeId: "h1");

    verify(
      () => client.rpc("leave_home", params: {"p_home_id": "h1"}),
    ).called(1);
  });

  test("leaveHome sends new owner id when transferring", () async {
    when(
      () => client.rpc(any(), params: any(named: "params")),
    ).thenAnswer((_) => ImmediateRpcResult(null));

    await service.leaveHome(homeId: "h1", newOwnerId: "u2");

    verify(
      () => client.rpc(
        "leave_home",
        params: {"p_home_id": "h1", "p_new_owner_id": "u2"},
      ),
    ).called(1);
  });
}
