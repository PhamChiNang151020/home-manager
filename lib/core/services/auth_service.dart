import "package:home_manager/core/config/app_config.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.oauthRedirect,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
