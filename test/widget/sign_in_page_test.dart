import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "../support/mock_supabase.dart";

class MockAuthService extends AuthService {
  MockAuthService() : super(MockSupabaseClient());
}

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
        // Test font (Ahem) is wider than Nunito; scale text so the 313px card fits.
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(0.8)),
              child: child!,
            ),
        home: SignInPage(authService: MockAuthService()),
      ),
    );

    expect(find.byType(AppBrandLogo), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsNothing);
    expect(find.text(S.appName), findsOneWidget);
    expect(find.text(S.appTagline), findsOneWidget);
    expect(find.text(S.signInGoogle), findsOneWidget);
  });
}
