import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/empty_state_view.dart";

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.build(brightness: Brightness.dark, accent: AppAccent.amber),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets("shows only the heading when nothing else is given", (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const EmptyStateView(message: "Chưa có kỳ điện")),
    );

    expect(find.text("Chưa có kỳ điện"), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets("shows the description and contextual icon", (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmptyStateView(
          message: "Chưa có kỳ điện",
          icon: Icons.electric_meter_outlined,
          description: "Bấm + để thêm kỳ đầu tiên.",
        ),
      ),
    );

    expect(find.text("Bấm + để thêm kỳ đầu tiên."), findsOneWidget);
    expect(find.byIcon(Icons.electric_meter_outlined), findsOneWidget);
  });

  testWidgets("runs the primary action when tapped", (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        EmptyStateView(
          message: "Chưa có kỳ điện",
          actionLabel: "Thêm kỳ điện",
          onAction: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text("Thêm kỳ điện"));
    expect(taps, 1);
  });
}
