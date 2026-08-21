import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_form.dart";
import "package:home_manager/features/electricity/electricity_form.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:home_manager/features/expenses/quick_add_sheet.dart";
import "package:home_manager/features/personal_debts/personal_debt_forms.dart";
import "package:home_manager/features/savings/savings_forms.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/water/water_form.dart";

Future<void> showQuickAddPickerSheet({
  required BuildContext context,
  required Home home,
  required AppServices services,
  required String currentUserId,
  VoidCallback? onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (sheetContext) {
      // Use the caller [context] after pop — [sheetContext] is disposed.
      Future<void> openAfterPop(Future<void> Function() open) async {
        Navigator.pop(sheetContext);
        await open();
      }

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.quickAddPickTitle,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                _PickTile(
                  iconPath: AppIcons.expenses,
                  label: S.expenses,
                  onTap:
                      () => openAfterPop(() async {
                        final categories = await services.expenses
                            .listCategories(home.id);
                        final members = await services.homes.listMembers(
                          home.id,
                        );
                        if (!context.mounted) return;
                        if (categories.isEmpty) return;
                        final openFull = await showQuickAddSheet(
                          context: context,
                          home: home,
                          expenses: services.expenses,
                          photos: services.photos,
                          categories: categories,
                          members: members,
                          currentUserId: currentUserId,
                          onSaved: onSaved ?? () {},
                        );
                        if (openFull && context.mounted) {
                          await showExpenseForm(
                            context: context,
                            home: home,
                            expenses: services.expenses,
                            photos: services.photos,
                            categories: categories,
                            members: members,
                            currentUserId: currentUserId,
                            onSaved: onSaved ?? () {},
                          );
                        }
                      }),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PickTile(
                  iconPath: AppIcons.electricity,
                  label: S.electricity,
                  onTap:
                      () => openAfterPop(() async {
                        final items = await services.electricity.list(home.id);
                        if (!context.mounted) return;
                        await showElectricityAddForm(
                          context: context,
                          home: home,
                          electricity: services.electricity,
                          photos: services.photos,
                          previousPeriod: items.isEmpty ? null : items.first,
                          existingPeriods: items,
                          onSaved: onSaved ?? () {},
                        );
                      }),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PickTile(
                  iconPath: AppIcons.water,
                  label: S.water,
                  onTap:
                      () => openAfterPop(() async {
                        final items = await services.water.list(home.id);
                        if (!context.mounted) return;
                        await showWaterAddForm(
                          context: context,
                          home: home,
                          water: services.water,
                          photos: services.photos,
                          previousPeriod: items.isEmpty ? null : items.first,
                          existingPeriods: items,
                          onSaved: onSaved ?? () {},
                        );
                      }),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PickTile(
                  icon: Icons.credit_card_outlined,
                  label: S.addBankAccount,
                  onTap:
                      () => openAfterPop(() async {
                        if (!context.mounted) return;
                        await showBankAccountForm(
                          context: context,
                          homeId: home.id,
                          bank: services.bankAccounts,
                          onSaved: onSaved ?? () {},
                        );
                      }),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PickTile(
                  icon: Icons.handshake_outlined,
                  label: S.addDebt,
                  onTap:
                      () => openAfterPop(() async {
                        if (!context.mounted) return;
                        await showPersonalDebtForm(
                          context: context,
                          homeId: home.id,
                          debts: services.personalDebts,
                          currentUserId: currentUserId,
                          onSaved: onSaved ?? () {},
                        );
                      }),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PickTile(
                  icon: Icons.savings_outlined,
                  label: S.addSavings,
                  onTap:
                      () => openAfterPop(() async {
                        if (!context.mounted) return;
                        await showSavingsForm(
                          context: context,
                          homeId: home.id,
                          savings: services.savings,
                          onSaved: onSaved ?? () {},
                        );
                      }),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.label,
    required this.onTap,
    this.iconPath,
    this.icon,
  });

  final String? iconPath;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.bgElevated,
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              if (iconPath != null)
                AppAssetIcon(iconPath!, size: 32)
              else
                Icon(icon, size: 32, color: colors.accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
