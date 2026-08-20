import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_motion.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/animated_money_text.dart";

void main() {
  testWidgets("AnimatedMoneyText animates toward target amount", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: const Scaffold(
          body: AnimatedMoneyText(amount: 1000000, large: true),
        ),
      ),
    );

    expect(find.textContaining("0"), findsOneWidget);

    await tester.pump(AppMotion.slow);
    await tester.pump();

    expect(find.textContaining("1.000.000"), findsOneWidget);
  });
}
