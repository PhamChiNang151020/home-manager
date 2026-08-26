abstract final class JoinLink {
  static const queryKey = "join";
  static const nativeScheme = "com.pcn.home-manager";
  static const prefsKey = "pending_join_token";

  static String? tokenFromUri(Uri uri) {
    final fromQuery = uri.queryParameters[queryKey]?.trim();
    if (fromQuery != null && fromQuery.isNotEmpty) {
      return fromQuery;
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
    final token = uri.queryParameters["token"]?.trim();
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  static String httpsJoinUrl({required String baseUrl, required String token}) {
    final base = Uri.parse(baseUrl);
    return base
        .replace(queryParameters: {...base.queryParameters, queryKey: token})
        .toString();
  }
}
