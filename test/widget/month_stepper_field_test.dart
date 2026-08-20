import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/month_stepper_field.dart";

void main() {
  testWidgets("disables next month on the current month", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: MonthStepperField(
            month: DateTime(DateTime.now().year, DateTime.now().month),
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNull);
    expect(find.text(S.month), findsOneWidget);
  });

  testWidgets("enables next month when viewing a past month", (tester) async {
    DateTime? changed;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: MonthStepperField(
            month: DateTime(2024, 1),
            onChanged: (value) => changed = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.chevron_right));
    expect(changed, DateTime(2024, 2));
  });
}
