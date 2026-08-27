import "package:home_manager/core/domain/join_link.dart";

/// Web Google OAuth `redirectTo`. Must be an exact URL in the Supabase Auth
/// allow-list. Query strings (including `?join=`) fail that match and GoTrue
/// falls back to Site URL — often `http://localhost:8080`.
///
/// Join tokens are persisted in localStorage before OAuth; do not attach them
/// here.
abstract final class OauthRedirect {
  static const localDev = "http://localhost:8080/";

  static String webFromPage(Uri pageUri) {
    if (pageUri.scheme != "http" && pageUri.scheme != "https") {
      return localDev;
    }
    if (pageUri.host.isEmpty) return localDev;
    return JoinLink.appBaseUrl(pageUri);
  }
}
