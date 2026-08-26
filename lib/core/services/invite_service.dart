import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class InviteService {
  InviteService(this._client);

  final SupabaseClient _client;

  /// Creates a pending invite row and returns its id.
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

  /// Creates the invite then asks the Edge Function to email the join link.
  Future<void> inviteAndNotify({
    required String homeId,
    required String email,
  }) async {
    final inviteId = await invite(homeId: homeId, email: email);
    await sendInviteEmail(inviteId);
  }

  Future<void> sendInviteEmail(String inviteId) async {
    AppLog.i("Sending invite email for $inviteId");
    try {
      final response = await _client.functions.invoke(
        "send-home-invite",
        body: {"invite_id": inviteId},
      );
      if (response.status >= 200 && response.status < 300) {
        return;
      }
      final data = response.data;
      final detail = _errorDetail(data) ?? "status ${response.status}";
      throw Exception(detail);
    } on FunctionException catch (e) {
      final detail = _errorDetail(e.details) ?? e.reasonPhrase ?? "HTTP ${e.status}";
      throw Exception(detail);
    }
  }

  static String? _errorDetail(dynamic data) {
    if (data is Map) {
      final error = data["error"] ?? data["msg"] ?? data["message"];
      if (error != null) return "$error";
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return null;
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
