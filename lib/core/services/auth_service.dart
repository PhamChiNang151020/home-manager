import "package:flutter/foundation.dart";
import "package:home_manager/core/config/app_config.dart";
import "package:home_manager/core/domain/oauth_launch.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    AppLog.i("Starting Google OAuth sign-in");
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.oauthRedirect,
      authScreenLaunchMode: oauthLaunchMode(isWeb: kIsWeb),
    );
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    AppLog.i("Signing in with email/password");
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    AppLog.i("Signing up with email/password");
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    AppLog.i("Sending password reset email");
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: AppConfig.oauthRedirect,
    );
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    AppLog.i("Updating password");
    return _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> signOut() {
    AppLog.i("Signing out");
    return _client.auth.signOut();
  }
}
