import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/shell/empty_home_view.dart";

/// Local-only join-home demo for toast QA (mocked RPC, no production data).
///
/// Run:
///   flutter run -d web-server -t tool/join_toast_web_demo.dart \
///     --web-hostname=0.0.0.0 --web-port=5555
///
/// Optional: `?autojoin=1` skips typing and runs the mocked accept so the
/// success toast is visible for screenshots.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const autoJoinDefine = bool.fromEnvironment(
    "JOIN_TOAST_AUTOJOIN",
    defaultValue: false,
  );
  final autoJoin =
      autoJoinDefine || Uri.base.queryParameters["autojoin"] == "1";
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(
        brightness: Brightness.light,
        accent: AppAccent.amber,
      ),
      home: _JoinToastDemoShell(autoJoin: autoJoin),
    ),
  );
}

class _JoinToastDemoShell extends StatefulWidget {
  const _JoinToastDemoShell({this.autoJoin = false});

  final bool autoJoin;

  @override
  State<_JoinToastDemoShell> createState() => _JoinToastDemoShellState();
}

class _JoinToastDemoShellState extends State<_JoinToastDemoShell> {
  bool _hasHome = false;
  bool _pendingJoinedToast = false;
  bool _autoJoinStarted = false;

  Future<void> _mockAccept() async {
    // Stubbed accept_invite_code RPC — no network / DB.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() {
      _hasHome = true;
      _pendingJoinedToast = true;
    });
  }

  void _scheduleJoinedToastIfNeeded() {
    if (!_pendingJoinedToast || !_hasHome) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pendingJoinedToast) return;
      _pendingJoinedToast = false;
      showAppToast(context, S.joinedHome);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.autoJoin && !_autoJoinStarted && !_hasHome) {
      _autoJoinStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mockAccept();
      });
    }
    _scheduleJoinedToastIfNeeded();
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasHome ? S.overview : S.appName),
      ),
      body: MobileViewport(
        child:
            _hasHome
                ? const Center(
                  child: Text(
                    "Tổng quan",
                    key: ValueKey("overview-body"),
                  ),
                )
                : EmptyHomeView(
                  email: "demo@local.test",
                  onAddHome: () {},
                  onSignOut: () {},
                  onAcceptCode: (_) => _mockAccept(),
                  onAcceptToken: (_) async {},
                ),
      ),
      bottomNavigationBar:
          _hasHome
              ? AppBottomNav(
                tabIndex: 0,
                onTabSelected: (_) {},
                onQuickAdd: () {},
              )
              : null,
    );
  }
}
