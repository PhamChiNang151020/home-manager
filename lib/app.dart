import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shell/app_shell.dart";

class HomeManagerApp extends StatelessWidget {
  const HomeManagerApp({super.key, required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: AnimatedBuilder(
        animation: session,
        builder: (context, _) {
          if (session.loading && session.user == null) {
            return const Scaffold(body: LoadingView());
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
      theme: AppTheme.dark(),
      home: const MissingConfigPage(),
    );
  }
}
