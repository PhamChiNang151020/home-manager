import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_balance.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/trend_chip.dart";

class OverviewSummaryCard extends StatelessWidget {
  const OverviewSummaryCard({
    super.key,
    required this.balance,
    this.spendDeltaPercent,
  });

  final MonthBalance balance;
  final double? spendDeltaPercent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      child: Column(
        children: [
          _Row(
            label: S.monthIncome,
            amount: balance.income,
            color: colors.success,
          ),
          _Row(
            label: S.monthSpend,
            amount: balance.totalOut,
            color: colors.error,
            trailing:
                spendDeltaPercent == null
                    ? null
                    : TrendChip(percent: spendDeltaPercent!),
          ),
          const Divider(),
          _Row(
            label: S.monthNet,
            amount: balance.net,
            color: balance.net >= 0 ? colors.success : colors.error,
            large: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.amount,
    required this.color,
    this.large = false,
    this.trailing,
  });

  final String label;
  final double amount;
  final Color color;
  final bool large;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: large ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Row(
            children: [
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: AppSpacing.sm),
              ],
              MoneyText(
                amount: amount,
                large: large,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: large ? 22 : 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
