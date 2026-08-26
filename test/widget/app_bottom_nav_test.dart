import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";

void main() {
  testWidgets("adds home-indicator inset on iOS when bottom padding is zero", (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final dpr = tester.view.devicePixelRatio;
    tester.view.padding = FakeViewPadding(top: 59 * dpr);
    tester.view.viewPadding = FakeViewPadding(top: 59 * dpr);
    addTearDown(tester.view.reset);

    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(
            brightness: Brightness.dark,
            accent: AppAccent.amber,
          ),
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              tabIndex: 0,
              onTabSelected: (_) {},
              onQuickAdd: () {},
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppBottomNav));
      expect(
        size.height,
        AppSpacing.touchMin + AppSpacing.md + AppSpacing.sm + 34,
      );
      expect(find.text(S.overview), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
