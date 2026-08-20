import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/month_balance.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/overview/overview_summary_card.dart";

void main() {
  testWidgets("shows income spend and net", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: const Scaffold(
          body: OverviewSummaryCard(
            balance: MonthBalance(
              income: 20000000,
              electricity: 700000,
              water: 150000,
              expenses: 4000000,
            ),
          ),
        ),
      ),
    );

    expect(find.text(S.monthIncome), findsOneWidget);
    expect(find.text(S.monthSpend), findsOneWidget);
    expect(find.text(S.monthNet), findsOneWidget);
  });
}
