import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";

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
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 42,
                    sections: [
                      for (final item in spend)
                        PieChartSectionData(
                          value: item.amountVnd,
                          color: colors.categoryColor(item.category.colorKey),
                          radius: 22,
                          title: "",
                        ),
                    ],
                  ),
                ),
                Text(
                  VndFormat.compact(total),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              for (final item in spend)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.categoryColor(item.category.colorKey),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      item.category.name,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
