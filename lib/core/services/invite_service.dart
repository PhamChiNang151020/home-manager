import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class InviteService {
  InviteService(this._client);

  final SupabaseClient _client;

  Future<void> invite({required String homeId, required String email}) {
    AppLog.i("Inviting $email to home $homeId");
    return _client.rpc(
      "invite_to_home",
      params: {"p_home_id": homeId, "p_email": email},
    );
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
    return result as String;
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
