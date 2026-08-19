import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shell/app_shell.dart";

class HomeManagerApp extends StatelessWidget {
  const HomeManagerApp({
    super.key,
    required this.session,
    required this.theme,
  });

  final SessionController session;
  final ThemeController theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return MaterialApp(
          title: S.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: theme.accent,
          ),
          darkTheme: AppTheme.build(
            brightness: Brightness.dark,
            accent: theme.accent,
          ),
          themeMode: theme.mode,
          home: AnimatedBuilder(
            animation: session,
            builder: (context, _) {
              if (session.loading && session.user == null) {
                return const Scaffold(body: LoadingView());
              }
              if (session.user == null) {
                return SignInPage(
                  onGoogle: session.signIn,
                  error: session.error,
                );
              }
              return AppShell(session: session, theme: theme);
            },
          ),
        );
      },
    );
  }
}

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key, required this.theme});

  final ThemeController theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return MaterialApp(
          title: S.appName,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: theme.accent,
          ),
          darkTheme: AppTheme.build(
            brightness: Brightness.dark,
            accent: theme.accent,
          ),
          themeMode: theme.mode,
          home: const MissingConfigPage(),
        );
      },
    );
  }
}
