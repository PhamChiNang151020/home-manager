import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "package:home_manager/features/shared/app_loading.dart";

void main() {
  testWidgets("LoadingOverlay shows loader when loading", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: SizedBox.expand(
            child: LoadingOverlay(loading: true, child: Text("content")),
          ),
        ),
      ),
    );

    expect(find.text("content"), findsOneWidget);
    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.byType(AppBrandLogo), findsOneWidget);
    expect(tester.widget<AppLoader>(find.byType(AppLoader)).size, 88);
  });

  testWidgets("LoadingOverlay hides loader when not loading", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: SizedBox.expand(
            child: LoadingOverlay(loading: false, child: Text("content")),
          ),
        ),
      ),
    );

    expect(find.text("content"), findsOneWidget);
    expect(find.byType(AppLoader), findsNothing);
  });

  testWidgets("BrandedLoadingScreen shows logo spinner and tagline", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: const BrandedLoadingScreen(),
      ),
    );

    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.byType(AppBrandLogo), findsOneWidget);
    expect(find.text(S.appName), findsOneWidget);
    expect(find.text(S.appTagline), findsOneWidget);
  });

  testWidgets("LoadingScreen delegates to BrandedLoadingScreen", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: const LoadingScreen(),
      ),
    );

    expect(find.byType(BrandedLoadingScreen), findsOneWidget);
  });
}
