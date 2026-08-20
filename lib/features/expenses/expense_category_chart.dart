import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/expenses/expense_category_style.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/money_text.dart";

class ExpenseCategoryChart extends StatelessWidget {
  const ExpenseCategoryChart({super.key, required this.spend});

  final List<CategorySpend> spend;

  @override
  Widget build(BuildContext context) {
    if (spend.isEmpty) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;
    final total = spend.fold<double>(0, (sum, item) => sum + item.amountVnd);
    if (total <= 0) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.spendByCategory,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  for (final item in spend)
                    PieChartSectionData(
                      value: item.amountVnd,
                      color: colors.categoryColor(item.category.colorKey),
                      radius: 28,
                      title: "",
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in spend)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  ExpenseCategoryIcon(
                    iconKey: item.category.iconKey,
                    size: 18,
                    color: colors.categoryColor(item.category.colorKey),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(item.category.name)),
                  MoneyText(amount: item.amountVnd),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    "${((item.amountVnd / total) * 100).round()}%",
                    style: TextStyle(color: colors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          const Divider(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.amount, style: TextStyle(color: colors.textSecondary)),
              MoneyText(amount: total),
            ],
          ),
          const SizedBox(height: 0),
          Text(
            VndFormat.compact(total),
            style: TextStyle(color: colors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
