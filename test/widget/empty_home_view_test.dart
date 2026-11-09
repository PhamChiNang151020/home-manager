import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shell/empty_home_view.dart";

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.build(
      brightness: Brightness.light,
      accent: AppAccent.amber,
    ),
    home: Scaffold(body: MobileViewport(child: child)),
  );
}

void main() {
  testWidgets("default state shows account invite and disabled enter", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        EmptyHomeView(
          email: "nang.pham@gmail.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {},
          onAcceptToken: (_) async {},
        ),
      ),
    );

    expect(find.text(S.signedInLabel), findsOneWidget);
    expect(find.text("nang.pham@gmail.com"), findsOneWidget);
    expect(find.text(S.emptyHomeTitle), findsOneWidget);
    expect(find.text(S.receiveInvite), findsOneWidget);
    expect(find.text(S.enterHome), findsOneWidget);

    final enter = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.enterHome),
    );
    expect(enter.onPressed, isNull);
  });

  testWidgets("typing six chars enables enter and maps invalid error", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        EmptyHomeView(
          email: "a@b.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {
            throw Exception("invalid or expired invite code");
          },
          onAcceptToken: (_) async {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "k7m2qp");
    await tester.pump();

    expect(find.text("K"), findsOneWidget);
    expect(find.text("7"), findsOneWidget);
    expect(find.text("M"), findsOneWidget);
    expect(find.text("2"), findsOneWidget);
    expect(find.text("Q"), findsOneWidget);
    expect(find.text("P"), findsOneWidget);

    final enter = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.enterHome),
    );
    expect(enter.onPressed, isNotNull);

    await tester.tap(find.text(S.enterHome));
    await tester.pumpAndSettle();

    expect(find.text(S.inviteCodeInvalid), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets("lockout clears boxes and disables enter", (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        EmptyHomeView(
          email: "a@b.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {
            throw Exception("too many attempts");
          },
          onAcceptToken: (_) async {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "K7M2QP");
    await tester.pump();
    await tester.tap(find.text(S.enterHome));
    await tester.pumpAndSettle();

    expect(find.text(S.inviteCodeLocked), findsOneWidget);
    expect(find.text("K"), findsNothing);

    final enter = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.enterHome),
    );
    expect(enter.onPressed, isNull);
  });

  testWidgets("paste join url uses token path", (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    String? acceptedToken;
    await tester.pumpWidget(
      _wrap(
        EmptyHomeView(
          email: "a@b.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {
            fail("should not accept code");
          },
          onAcceptToken: (token) async {
            acceptedToken = token;
          },
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      "https://example.test/join.html?join=tokABC",
    );
    await tester.pump();

    final enter = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.enterHome),
    );
    expect(enter.onPressed, isNotNull);

    await tester.tap(find.text(S.enterHome));
    await tester.pumpAndSettle();

    expect(acceptedToken, "tokABC");
    expect(find.text(S.joinedHome), findsOneWidget);
  });
}
