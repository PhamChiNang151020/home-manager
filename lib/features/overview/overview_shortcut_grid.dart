import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/money_text.dart";

class OverviewShortcutGrid extends StatelessWidget {
  const OverviewShortcutGrid({
    super.key,
    required this.electricityAmount,
    required this.waterAmount,
    required this.incomeAmount,
    required this.onElectricity,
    required this.onWater,
    required this.onIncome,
  });

  final double electricityAmount;
  final double waterAmount;
  final double incomeAmount;
  final VoidCallback onElectricity;
  final VoidCallback onWater;
  final VoidCallback onIncome;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniTile(
            icon: AppIcons.electricity,
            label: S.electricity,
            amount: electricityAmount,
            onTap: onElectricity,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniTile(
            icon: AppIcons.water,
            label: S.water,
            amount: waterAmount,
            onTap: onWater,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniTile(
            icon: AppIcons.income,
            label: S.income,
            amount: incomeAmount,
            onTap: onIncome,
          ),
        ),
      ],
    );
  }
}

class _MiniTile extends StatelessWidget {
  const _MiniTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.onTap,
  });

  final String icon;
  final String label;
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          AppAssetIcon(icon, size: 28),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          MoneyText(
            amount: amount,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
