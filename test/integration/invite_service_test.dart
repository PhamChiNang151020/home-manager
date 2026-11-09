import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/invite_code.dart";
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
        "code": "K7M2QP",
      }),
    );

    final link = await service.createOrGetJoinLink("h1");

    expect(link.token, "abc123");
    expect(link.homeId, "h1");
    expect(link.code, "K7M2QP");
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
        "code": "ABCDEF",
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

  test("acceptInviteCode returns home id from status ok", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult({"status": "ok", "home_id": "h1"}),
    );

    final homeId = await service.acceptInviteCode("K7M2QP");

    expect(homeId, "h1");
    verify(
      () => client.rpc("accept_invite_code", params: {"p_code": "K7M2QP"}),
    ).called(1);
  });

  test("acceptInviteCode maps invalid status", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult({"status": "invalid"}),
    );

    await expectLater(
      () => service.acceptInviteCode("BADCOD"),
      throwsA(
        isA<InviteCodeException>().having(
          (e) => e.kind,
          "kind",
          InviteCodeAcceptError.invalidOrExpired,
        ),
      ),
    );
  });

  test("acceptInviteCode maps locked status", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult({"status": "locked"}),
    );

    await expectLater(
      () => service.acceptInviteCode("K7M2QP"),
      throwsA(
        isA<InviteCodeException>().having(
          (e) => e.kind,
          "kind",
          InviteCodeAcceptError.tooManyAttempts,
        ),
      ),
    );
  });

  test("invite returns invite id from RPC", () async {
    when(() => client.rpc(any(), params: any(named: "params"))).thenAnswer(
      (_) => ImmediateRpcResult("inv-1"),
    );

    final id = await service.invite(homeId: "h1", email: "a@b.com");

    expect(id, "inv-1");
    verify(
      () => client.rpc(
        "invite_to_home",
        params: {"p_home_id": "h1", "p_email": "a@b.com"},
      ),
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
