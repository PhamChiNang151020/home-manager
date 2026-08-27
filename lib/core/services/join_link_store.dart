import "dart:async";

import "package:app_links/app_links.dart";
import "package:home_manager/core/domain/join_link.dart";
import "package:home_manager/core/logging/app_log.dart";
import "join_link_js_stub.dart"
    if (dart.library.html) "join_link_js_web.dart"
    if (dart.library.js_interop) "join_link_js_web.dart";
import "package:shared_preferences/shared_preferences.dart";

class JoinLinkStore {
  static Future<void> captureFrom(Uri uri) async {
    final token = JoinLink.tokenFromUri(uri);
    if (token == null) return;
    AppLog.i("Captured join token from $uri");
    await persist(token);
  }

  static Future<void> persist(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(JoinLink.prefsKey, token);
    persistJoinTokenJs(token);
  }

  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = prefs.getString(JoinLink.prefsKey)?.trim();
    if (fromPrefs != null && fromPrefs.isNotEmpty) return fromPrefs;
    final fromJs = readJoinTokenJs();
    if (fromJs == null) return null;
    await prefs.setString(JoinLink.prefsKey, fromJs);
    return fromJs;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(JoinLink.prefsKey);
    clearJoinTokenJs();
  }
}

class JoinLinkListener {
  StreamSubscription<Uri>? _sub;

  Future<void> start({required Future<void> Function() onCaptured}) async {
    await JoinLinkStore.captureFrom(Uri.base);
    final links = AppLinks();
    try {
      final initial = await links.getInitialLink();
      if (initial != null) {
        await JoinLinkStore.captureFrom(initial);
      }
    } catch (e) {
      AppLog.d("JoinLinkListener initial link skipped: $e");
    }
    _sub = links.uriLinkStream.listen((uri) async {
      await JoinLinkStore.captureFrom(uri);
      await onCaptured();
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
