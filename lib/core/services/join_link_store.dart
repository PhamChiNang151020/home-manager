import "dart:async";

import "package:app_links/app_links.dart";
import "package:home_manager/core/domain/join_link.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:shared_preferences/shared_preferences.dart";

class JoinLinkStore {
  static Future<void> captureFrom(Uri uri) async {
    final token = JoinLink.tokenFromUri(uri);
    if (token == null) return;
    AppLog.i("Captured join token from $uri");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(JoinLink.prefsKey, token);
  }

  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(JoinLink.prefsKey)?.trim();
    if (token == null || token.isEmpty) return null;
    return token;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(JoinLink.prefsKey);
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
