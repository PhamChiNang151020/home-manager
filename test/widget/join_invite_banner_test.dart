import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/join_link.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/auth/join_invite_banner.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/shared/auth_card.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../support/mock_supabase.dart";
import "../support/shots.dart";

class MockAuthService extends AuthService {
  MockAuthService() : super(MockSupabaseClient());
}


Future<void> _loadNunito() async {
  await loadShotFonts();
}

Future<void> _savePng(WidgetTester tester, String name) async {
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
  writeShotBytes("$name.png", bytes!);
}

Widget _frame(Widget home, {double viewPaddingTop = 0}) {
  return MaterialApp(
    theme: AppTheme.build(
      brightness: Brightness.light,
      accent: AppAccent.amber,
      glass: false,
    ),
    home: RepaintBoundary(
      key: const ValueKey("shot"),
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(393, 852),
          padding: EdgeInsets.only(top: viewPaddingTop),
          viewPadding: EdgeInsets.only(top: viewPaddingTop),
          textScaler: TextScaler.noScaling,
        ),
        child: home,
      ),
    ),
  );
}

Future<void> _pumpSignIn(
  WidgetTester tester, {
  String? joinToken,
  String? error,
  double viewPaddingTop = 0,
}) async {
  SharedPreferences.setMockInitialValues({
    if (joinToken != null) JoinLink.prefsKey: joinToken,
  });
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _frame(
      SignInPage(authService: MockAuthService(), error: error),
      viewPaddingTop: viewPaddingTop,
    ),
  );
  // JoinLinkStore.read is async; wait for the banner decision.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  final runShots = shouldCaptureShots;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Always load Nunito: the default test font (Ahem) is wider and overflows
    // the sign-in footer Row at 393px. Screenshots stay optional.
    await _loadNunito();
  });

  testWidgets(
    "banner shows with exact copy, group_add, size 313x64 at x 40-353, top 83, gap 16",
    (tester) async {
      await _pumpSignIn(tester, joinToken: "invite-token-abc");

      expect(find.text(S.joinInviteBanner), findsOneWidget);
      expect(find.byIcon(Icons.group_add), findsOneWidget);
      expect(find.byKey(JoinInviteBanner.bannerKey), findsOneWidget);

      final bannerRect = tester.getRect(find.byKey(JoinInviteBanner.bannerKey));
      expect(bannerRect.width, closeTo(313, 3));
      expect(bannerRect.height, closeTo(64, 3));
      expect(bannerRect.left, closeTo(40, 3));
      expect(bannerRect.right, closeTo(353, 3));
      expect(bannerRect.top, closeTo(83, 3));

      // Natural wrap only: assert line count, not where the break falls.
      final bannerText = tester.widget<Text>(find.text(S.joinInviteBanner));
      final textRect = tester.getRect(find.text(S.joinInviteBanner));
      final painter =
          TextPainter(
            text: TextSpan(text: S.joinInviteBanner, style: bannerText.style),
            textDirection: TextDirection.ltr,
            maxLines: 3,
          )..layout(maxWidth: textRect.width);
      expect(painter.computeLineMetrics().length, 2);

      final cardRect = tester.getRect(find.byType(AuthCard));
      expect(cardRect.top - bannerRect.bottom, closeTo(16, 3));

      if (runShots) {
        await _savePng(tester, "sign_in_with_banner");
      }
    },
  );

  testWidgets("banner hidden when no join token", (tester) async {
    await _pumpSignIn(tester);

    expect(find.text(S.joinInviteBanner), findsNothing);
    expect(find.byKey(JoinInviteBanner.bannerKey), findsNothing);
    expect(find.byIcon(Icons.group_add), findsNothing);

    if (runShots) {
      await _savePng(tester, "sign_in_without_banner");
    }
  });

  testWidgets("banner still shown after a failed sign-in", (tester) async {
    await _pumpSignIn(
      tester,
      joinToken: "invite-token-abc",
      error: S.errorInvalidCredentials,
    );

    expect(find.text(S.joinInviteBanner), findsOneWidget);
    expect(find.byKey(JoinInviteBanner.bannerKey), findsOneWidget);
    expect(find.text(S.errorInvalidCredentials), findsOneWidget);
  });
}
