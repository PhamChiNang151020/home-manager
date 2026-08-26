import "package:supabase_flutter/supabase_flutter.dart";

/// Persists FCM registration tokens for the signed-in user.
class FcmTokenService {
  FcmTokenService(this._client);

  final SupabaseClient _client;

  /// Upserts by unique [token]. Returns false if not signed in.
  Future<bool> upsertToken(String token, {String platform = "web"}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || token.isEmpty) return false;

    await _client.from("fcm_tokens").upsert({
      "user_id": userId,
      "token": token,
      "platform": platform,
      "updated_at": DateTime.now().toUtc().toIso8601String(),
    }, onConflict: "token");
    return true;
  }

  Future<void> deleteToken(String token) async {
    if (token.isEmpty) return;
    await _client.from("fcm_tokens").delete().eq("token", token);
  }
}
