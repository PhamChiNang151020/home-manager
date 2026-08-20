import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";

void main() {
  testWidgets("SignInPage shows brand logo and tagline instead of bolt icon", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: SignInPage(onGoogle: () {}),
      ),
    );

    expect(find.byType(AppBrandLogo), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsNothing);
    expect(find.text(S.appName), findsOneWidget);
    expect(find.text(S.appTagline), findsOneWidget);
    expect(find.text(S.signInGoogle), findsOneWidget);
  });
}
