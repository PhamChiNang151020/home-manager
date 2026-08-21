import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/bank_account_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_card.dart";
import "package:home_manager/features/bank_credit/bank_credit_form.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/loading_view.dart";

class BankCreditPage extends StatefulWidget {
  const BankCreditPage({super.key, required this.home, required this.bank});

  final Home home;
  final BankAccountService bank;

  @override
  State<BankCreditPage> createState() => BankCreditPageState();
}

class BankCreditPageState extends State<BankCreditPage> {
  List<BankAccount> _accounts = [];
  final Map<String, BankAccountPeriod?> _latest = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant BankCreditPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final accounts = await widget.bank.listAccounts(widget.home.id);
      final latest = <String, BankAccountPeriod?>{};
      for (final a in accounts) {
        latest[a.id] = await widget.bank.latestPeriod(a.id);
      }
      if (!mounted) return;
      setState(() {
        _accounts = accounts;
        _latest
          ..clear()
          ..addAll(latest);
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("bank credit load failed", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  void openAddAccount() {
    showBankAccountForm(
      context: context,
      homeId: widget.home.id,
      bank: widget.bank,
      onSaved: _load,
    );
  }

  Future<bool> _confirmDelete(BankAccount account) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.deleteBankAccount),
            content: const Text(S.deleteBankAccountConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(S.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(S.delete),
              ),
            ],
          ),
    );
    if (ok != true || !mounted) return false;
    try {
      await widget.bank.deleteAccount(account.id);
      return true;
    } catch (e, st) {
      AppLog.e("bank credit delete failed", error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_loading && _accounts.isEmpty) {
      return const LoadingView();
    }
    final colors = context.appColors;
    final dismissRadius = BorderRadius.circular(AppSpacing.cardRadius + 4);
    return ListView.builder(
      padding: AppSpacing.shellListPadding,
      itemCount: _accounts.isEmpty ? 1 : _accounts.length,
      itemBuilder: (context, i) {
        if (_accounts.isEmpty) {
          return const EmptyStateView(message: S.noBankAccounts);
        }
        final account = _accounts[i];
        final period = _latest[account.id];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Dismissible(
            key: ValueKey(account.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.18),
                borderRadius: dismissRadius,
              ),
              child: Icon(Icons.delete_outline, color: colors.error),
            ),
            confirmDismiss: (_) => _confirmDelete(account),
            onDismissed: (_) {
              setState(() {
                _accounts = _accounts.where((a) => a.id != account.id).toList();
                _latest.remove(account.id);
              });
            },
            child: BankCreditCard(
              account: account,
              period: period,
              onTap:
                  () => showBankAccountForm(
                    context: context,
                    homeId: widget.home.id,
                    bank: widget.bank,
                    existing: account,
                    onSaved: _load,
                  ),
              onEditPeriod:
                  () => showBankPeriodForm(
                    context: context,
                    account: account,
                    bank: widget.bank,
                    existing: period,
                    onSaved: _load,
                  ),
            ),
          ),
        );
      },
    );
  }
}

class BankCreditRoutePage extends StatefulWidget {
  const BankCreditRoutePage({
    super.key,
    required this.home,
    required this.bank,
  });

  final Home home;
  final BankAccountService bank;

  @override
  State<BankCreditRoutePage> createState() => _BankCreditRoutePageState();
}

class _BankCreditRoutePageState extends State<BankCreditRoutePage> {
  final _pageKey = GlobalKey<BankCreditPageState>();

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.bankCredit,
      actionLabel: S.addBankAccount,
      onAction: () => _pageKey.currentState?.openAddAccount(),
      body: BankCreditPage(key: _pageKey, home: widget.home, bank: widget.bank),
    );
  }
}
