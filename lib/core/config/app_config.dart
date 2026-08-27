import "package:flutter/foundation.dart";
import "package:home_manager/core/domain/join_link.dart";

class AppConfig {
  static const supabaseUrl = String.fromEnvironment("SUPABASE_URL");
  static const supabaseAnonKey = String.fromEnvironment("SUPABASE_ANON_KEY");

  /// Custom scheme registered in ios/Runner/Info.plist and Supabase Auth.
  static const iosOauthRedirect = "com.pcn.home-manager://login-callback";

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get oauthRedirect {
    if (!kIsWeb) {
      return iosOauthRedirect;
    }
    final uri = Uri.base;
    if (uri.scheme == "http" || uri.scheme == "https") {
      return JoinLink.appBaseUrl(uri);
    }
    return "http://localhost:8080/";
  }
}
