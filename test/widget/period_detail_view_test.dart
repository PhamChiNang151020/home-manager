import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/period_detail_view.dart";
import "package:home_manager/features/shared/status_badge.dart";

void main() {
  testWidgets("PeriodDetailView stacks fields with paid badge", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: PeriodDetailView(
            month: DateTime(2026, 8),
            amountVnd: 6830000,
            recordedAt: DateTime(2026, 8, 12, 10, 0),
            isPaid: false,
            consumptionIcon: Icons.water_drop_outlined,
            consumptionValue: "48 → 57 m³",
            note: "seed",
          ),
        ),
      ),
    );

    expect(find.text(S.month), findsOneWidget);
    expect(find.text("08/2026"), findsOneWidget);
    expect(find.text(S.consumption), findsOneWidget);
    expect(find.text("48 → 57 m³"), findsOneWidget);
    expect(find.text(S.noPhoto), findsOneWidget);
    expect(find.byType(StatusBadge), findsOneWidget);
    expect(find.text(S.unpaid), findsWidgets);
    expect(find.text("seed"), findsOneWidget);
  });
}
