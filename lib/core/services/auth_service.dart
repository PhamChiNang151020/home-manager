import "package:flutter/foundation.dart";
import "package:home_manager/core/config/app_config.dart";
import "package:home_manager/core/domain/join_link.dart";
import "package:home_manager/core/domain/oauth_launch.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/services/join_link_store.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    AppLog.i("Starting Google OAuth sign-in");
    var redirectTo = AppConfig.oauthRedirect;
    if (kIsWeb) {
      final token = await JoinLinkStore.read();
      if (token != null) {
        redirectTo = JoinLink.appUrlWithJoin(baseUrl: redirectTo, token: token);
      }
    }
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
      authScreenLaunchMode: oauthLaunchMode(isWeb: kIsWeb),
    );
  }

  Future<void> signOut() {
    AppLog.i("Signing out");
    return _client.auth.signOut();
  }
}
