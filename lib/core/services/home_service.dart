import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class HomeService {
  HomeService(this._client);

  final SupabaseClient _client;

  Future<int> acceptPendingInvites() async {
    final result = await _client.rpc("accept_pending_invites");
    if (result is int) {
      return result;
    }
    return int.tryParse("$result") ?? 0;
  }

  Future<List<Home>> listHomes() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      AppLog.d("listHomes: no user");
      return [];
    }
    AppLog.d("listHomes for $uid");
    final memberships = await _client
        .from("home_members")
        .select("home_id, role, homes(*)")
        .eq("user_id", uid);
    return (memberships as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final homeJson = Map<String, dynamic>.from(map["homes"] as Map);
      return Home.fromJson(homeJson, myRole: map["role"] as String);
    }).toList();
  }

  Future<String> createHome({
    required String name,
    required TrackingMode mode,
    double kwhRate = 3500,
    int? photoDueDay,
    int? paydayDay,
    int? remindDay,
  }) async {
    final id = await _client.rpc(
      "create_home",
      params: {
        "p_name": name,
        "p_tracking_mode": mode.dbValue,
        "p_kwh_rate": kwhRate,
        "p_photo_due_day": photoDueDay,
        "p_payday_day": paydayDay,
        "p_remind_day": remindDay,
      },
    );
    return id as String;
  }

  Future<void> updateSettings({
    required String homeId,
    String? name,
    double? kwhRate,
    double? m3Rate,
    int? photoDueDay,
    int? paydayDay,
    int? remindDay,
  }) {
    return _client.rpc(
      "update_home_settings",
      params: {
        "p_home_id": homeId,
        "p_name": name,
        "p_kwh_rate": kwhRate,
        "p_m3_rate": m3Rate,
        "p_photo_due_day": photoDueDay,
        "p_payday_day": paydayDay,
        "p_remind_day": remindDay,
      },
    );
  }

  Future<List<HomeMember>> listMembers(String homeId) async {
    final rows = await _client
        .from("home_members")
        .select("user_id, role, profiles(email, display_name)")
        .eq("home_id", homeId);
    return (rows as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final profile = map["profiles"] as Map?;
      return HomeMember(
        userId: map["user_id"] as String,
        role: map["role"] as String,
        email: profile?["email"] as String?,
        displayName: profile?["display_name"] as String?,
      );
    }).toList();
  }
}
