import "package:flutter/foundation.dart";
import "package:url_launcher/url_launcher.dart";

/// Google OAuth on iOS/Android must leave the in-app Safari sheet.
/// [LaunchMode.platformDefault] uses SFSafariViewController, which stays open
/// after the custom-scheme callback (blank `accounts.google.com`).
LaunchMode oauthLaunchMode({required bool isWeb}) {
  if (isWeb) {
    return LaunchMode.platformDefault;
  }
  return LaunchMode.externalApplication;
}

Future<void> dismissOAuthBrowser() async {
  if (kIsWeb) return;
  try {
    await closeInAppWebView();
  } catch (_) {}
}
