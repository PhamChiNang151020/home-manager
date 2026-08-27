import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:home_manager/app.dart";
import "package:home_manager/core/config/app_config.dart";
import "package:home_manager/core/config/firebase_web_config.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/join_link_store.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:intl/intl.dart";
import "package:supabase_flutter/supabase_flutter.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLog.bindFlutterErrors();
  await JoinLinkStore.captureFrom(Uri.base);
  await initializeDateFormatting("vi");
  Intl.defaultLocale = "vi";
  AppLog.i("Starting home_manager");
  final theme = await ThemeController.load();
  final lock = await LockController.load();
  if (!AppConfig.isConfigured) {
    AppLog.w("Supabase not configured");
    runApp(MissingConfigApp(theme: theme));
    return;
  }
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
  await _initFirebaseMessagingIfConfigured();
  final client = Supabase.instance.client;
  final services = AppServices(client);
  final session = SessionController(
    auth: AuthService(client),
    homesApi: HomeService(client),
    invites: services.invites,
  );
  await session.start();
  runApp(
    HomeManagerApp(
      session: session,
      theme: theme,
      lock: lock,
      services: services,
    ),
  );
}

/// Soft init: FCM is optional. Never blocks app start; web-only in Phase 1.
Future<void> _initFirebaseMessagingIfConfigured() async {
  if (!kIsWeb) return;
  if (!FirebaseWebConfig.isConfigured) {
    AppLog.w(
      "Firebase web config incomplete; push notifications disabled "
      "(set FIREBASE_* via --dart-define)",
    );
    return;
  }
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: FirebaseWebConfig.apiKey,
        authDomain: FirebaseWebConfig.authDomain,
        projectId: FirebaseWebConfig.projectId,
        storageBucket: FirebaseWebConfig.storageBucket,
        messagingSenderId: FirebaseWebConfig.messagingSenderId,
        appId: FirebaseWebConfig.appId,
      ),
    );
    AppLog.i("Firebase initialized for Cloud Messaging (web)");
  } catch (e, st) {
    AppLog.e(
      "Firebase init failed; continuing without FCM",
      error: e,
      stackTrace: st,
    );
  }
}
