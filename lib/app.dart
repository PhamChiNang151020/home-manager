import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/shell/app_shell.dart";

class HomeManagerApp extends StatelessWidget {
  const HomeManagerApp({super.key, required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          if (session.loading && session.user == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (session.user == null) {
            return SignInPage(onGoogle: session.signIn, error: session.error);
          }
          return AppShell(session: session);
        },
      ),
    );
  }
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appName,
      home: const MissingConfigPage(),
    );
  }
}
