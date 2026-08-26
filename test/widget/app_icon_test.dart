import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";

void main() {
  testWidgets("AppIcon renders a tinted Icon", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: const Scaffold(body: AppIcon(AppIcons.electricity, size: 28)),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, AppIcons.electricity);
    expect(icon.size, 28);
  });
}
