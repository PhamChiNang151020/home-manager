import "package:flutter/foundation.dart";
import "package:home_manager/core/domain/oauth_redirect.dart";

import "page_uri_stub.dart"
    if (dart.library.html) "page_uri_web.dart"
    if (dart.library.js_interop) "page_uri_web.dart";

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
    return OauthRedirect.webFromPage(currentPageUri());
  }
}
