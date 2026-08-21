import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/savings.dart";
import "package:home_manager/core/services/savings_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/savings/savings_forms.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/section_header.dart";

class SavingsRoutePage extends StatefulWidget {
  const SavingsRoutePage({
    super.key,
    required this.home,
    required this.savings,
  });

  final Home home;
  final SavingsService savings;

  @override
  State<SavingsRoutePage> createState() => _SavingsRoutePageState();
}

class _SavingsRoutePageState extends State<SavingsRoutePage> {
  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.savings,
      body: SavingsPage(home: widget.home, savings: widget.savings),
    );
  }
}

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key, required this.home, required this.savings});

  final Home home;
  final SavingsService savings;

  @override
  State<SavingsPage> createState() => SavingsPageState();
}

class SavingsPageState extends State<SavingsPage> {
  List<Savings> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SavingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.savings.list(widget.home.id);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("savings load failed", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  void openAddForm() {
    showSavingsForm(
      context: context,
      homeId: widget.home.id,
      savings: widget.savings,
      onSaved: _load,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_loading && _items.isEmpty) {
      return const LoadingView();
    }
    final deposits = _items.where((s) => s.isTermDeposit).toList();
    final goals = _items.where((s) => s.isGoal).toList();
    final colors = context.appColors;

    return ListView(
      padding: AppSpacing.shellListPadding,
      children: [
        if (_items.isEmpty)
          const EmptyStateView(message: S.noSavings)
        else ...[
          const SectionHeader(title: S.termDeposit),
          if (deposits.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Text("—"),
            )
          else
            for (final s in deposits)
              _DepositCard(
                item: s,
                colors: colors,
                onTap:
                    () => showSavingsForm(
                      context: context,
                      homeId: widget.home.id,
                      savings: widget.savings,
                      existing: s,
                      onSaved: _load,
                    ),
                onContribute:
                    () => showContributionForm(
                      context: context,
                      item: s,
                      savings: widget.savings,
                      onSaved: _load,
                    ),
              ),
          const SectionHeader(title: S.savingsGoal),
          if (goals.isEmpty)
            const Text("—")
          else
            for (final s in goals)
              _GoalCard(
                item: s,
                colors: colors,
                onTap:
                    () => showSavingsForm(
                      context: context,
                      homeId: widget.home.id,
                      savings: widget.savings,
                      existing: s,
                      onSaved: _load,
                    ),
                onContribute:
                    () => showContributionForm(
                      context: context,
                      item: s,
                      savings: widget.savings,
                      onSaved: _load,
                    ),
              ),
        ],
      ],
    );
  }
}

class _DepositCard extends StatelessWidget {
  const _DepositCard({
    required this.item,
    required this.colors,
    required this.onTap,
    required this.onContribute,
  });

  final Savings item;
  final AppColorScheme colors;
  final VoidCallback onTap;
  final VoidCallback onContribute;

  @override
  Widget build(BuildContext context) {
    String? maturityLabel;
    if (item.maturityDate != null) {
      final days = item.maturityDate!.difference(DateTime.now()).inDays;
      maturityLabel =
          days < 0 ? S.matured : S.daysToMaturity.replaceAll("{days}", "$days");
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleSmall),
            if (item.bankName != null)
              Text(item.bankName!, style: TextStyle(color: colors.textMuted)),
            const SizedBox(height: AppSpacing.xs),
            MoneyText(amount: item.currentAmount),
            if (item.interestRate != null)
              Text(
                "${S.interestRate}: ${item.interestRate}%",
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            if (maturityLabel != null)
              Text(
                maturityLabel,
                style: TextStyle(color: colors.warning, fontSize: 12),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onContribute,
                child: const Text(S.addContribution),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.item,
    required this.colors,
    required this.onTap,
    required this.onContribute,
  });

  final Savings item;
  final AppColorScheme colors;
  final VoidCallback onTap;
  final VoidCallback onContribute;

  @override
  Widget build(BuildContext context) {
    final pct = (item.progress * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MoneyText(amount: item.currentAmount),
                Text(
                  "${VndFormat.format(item.targetAmount ?? 0)} · $pct%",
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 8,
                backgroundColor: colors.bgElevated,
                color: colors.accent,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onContribute,
                child: const Text(S.addContribution),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
