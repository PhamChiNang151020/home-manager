import "package:flutter/material.dart";
import "package:home_manager/core/domain/bank_brand.dart";
import "package:home_manager/core/domain/net_worth.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/personal_debt.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_page.dart";
import "package:home_manager/features/personal_debts/personal_debts_page.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/bank_logo.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/wallet/wallet_forms.dart";
import "package:intl/intl.dart";

class WalletRoutePage extends StatelessWidget {
  const WalletRoutePage({
    super.key,
    required this.home,
    required this.services,
    required this.currentUserId,
  });

  final Home home;
  final AppServices services;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.wallet,
      body: WalletHubPage(
        home: home,
        services: services,
        currentUserId: currentUserId,
      ),
    );
  }
}

class WalletHubPage extends StatefulWidget {
  const WalletHubPage({
    super.key,
    required this.home,
    required this.services,
    required this.currentUserId,
    this.embedded = false,
  });

  final Home home;
  final AppServices services;
  final String currentUserId;

  /// When true (transactions hub), omit outer scaffold chrome.
  final bool embedded;

  @override
  State<WalletHubPage> createState() => WalletHubPageState();
}

class WalletHubPageState extends State<WalletHubPage> {
  List<Wallet> _wallets = [];
  List<BankAccount> _banks = [];
  final Map<String, double> _bankUsed = {};
  List<PersonalDebt> _debts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant WalletHubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final wallets = await widget.services.wallets.list(widget.home.id);
      final banks = await widget.services.bankAccounts.listAccounts(
        widget.home.id,
      );
      final used = <String, double>{};
      for (final b in banks) {
        final p = await widget.services.bankAccounts.latestPeriod(b.id);
        used[b.id] = p?.balanceUsed ?? 0;
      }
      final debts = await widget.services.personalDebts.list(widget.home.id);
      if (!mounted) return;
      setState(() {
        _wallets = wallets;
        _banks = banks;
        _bankUsed
          ..clear()
          ..addAll(used);
        _debts = debts;
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("wallet hub load failed", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  void openAddForm() {
    showWalletForm(
      context: context,
      homeId: widget.home.id,
      wallets: widget.services.wallets,
      onSaved: _load,
    );
  }

  Future<void> _openDetail(Wallet wallet) async {
    await Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: WalletDetailPage(
          home: widget.home,
          wallet: wallet,
          allWallets: _wallets,
          wallets: widget.services.wallets,
        ),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_loading && _wallets.isEmpty && _banks.isEmpty) {
      return const LoadingView();
    }

    final colors = context.appColors;
    final total = sumAmounts(_wallets.map((w) => w.balanceVnd));
    final openDebts = _debts.where((d) => !d.isSettled).toList();
    final iOwe = sumAmounts(
      openDebts.where((d) => d.iOwe).map((d) => d.remainingAmount),
    );
    final owedToMe = sumAmounts(
      openDebts.where((d) => !d.iOwe).map((d) => d.remainingAmount),
    );

    final body = ListView(
      padding: AppSpacing.shellListPadding,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.walletTotal,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xs),
              MoneyText(
                amount: total,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: SectionHeader(title: S.wallet)),
            TextButton.icon(
              onPressed: openAddForm,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(S.addWallet),
            ),
          ],
        ),
        if (_wallets.isEmpty)
          const EmptyStateView(
            message: S.noWallets,
            icon: Icons.account_balance_wallet_outlined,
          )
        else
          for (final w in _wallets)
            AppCard(
              onTap: () => _openDetail(w),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _WalletLeading(wallet: w),
                title: Text(w.name),
                subtitle: Text(_kindLabel(w.kind)),
                trailing: MoneyText(amount: w.balanceVnd),
              ),
            ),
        SectionHeader(title: S.walletSectionCredit),
        if (_banks.isEmpty)
          Text(
            S.noBankAccounts,
            style: TextStyle(color: colors.textMuted),
          )
        else
          for (final b in _banks.take(3))
            AppCard(
              onTap: () {
                Navigator.push<void>(
                  context,
                  AppPageRoute<void>(
                    page: BankCreditRoutePage(
                      home: widget.home,
                      bank: widget.services.bankAccounts,
                    ),
                  ),
                ).then((_) => _load());
              },
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: BankLogo(bankName: b.bankName, size: 36),
                title: Text(b.bankName),
                subtitle: Text(
                  "${S.balanceUsed}: ${VndFormat.compact(_bankUsed[b.id] ?? 0)}",
                ),
                trailing: Text(VndFormat.compact(b.creditLimit)),
              ),
            ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push<void>(
                context,
                AppPageRoute<void>(
                  page: BankCreditRoutePage(
                    home: widget.home,
                    bank: widget.services.bankAccounts,
                  ),
                ),
              ).then((_) => _load());
            },
            child: const Text(S.walletSeeAll),
          ),
        ),
        SectionHeader(title: S.walletSectionDebts),
        AppCard(
          onTap: () {
            Navigator.push<void>(
              context,
              AppPageRoute<void>(
                page: PersonalDebtsRoutePage(
                  home: widget.home,
                  debts: widget.services.personalDebts,
                  currentUserId: widget.currentUserId,
                ),
              ),
            ).then((_) => _load());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${S.iOwe}: ${VndFormat.compact(iOwe)}"),
              const SizedBox(height: AppSpacing.xs),
              Text("${S.owedToMe}: ${VndFormat.compact(owedToMe)}"),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  S.walletSeeAll,
                  style: TextStyle(color: colors.accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return body;
  }

  static String _kindLabel(WalletKind kind) {
    return switch (kind) {
      WalletKind.cash => S.walletCash,
      WalletKind.bank => S.walletBank,
      WalletKind.ewallet => S.walletEwallet,
    };
  }
}

class _WalletLeading extends StatelessWidget {
  const _WalletLeading({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    if (wallet.kind == WalletKind.bank &&
        (wallet.bankName?.isNotEmpty ?? false)) {
      return BankLogo(bankName: wallet.bankName!, size: 36);
    }
    final icon = switch (wallet.kind) {
      WalletKind.cash => Icons.payments_outlined,
      WalletKind.bank => Icons.account_balance_outlined,
      WalletKind.ewallet => Icons.smartphone_outlined,
    };
    return CircleAvatar(
      backgroundColor: context.appColors.accent.withValues(alpha: 0.15),
      child: Icon(icon, color: context.appColors.accent, size: 20),
    );
  }
}

class WalletDetailPage extends StatefulWidget {
  const WalletDetailPage({
    super.key,
    required this.home,
    required this.wallet,
    required this.allWallets,
    required this.wallets,
  });

  final Home home;
  final Wallet wallet;
  final List<Wallet> allWallets;
  final WalletService wallets;

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  late Wallet _wallet;
  List<WalletTransaction> _txns = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _wallet = widget.wallet;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.wallets.list(widget.home.id);
      final current = list.firstWhere(
        (w) => w.id == _wallet.id,
        orElse: () => _wallet,
      );
      final txns = await widget.wallets.listTransactions(_wallet.id);
      if (!mounted) return;
      setState(() {
        _wallet = current;
        _txns = txns;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.deleteWallet),
            content: const Text(S.deleteWalletConfirm),
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
    if (ok != true || !mounted) return;
    await widget.wallets.delete(_wallet.id);
    if (!mounted) return;
    showAppToast(context, S.toastWalletDeleted, kind: AppToastKind.destructive);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FeaturePageScaffold(
      title: _wallet.name,
      body:
          _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _loading && _txns.isEmpty
              ? const LoadingView()
              : ListView(
                padding: AppSpacing.shellListPadding,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.walletBalance,
                          style: TextStyle(color: colors.textMuted),
                        ),
                        MoneyText(
                          amount: _wallet.balanceVnd,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_wallet.bankName != null &&
                            BankBrand.logoUrlForName(_wallet.bankName!) !=
                                null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(_wallet.bankName!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              () => showWalletAdjustSheet(
                                context: context,
                                wallet: _wallet,
                                wallets: widget.wallets,
                                onSaved: _load,
                              ),
                          child: const Text(S.walletAdjust),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              widget.allWallets.length < 2
                                  ? null
                                  : () => showWalletTransferSheet(
                                    context: context,
                                    allWallets: widget.allWallets,
                                    from: _wallet,
                                    wallets: widget.wallets,
                                    onSaved: _load,
                                  ),
                          child: const Text(S.walletTransfer),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed:
                            () => showWalletForm(
                              context: context,
                              homeId: widget.home.id,
                              wallets: widget.wallets,
                              existing: _wallet,
                              onSaved: _load,
                            ),
                        child: const Text(S.editWallet),
                      ),
                      TextButton(
                        onPressed: _delete,
                        child: Text(
                          S.deleteWallet,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ],
                  ),
                  const SectionHeader(title: S.walletHistory),
                  if (_txns.isEmpty)
                    const EmptyStateView(message: S.noWalletTxns)
                  else
                    for (final t in _txns)
                      AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_txnLabel(t.kind)),
                          subtitle: Text(
                            [
                              if (t.note != null && t.note!.isNotEmpty) t.note!,
                              DateFormat("dd/MM/yyyy HH:mm").format(
                                t.createdAt.toLocal(),
                              ),
                            ].join(" · "),
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            VndFormat.format(t.signedAmount),
                            style: TextStyle(
                              color:
                                  t.signedAmount >= 0
                                      ? colors.success
                                      : colors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
    );
  }

  static String _txnLabel(WalletTxnKind kind) {
    return switch (kind) {
      WalletTxnKind.adjust => S.walletTxnAdjust,
      WalletTxnKind.expense => S.walletTxnExpense,
      WalletTxnKind.transferOut => S.walletTxnTransferOut,
      WalletTxnKind.transferIn => S.walletTxnTransferIn,
    };
  }
}
