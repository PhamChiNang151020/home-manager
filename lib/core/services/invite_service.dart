import "package:home_manager/core/domain/invite_code.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class InviteService {
  InviteService(this._client);

  final SupabaseClient _client;

  /// Creates a pending invite row. The invitee joins on Google login with
  /// that email (`accept_pending_invites`). No outbound email is sent.
  Future<String> invite({required String homeId, required String email}) async {
    AppLog.i("Inviting $email to home $homeId");
    final result = await _client.rpc(
      "invite_to_home",
      params: {"p_home_id": homeId, "p_email": email},
    );
    final id = "$result".trim();
    if (id.isEmpty || id == "null") {
      throw Exception("invite_to_home không trả về id");
    }
    return id;
  }

  Future<void> cancel(String inviteId) {
    AppLog.i("Cancelling invite $inviteId");
    return _client.from("home_invites").delete().eq("id", inviteId);
  }

  Future<List<HomeInvite>> listPending(String homeId) async {
    final rows = await _client
        .from("home_invites")
        .select()
        .eq("home_id", homeId)
        .eq("status", "pending")
        .order("created_at");
    return (rows as List)
        .map(
          (row) => HomeInvite.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<HomeJoinLink> createOrGetJoinLink(
    String homeId, {
    bool rotate = false,
  }) async {
    AppLog.i("Join link for $homeId rotate=$rotate");
    final result = await _client.rpc(
      "create_or_get_join_link",
      params: {"p_home_id": homeId, "p_rotate": rotate},
    );
    return HomeJoinLink.fromJson(_asJsonMap(result));
  }

  Future<String> acceptJoinToken(String token) async {
    AppLog.i("Accepting join token");
    final result = await _client.rpc(
      "accept_invite_token",
      params: {"p_token": token},
    );
    final id = "$result".trim();
    if (id.isEmpty || id == "null") {
      throw Exception("accept_invite_token không trả về id");
    }
    return id;
  }

  /// Accepts a 6-char invite code. RPC returns jsonb
  /// `{status:'ok',home_id}` / `{status:'invalid'}` / `{status:'locked'}`.
  Future<String> acceptInviteCode(String code) async {
    AppLog.i("Accepting invite code");
    final result = await _client.rpc(
      "accept_invite_code",
      params: {"p_code": code},
    );
    final map = _asJsonMap(result);
    final status = "${map["status"] ?? ""}".trim().toLowerCase();
    switch (status) {
      case "ok":
        final id = "${map["home_id"] ?? ""}".trim();
        if (id.isEmpty || id == "null") {
          throw const InviteCodeException(
            InviteCodeAcceptError.other,
            "accept_invite_code không trả về home_id",
          );
        }
        return id;
      case "locked":
        throw const InviteCodeException(InviteCodeAcceptError.tooManyAttempts);
      case "invalid":
        throw const InviteCodeException(InviteCodeAcceptError.invalidOrExpired);
      default:
        throw InviteCodeException(
          InviteCodeAcceptError.other,
          "accept_invite_code status không hợp lệ: $status",
        );
    }
  }

  Future<void> revokeJoinLink(String homeId) async {
    AppLog.i("Revoking join link for $homeId");
    await _client.rpc("revoke_join_link", params: {"p_home_id": homeId});
  }

  static Map<String, dynamic> _asJsonMap(dynamic result) {
    if (result is Map<String, dynamic>) {
      return result;
    }
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    throw FormatException("Unexpected join link payload: $result");
  }
}
