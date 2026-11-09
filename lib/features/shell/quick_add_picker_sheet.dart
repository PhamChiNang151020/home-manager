import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_form.dart";
import "package:home_manager/features/electricity/electricity_form.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:home_manager/features/expenses/quick_add_sheet.dart";
import "package:home_manager/features/income/income_page.dart";
import "package:home_manager/features/personal_debts/personal_debt_forms.dart";
import "package:home_manager/features/savings/savings_forms.dart";
import "package:home_manager/features/shared/app_sheet.dart";
import "package:home_manager/features/shared/list_group.dart";
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
    // Custom 36-tall handle below matches ticket sheet y 314; Material's
    // default handle is ~48 and pushes the sheet top to ~301.
    showDragHandle: false,
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
    final (categories, members, wallets) =
        await (
          _services.expenses.listCategories(_home.id),
          _services.homes.listMembers(_home.id),
          _services.wallets.list(_home.id),
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
        wallets: wallets,
        walletService: _services.wallets,
        onSaved: _onSaved,
      );
    }
  }

  Future<void> _openIncome() async {
    final caller = widget.callerContext;
    _close();
    if (!caller.mounted) return;
    await Navigator.of(caller).push<void>(
      AppPageRoute<void>(
        page: IncomeRoutePage(home: _home, services: _services),
      ),
    );
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

  Widget _row({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    final busy = _busy == label;
    return ListGroupRow(
      key: ValueKey("quick-add-$label"),
      title: label,
      height: ListGroupRowHeight.h56,
      showDivider: showDivider,
      leading: ListGroupIcon(icon: icon),
      trailing:
          busy
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : null,
      onTap: _busy == null ? onTap : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // showAppSheet already applies useSafeArea; avoid a second SafeArea so
    // sheet top lands at design y 314 on 393×852.
    final colors = context.appColors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        // Sheet bottom = 16 content + real home-indicator (0 on web → y 348).
        AppSpacing.md + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 36,
            child: Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Text(
            S.quickAddPickTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 24 / 18,
              fontWeight: FontWeight.w700,
              fontFamily: "Nunito",
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListGroup(
            children: [
              _row(
                icon: AppIcons.expenses,
                label: S.expenses,
                onTap: () => _pick(S.expenses, _openExpense),
              ),
              _row(
                icon: AppIcons.income,
                label: S.income,
                onTap: () => _pick(S.income, _openIncome),
              ),
              _row(
                icon: AppIcons.electricity,
                label: S.electricity,
                onTap: () => _pick(S.electricity, _openElectricity),
              ),
              _row(
                icon: AppIcons.water,
                label: S.water,
                onTap: () => _pick(S.water, _openWater),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ListGroup(
            children: [
              _row(
                icon: Icons.credit_card_outlined,
                label: S.addBankAccount,
                onTap: () => _pick(S.addBankAccount, _openBankAccount),
              ),
              _row(
                icon: Icons.handshake_outlined,
                label: S.addDebt,
                onTap: () => _pick(S.addDebt, _openDebt),
              ),
              _row(
                icon: Icons.savings_outlined,
                label: S.addSavings,
                onTap: () => _pick(S.addSavings, _openSavings),
                showDivider: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
