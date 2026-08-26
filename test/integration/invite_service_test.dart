import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";

void main() {
  late MockSupabaseClient client;
  late InviteService service;

  setUpAll(() {
    registerSupabaseFallbacks();
  });

  setUp(() {
    resetMocktailState();
    client = MockSupabaseClient();
    service = InviteService(client);
  });

  test("createOrGetJoinLink parses token payload", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult({
        "token": "abc123",
        "home_id": "h1",
        "expires_at": "2026-09-08T00:00:00.000Z",
      }),
    );

    final link = await service.createOrGetJoinLink("h1");

    expect(link.token, "abc123");
    expect(link.homeId, "h1");
    expect(link.expiresAt.toUtc(), DateTime.utc(2026, 9, 8));
    verify(
      () => client.rpc(
        "create_or_get_join_link",
        params: {"p_home_id": "h1", "p_rotate": false},
      ),
    ).called(1);
  });

  test("createOrGetJoinLink rotate passes p_rotate true", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult({
        "token": "newtok",
        "home_id": "h1",
        "expires_at": "2026-09-08T00:00:00.000Z",
      }),
    );

    await service.createOrGetJoinLink("h1", rotate: true);

    verify(
      () => client.rpc(
        "create_or_get_join_link",
        params: {"p_home_id": "h1", "p_rotate": true},
      ),
    ).called(1);
  });

  test("acceptJoinToken returns home id", () async {
    when(
      () => client.rpc(any(), params: any(named: "params")),
    ).thenAnswer((_) => ImmediateRpcResult("h1"));

    final homeId = await service.acceptJoinToken("abc123");

    expect(homeId, "h1");
    verify(
      () => client.rpc("accept_invite_token", params: {"p_token": "abc123"}),
    ).called(1);
  });

  test("revokeJoinLink calls RPC", () async {
    when(
      () => client.rpc(any(), params: any(named: "params")),
    ).thenAnswer((_) => ImmediateRpcResult(null));

    await service.revokeJoinLink("h1");

    verify(
      () => client.rpc("revoke_join_link", params: {"p_home_id": "h1"}),
    ).called(1);
  });
}
