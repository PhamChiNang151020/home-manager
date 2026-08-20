import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/skeleton.dart";

void main() {
  testWidgets("SkeletonBox renders shimmer container", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: const Scaffold(
          body: SkeletonBox(width: 120, height: 16),
        ),
      ),
    );

    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.byType(SkeletonBox), findsOneWidget);
  });
}
