import "dart:io";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/shell/empty_home_view.dart";

const _outDir = "/opt/cursor/artifacts/dot1";

/// Mirrors AppShell join timing: flag after accept, toast post-frame with nav.
class _JoinFlowShell extends StatefulWidget {
  const _JoinFlowShell();

  @override
  State<_JoinFlowShell> createState() => _JoinFlowShellState();
}

class _JoinFlowShellState extends State<_JoinFlowShell> {
  bool _hasHome = false;
  bool _pendingJoinedToast = false;

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
    _scheduleJoinedToastIfNeeded();
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasHome ? S.overview : S.appName),
      ),
      body: MobileViewport(
        child:
            _hasHome
                ? const Center(child: Text("overview"))
                : EmptyHomeView(
                  email: "a@b.com",
                  onAddHome: () {},
                  onSignOut: () {},
                  onAcceptCode: (_) async {
                    // Mocked RPC: success without touching production.
                    setState(() {
                      _hasHome = true;
                      _pendingJoinedToast = true;
                    });
                  },
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

Future<void> _loadNunito() async {
  final loader =
      FontLoader("Nunito")
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Regular.ttf"))
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Medium.ttf"))
        ..addFont(
          rootBundle.load("assets/fonts/Nunito/static/Nunito-SemiBold.ttf"),
        )
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Bold.ttf"))
        ..addFont(
          rootBundle.load("assets/fonts/Nunito/static/Nunito-ExtraBold.ttf"),
        );
  await loader.load();
}

Future<void> _savePng(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey("shot")),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final dir = Directory(_outDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File("$_outDir/07_join_toast_tong_quan.png").writeAsBytesSync(bytes!);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (Directory("/opt/cursor/artifacts").existsSync()) {
      await _loadNunito();
    }
  });

  testWidgets(
    "join-success toast bottom is 8px above bottom nav top on 393x852",
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      // Đợt 1 nav = 64 + 34 -> top 754; toast y 698–746.
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: AppAccent.amber,
          ),
          home: RepaintBoundary(
            key: const ValueKey("shot"),
            child: const SizedBox(
              width: 393,
              height: 852,
              child: MediaQuery(
                data: MediaQueryData(
                  size: Size(393, 852),
                  padding: EdgeInsets.only(bottom: 34),
                  viewPadding: EdgeInsets.only(bottom: 34),
                  textScaler: TextScaler.noScaling,
                ),
                child: _JoinFlowShell(),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), "K7M2QP");
      await tester.pump();
      await tester.tap(find.text(S.enterHome));
      await tester.pump(); // setState: home + nav + schedule toast
      await tester.pump(); // post-frame toast

      expect(find.text(S.joinedHome), findsOneWidget);
      expect(find.byType(AppBottomNav), findsOneWidget);
      expect(find.text(S.overview), findsWidgets);

      // Measure the floating snack bar surface (Material), not the SnackBar
      // slot which can report a different layout rect.
      final toastRect = tester.getRect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Material),
        ),
      );
      final navRect = tester.getRect(find.byType(AppBottomNav));

      expect(navRect.top, closeTo(754, 0.5));
      expect(
        toastRect.bottom,
        closeTo(navRect.top - 8, 0.5),
        reason:
            "toast bottom ${toastRect.bottom} should be 8px above "
            "nav top ${navRect.top}",
      );
      // Expected band on 393×852 with nav top 754: toast y 698–746.
      expect(toastRect.top, closeTo(698, 0.5));
      expect(toastRect.bottom, closeTo(746, 0.5));

      final outDir = Directory(_outDir);
      if (outDir.existsSync() || Directory("/opt/cursor/artifacts").existsSync()) {
        outDir.createSync(recursive: true);
        await _savePng(tester);
        File("$_outDir/measured.join_toast_y.txt").writeAsStringSync(
          "toast_top=${toastRect.top}\n"
          "toast_bottom=${toastRect.bottom}\n"
          "nav_top=${navRect.top}\n"
          "gap_above_nav=${navRect.top - toastRect.bottom}\n"
          "viewport=393x852\n"
          "expected_band=698-746\n",
        );
      }
    },
  );
}
