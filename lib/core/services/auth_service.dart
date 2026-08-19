import "package:home_manager/core/config/app_config.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() {
    AppLog.i("Starting Google OAuth sign-in");
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.oauthRedirect,
    );
  }

  Future<void> signOut() {
    AppLog.i("Signing out");
    return _client.auth.signOut();
  }
}
