import "package:home_manager/core/models/home.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class InviteService {
  InviteService(this._client);

  final SupabaseClient _client;

  Future<void> invite({required String homeId, required String email}) {
    return _client.rpc(
      "invite_to_home",
      params: {"p_home_id": homeId, "p_email": email},
    );
  }

  Future<List<HomeInvite>> listPending(String homeId) async {
    final rows = await _client
        .from("home_invites")
        .select()
        .eq("home_id", homeId)
        .eq("status", "pending")
        .order("created_at");
    return (rows as List)
        .map((row) => HomeInvite.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }
}
