import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/pwa_install.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/pwa/install_home_screen_banner.dart";
import "package:home_manager/features/pwa/install_home_screen_page.dart";
import "package:qr_flutter/qr_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";

Widget _app(Widget home) {
  return MaterialApp(
    theme: AppTheme.build(
      brightness: Brightness.light,
      accent: AppAccent.amber,
    ),
    home: Scaffold(body: home),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets("hides when standalone", (tester) async {
    await tester.pumpWidget(
      _app(
        const InstallHomeScreenBanner(
          surface: PwaInstallSurface.hidden,
          dismissedInitially: false,
        ),
      ),
    );

    expect(find.text(S.installBannerTitle), findsNothing);
  });

  testWidgets("shows iOS Safari steps and opens QR guide", (tester) async {
    await tester.pumpWidget(
      _app(
        const InstallHomeScreenBanner(
          surface: PwaInstallSurface.iosSafari,
          dismissedInitially: false,
        ),
      ),
    );

    expect(find.text(S.installBannerTitle), findsOneWidget);
    expect(find.text(S.installBannerIosSafari), findsOneWidget);
    expect(find.text(S.installIosWebClip), findsOneWidget);

    await tester.tap(find.text(S.installGuide));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byType(QrImageView), 200);
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text(S.installQrHint), findsOneWidget);
    expect(find.text(PwaInstall.productionAppUrl), findsNothing);
  });

  testWidgets("install page shows iOS web clip button", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: const InstallHomeScreenPage(surface: PwaInstallSurface.iosSafari),
      ),
    );

    expect(find.text(S.installIosWebClip), findsWidgets);
    expect(find.text(S.installIosWebClipSteps), findsOneWidget);
    expect(find.text(S.installIosProfileRemoveTitle), findsOneWidget);
    expect(find.text(S.installIosProfileRemoveSteps), findsOneWidget);
  });

  test("iOS QR points to mobileconfig profile", () {
    expect(
      InstallHomeScreenPage.resolveQrUrl(
        surface: PwaInstallSurface.iosSafari,
        appUrl: PwaInstall.productionAppUrl,
        iosWebClipProfileUrl: PwaInstall.productionIosWebClipProfileUrl,
      ),
      PwaInstall.productionIosWebClipProfileUrl,
    );
  });

  testWidgets("dismiss hides banner", (tester) async {
    await tester.pumpWidget(
      _app(
        const InstallHomeScreenBanner(
          surface: PwaInstallSurface.androidChrome,
          dismissedInitially: false,
        ),
      ),
    );

    await tester.tap(find.text(S.installDismiss));
    await tester.pump();

    expect(find.text(S.installBannerTitle), findsNothing);
  });

  test("non-iOS QR uses provided app link", () {
    expect(
      InstallHomeScreenPage.resolveQrUrl(
        surface: PwaInstallSurface.androidChrome,
        appUrl: "https://example.test/app/",
        iosWebClipProfileUrl: PwaInstall.productionIosWebClipProfileUrl,
      ),
      "https://example.test/app/",
    );
  });

  testWidgets("install page shows QR without printing the URL", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: const InstallHomeScreenPage(
          surface: PwaInstallSurface.iosInApp,
          shareUrl: "https://example.test/app/",
        ),
      ),
    );

    await tester.scrollUntilVisible(find.byType(QrImageView), 200);
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text("https://example.test/app/"), findsNothing);
  });
}
