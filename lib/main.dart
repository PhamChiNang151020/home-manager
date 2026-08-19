import "package:flutter/material.dart";
import "package:home_manager/app.dart";
import "package:home_manager/core/config/app_config.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:supabase_flutter/supabase_flutter.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppConfig.isConfigured) {
    runApp(const MissingConfigApp());
    return;
  }
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
  final client = Supabase.instance.client;
  final session = SessionController(
    auth: AuthService(client),
    homesApi: HomeService(client),
  );
  await session.start();
  runApp(HomeManagerApp(session: session));
}
