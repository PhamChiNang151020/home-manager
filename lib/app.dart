import "package:flutter/material.dart";
import "package:home_manager/core/l10n/app_locale.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/pwa_history.dart";
import "package:home_manager/core/services/web_theme_color.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/pwa_viewport_scope.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/lock/lock_screen.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shell/app_shell.dart";

class HomeManagerApp extends StatelessWidget {
  const HomeManagerApp({
    super.key,
    required this.session,
    required this.theme,
    required this.lock,
    required this.services,
  });

  final SessionController session;
  final ThemeController theme;
  final LockController lock;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        return MaterialApp(
          title: S.appName,
          debugShowCheckedModeBanner: false,
          locale: AppLocale.locale,
          localizationsDelegates: AppLocale.delegates,
          supportedLocales: AppLocale.supportedLocales,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: theme.accent,
          ),
          darkTheme: AppTheme.build(
            brightness: Brightness.dark,
            accent: theme.accent,
          ),
          themeMode: theme.mode,
          builder: _syncWebThemeColor,
          home: _AppHome(
            session: session,
            theme: theme,
            lock: lock,
            services: services,
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
          locale: AppLocale.locale,
          localizationsDelegates: AppLocale.delegates,
          supportedLocales: AppLocale.supportedLocales,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: theme.accent,
          ),
          darkTheme: AppTheme.build(
            brightness: Brightness.dark,
            accent: theme.accent,
          ),
          themeMode: theme.mode,
          builder: _syncWebThemeColor,
          home: const MissingConfigPage(),
        );
      },
    );
  }
}

Widget _syncWebThemeColor(BuildContext context, Widget? child) {
  final colors = Theme.of(context).extension<AppColorScheme>();
  if (colors != null) {
    updateWebThemeColor(colors.bgBase);
  }
  return PwaViewportScope(child: child ?? const SizedBox.shrink());
}

class _AppHome extends StatefulWidget {
  const _AppHome({
    required this.session,
    required this.theme,
    required this.lock,
    required this.services,
  });

  final SessionController session;
  final ThemeController theme;
  final LockController lock;
  final AppServices services;

  @override
  State<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<_AppHome> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    installPwaHistoryGuard();
    widget.session.addListener(_onSessionChange);
    if (widget.session.user != null) {
      resetPwaBrowserHistory();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.session.removeListener(_onSessionChange);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        widget.lock.onPaused();
      case AppLifecycleState.resumed:
        widget.lock.onResumed();
      default:
        break;
    }
  }

  void _onSessionChange() {
    if (widget.session.user != null) {
      resetPwaBrowserHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final lock = widget.lock;
    return AnimatedBuilder(
      animation: Listenable.merge([session, lock]),
      builder: (context, _) {
        if (session.loading && session.user == null) {
          return const BrandedLoadingScreen();
        }
        if (session.user == null) {
          return SignInPage(onGoogle: session.signIn, error: session.error);
        }
        if (lock.isLocked) {
          return LockScreen(lock: lock);
        }
        return AppShell(
          session: session,
          theme: widget.theme,
          lock: lock,
          services: widget.services,
        );
      },
    );
  }
}
