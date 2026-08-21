import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/personal_debt.dart";
import "package:home_manager/core/services/personal_debt_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/personal_debts/personal_debt_forms.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/shared/status_badge.dart";
import "package:intl/intl.dart";

class PersonalDebtsRoutePage extends StatefulWidget {
  const PersonalDebtsRoutePage({
    super.key,
    required this.home,
    required this.debts,
    required this.currentUserId,
  });

  final Home home;
  final PersonalDebtService debts;
  final String currentUserId;

  @override
  State<PersonalDebtsRoutePage> createState() => _PersonalDebtsRoutePageState();
}

class _PersonalDebtsRoutePageState extends State<PersonalDebtsRoutePage> {
  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.personalDebts,
      body: PersonalDebtsPage(
        home: widget.home,
        debts: widget.debts,
        currentUserId: widget.currentUserId,
      ),
    );
  }
}

class PersonalDebtsPage extends StatefulWidget {
  const PersonalDebtsPage({
    super.key,
    required this.home,
    required this.debts,
    required this.currentUserId,
  });

  final Home home;
  final PersonalDebtService debts;
  final String currentUserId;

  @override
  State<PersonalDebtsPage> createState() => PersonalDebtsPageState();
}

class PersonalDebtsPageState extends State<PersonalDebtsPage> {
  List<PersonalDebt> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PersonalDebtsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.debts.list(widget.home.id);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("personal debts load failed", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  void openAddForm() {
    showPersonalDebtForm(
      context: context,
      homeId: widget.home.id,
      debts: widget.debts,
      currentUserId: widget.currentUserId,
      onSaved: _load,
    );
  }

  void _openDetail(PersonalDebt debt) {
    showPersonalDebtDetail(
      context: context,
      debt: debt,
      debts: widget.debts,
      onChanged: _load,
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
    final iOwe = _items.where((d) => d.iOwe).toList();
    final owed = _items.where((d) => !d.iOwe).toList();
    return ListView(
      padding: AppSpacing.shellListPadding,
      children: [
        if (_items.isEmpty)
          const EmptyStateView(message: S.noDebts)
        else ...[
          const SectionHeader(title: S.iOwe),
          if (iOwe.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Text("—"),
            )
          else
            for (final d in iOwe)
              _DebtTile(debt: d, onOpen: () => _openDetail(d)),
          const SectionHeader(title: S.owedToMe),
          if (owed.isEmpty)
            const Text("—")
          else
            for (final d in owed)
              _DebtTile(debt: d, onOpen: () => _openDetail(d)),
        ],
      ],
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({required this.debt, required this.onOpen});

  final PersonalDebt debt;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final secondaryStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.textMuted,
      fontSize: 12,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onOpen,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.counterpartyName,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: VndFormat.format(debt.remainingAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: " / ${VndFormat.format(debt.principalAmount)}",
                          style: secondaryStyle,
                        ),
                        if (debt.dueDate != null)
                          TextSpan(
                            text:
                                " · ${DateFormat("dd/MM/yyyy").format(debt.dueDate!)}",
                            style: secondaryStyle,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: debt.isSettled ? S.settled : S.openDebt,
              variant:
                  debt.isSettled
                      ? StatusBadgeVariant.success
                      : StatusBadgeVariant.warning,
            ),
          ],
        ),
      ),
    );
  }
}
