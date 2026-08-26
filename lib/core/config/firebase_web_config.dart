/// Firebase web config from `--dart-define` (optional feature).
///
/// Unlike [AppConfig] / Supabase, missing values do **not** block app startup —
/// only push/notification helpers are disabled.
class FirebaseWebConfig {
  static const apiKey = String.fromEnvironment("FIREBASE_API_KEY");
  static const authDomain = String.fromEnvironment("FIREBASE_AUTH_DOMAIN");
  static const projectId = String.fromEnvironment("FIREBASE_PROJECT_ID");
  static const storageBucket = String.fromEnvironment("FIREBASE_STORAGE_BUCKET");
  static const messagingSenderId = String.fromEnvironment(
    "FIREBASE_MESSAGING_SENDER_ID",
  );
  static const appId = String.fromEnvironment("FIREBASE_APP_ID");
  static const vapidKey = String.fromEnvironment("FIREBASE_VAPID_KEY");

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      authDomain.isNotEmpty &&
      projectId.isNotEmpty &&
      storageBucket.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      appId.isNotEmpty &&
      vapidKey.isNotEmpty;

  /// Absolute path under the current base href (e.g. `/home-manager/firebase-messaging-sw.js`).
  static String get messagingServiceWorkerScriptPath =>
      Uri.base.resolve("firebase-messaging-sw.js").path;
}
