import "package:flutter/material.dart";
import "package:home_manager/app.dart";
import "package:home_manager/core/config/app_config.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:intl/intl.dart";
import "package:supabase_flutter/supabase_flutter.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final client = Supabase.instance.client;
  final services = AppServices(client);
  final session = SessionController(
    auth: AuthService(client),
    homesApi: HomeService(client),
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
