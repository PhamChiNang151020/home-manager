import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/settings/settings_account_page.dart";

const _home = Home(
  id: "h1",
  name: "Testing",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

void main() {
  testWidgets("account page lists Google facts and current home", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: SettingsAccountPage(onSignOut: () {}, home: _home),
      ),
    );

    expect(find.text(S.accountSignIn), findsOneWidget);
    expect(find.text(S.accountGoogle), findsOneWidget);
    expect(find.text(S.managedHome), findsOneWidget);
    expect(find.text("Testing"), findsOneWidget);
    expect(find.text(S.owner), findsOneWidget);
    expect(find.text(S.accountEmailManagedHint), findsOneWidget);
    expect(find.text(S.signOut), findsOneWidget);
  });
}
