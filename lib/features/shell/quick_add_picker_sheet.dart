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
import "package:home_manager/features/shared/app_sheet.dart";
import "package:home_manager/features/water/water_form.dart";

Future<void> showQuickAddPickerSheet({
  required BuildContext context,
  required Home home,
  required AppServices services,
  required String currentUserId,
  VoidCallback? onSaved,
}) {
  return showAppSheet<void>(
    context: context,
    builder:
        (sheetContext) => _QuickAddPicker(
          // The next form is shown after this sheet pops, so it needs the
          // caller's context — [sheetContext] is disposed by then.
          callerContext: context,
          home: home,
          services: services,
          currentUserId: currentUserId,
          onSaved: onSaved,
        ),
  );
}

class _QuickAddPicker extends StatefulWidget {
  const _QuickAddPicker({
    required this.callerContext,
    required this.home,
    required this.services,
    required this.currentUserId,
    required this.onSaved,
  });

  final BuildContext callerContext;
  final Home home;
  final AppServices services;
  final String currentUserId;
  final VoidCallback? onSaved;

  @override
  State<_QuickAddPicker> createState() => _QuickAddPickerState();
}

class _QuickAddPickerState extends State<_QuickAddPicker> {
  /// Label of the row currently fetching, so the wait is visible on the row
  /// the user tapped instead of behind a sheet that already closed.
  String? _busy;

  Home get _home => widget.home;
  AppServices get _services => widget.services;
  VoidCallback get _onSaved => widget.onSaved ?? () {};

  /// Fetches first and pops only once the next form is ready to show.
  Future<void> _pick(String label, Future<void> Function() open) async {
    if (_busy != null) return;
    setState(() => _busy = label);
    try {
      await open();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Closes the picker, so the next sheet slides in from a clean stack. Each
  /// caller then checks `caller.mounted` before hosting that sheet.
  void _close() {
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openExpense() async {
    // Both queries go out together — one round trip, not two.
    final (categories, members) =
        await (
          _services.expenses.listCategories(_home.id),
          _services.homes.listMembers(_home.id),
        ).wait;
    final caller = widget.callerContext;
    _close();
    if (!caller.mounted || categories.isEmpty) return;

    final openFull = await showQuickAddSheet(
      context: caller,
      home: _home,
      expenses: _services.expenses,
      photos: _services.photos,
      categories: categories,
      members: members,
      currentUserId: widget.currentUserId,
      onSaved: _onSaved,
    );
    if (openFull && caller.mounted) {
      await showExpenseForm(
        context: caller,
        home: _home,
        expenses: _services.expenses,
        photos: _services.photos,
        categories: categories,
        members: members,
        currentUserId: widget.currentUserId,
        onSaved: _onSaved,
      );
    }
  }

  Future<void> _openElectricity() async {
    final items = await _services.electricity.list(_home.id);
    final caller = widget.callerContext;
    _close();
    if (!caller.mounted) return;
    await showElectricityAddForm(
      context: caller,
      home: _home,
      electricity: _services.electricity,
      photos: _services.photos,
      previousPeriod: items.isEmpty ? null : items.first,
      existingPeriods: items,
      onSaved: _onSaved,
    );
  }

  Future<void> _openWater() async {
    final items = await _services.water.list(_home.id);
    final caller = widget.callerContext;
    _close();
    if (!caller.mounted) return;
    await showWaterAddForm(
      context: caller,
      home: _home,
      water: _services.water,
      photos: _services.photos,
      previousPeriod: items.isEmpty ? null : items.first,
      existingPeriods: items,
      onSaved: _onSaved,
    );
  }

  Future<void> _openBankAccount() async {
    final caller = widget.callerContext;
    _close();
    if (!caller.mounted) return;
    await showBankAccountForm(
      context: caller,
      homeId: _home.id,
      bank: _services.bankAccounts,
      onSaved: _onSaved,
    );
  }

  Future<void> _openDebt() async {
    final caller = widget.callerContext;
    _close();
    if (!caller.mounted) return;
    await showPersonalDebtForm(
      context: caller,
      homeId: _home.id,
      debts: _services.personalDebts,
      currentUserId: widget.currentUserId,
      onSaved: _onSaved,
    );
  }

  Future<void> _openSavings() async {
    final caller = widget.callerContext;
    _close();
    if (!caller.mounted) return;
    await showSavingsForm(
      context: caller,
      homeId: _home.id,
      savings: _services.savings,
      onSaved: _onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              _PickTile(
                iconPath: AppIcons.expenses,
                label: S.expenses,
                busy: _busy == S.expenses,
                enabled: _busy == null,
                onTap: () => _pick(S.expenses, _openExpense),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PickTile(
                iconPath: AppIcons.electricity,
                label: S.electricity,
                busy: _busy == S.electricity,
                enabled: _busy == null,
                onTap: () => _pick(S.electricity, _openElectricity),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PickTile(
                iconPath: AppIcons.water,
                label: S.water,
                busy: _busy == S.water,
                enabled: _busy == null,
                onTap: () => _pick(S.water, _openWater),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PickTile(
                icon: Icons.credit_card_outlined,
                label: S.addBankAccount,
                busy: _busy == S.addBankAccount,
                enabled: _busy == null,
                onTap: () => _pick(S.addBankAccount, _openBankAccount),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PickTile(
                icon: Icons.handshake_outlined,
                label: S.addDebt,
                busy: _busy == S.addDebt,
                enabled: _busy == null,
                onTap: () => _pick(S.addDebt, _openDebt),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PickTile(
                icon: Icons.savings_outlined,
                label: S.addSavings,
                busy: _busy == S.addSavings,
                enabled: _busy == null,
                onTap: () => _pick(S.addSavings, _openSavings),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.label,
    required this.onTap,
    required this.busy,
    required this.enabled,
    this.iconPath,
    this.icon,
  });

  final String? iconPath;
  final IconData? icon;
  final String label;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.bgElevated,
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        onTap: enabled ? onTap : null,
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
              if (busy)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                )
              else
                Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
