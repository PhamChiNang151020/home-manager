class AppConfig {
  static const supabaseUrl = String.fromEnvironment("SUPABASE_URL");
  static const supabaseAnonKey = String.fromEnvironment("SUPABASE_ANON_KEY");

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get oauthRedirect {
    final uri = Uri.base;
    if (uri.scheme == "http" || uri.scheme == "https") {
      return uri.origin + uri.path;
    }
    return "http://localhost:8080/";
  }
}
