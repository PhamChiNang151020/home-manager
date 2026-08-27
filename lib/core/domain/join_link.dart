abstract final class JoinLink {
  static const queryKey = "join";
  static const nativeScheme = "com.pcn.home-manager";
  static const prefsKey = "pending_join_token";

  /// Written by `web/index.html` / `web/join.html` before Flutter boots so a
  /// camera-scan or PWA launch cannot drop `?join=` before Dart reads it.
  static const jsBackupKey = "toam_pending_join_token";
  static const landingFile = "join.html";

  static String? tokenFromUri(Uri uri) {
    final fromQuery = _nonEmpty(uri.queryParameters[queryKey]);
    if (fromQuery != null) {
      return fromQuery;
    }
    final fromFragment = tokenFromFragment(uri.fragment);
    if (fromFragment != null) {
      return fromFragment;
    }
    if (uri.scheme != nativeScheme) {
      return null;
    }
    final host = uri.host.toLowerCase();
    final firstSegment =
        uri.pathSegments.isEmpty ? "" : uri.pathSegments.first.toLowerCase();
    if (host != "join" && firstSegment != "join") {
      return null;
    }
    return _nonEmpty(uri.queryParameters["token"]);
  }

  /// Flutter web hash strategy may put the query inside `#/?join=`.
  static String? tokenFromFragment(String fragment) {
    if (fragment.isEmpty) return null;
    final q = fragment.indexOf("?");
    final query =
        q >= 0
            ? fragment.substring(q + 1)
            : (fragment.contains("=") ? fragment : "");
    if (query.isEmpty) return null;
    return _nonEmpty(Uri.splitQueryString(query)[queryKey]);
  }

  /// Camera / email landing page. Saves the token in localStorage then
  /// redirects into the Flutter app, so `?join=` survives engine URL rewrites.
  static String httpsJoinUrl({required String baseUrl, required String token}) {
    final base = Uri.parse(baseUrl);
    var path = base.path;
    if (!path.endsWith(landingFile)) {
      if (path.isEmpty || path == "/") {
        path = "/$landingFile";
      } else {
        if (!path.endsWith("/")) path = "$path/";
        path = "$path$landingFile";
      }
    }
    return Uri(
      scheme: base.scheme.isEmpty ? "https" : base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: path,
      queryParameters: {queryKey: token},
    ).toString();
  }

  /// Strips `join.html` / `index.html` so OAuth returns to the Flutter app.
  /// No query string — GoTrue allow-list is exact; `?join=` falls back to
  /// Site URL (often localhost).
  static String appBaseUrl(Uri pageUri) {
    return "${pageUri.origin}${_appPath(pageUri.path)}";
  }

  static String _appPath(String path) {
    var result = path;
    if (result.endsWith(landingFile)) {
      result = result.substring(0, result.length - landingFile.length);
    }
    if (result.endsWith("index.html")) {
      result = result.substring(0, result.length - "index.html".length);
    }
    if (result.isEmpty) return "/";
    if (!result.endsWith("/")) return "$result/";
    return result;
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
