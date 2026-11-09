import "package:flutter/material.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/income_service.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/expenses/expense_categories_page.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:home_manager/features/income/income_page.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_refresh_indicator.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:home_manager/features/shared/progress_bar.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/shared/skeleton.dart";
import "package:intl/intl.dart";

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({
    super.key,
    required this.home,
    required this.expenses,
    required this.homesApi,
    required this.photos,
    required this.currentUserId,
    required this.incomes,
    required this.services,
    this.wallets,
  });

  final Home home;
  final ExpenseService expenses;
  final HomeService homesApi;
  final BillPhotoService photos;
  final String currentUserId;
  final IncomeService incomes;
  final AppServices services;
  final WalletService? wallets;

  @override
  ExpensesPageState createState() => ExpensesPageState();
}

class ExpensesPageState extends State<ExpensesPage> {
  List<Expense> _monthItems = [];
  List<ExpenseCategory> _categories = [];
  List<HomeMember> _members = [];
  List<Wallet> _wallets = [];
  double _incomeTotal = 0;
  bool _loading = true;
  bool _failed = false;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = monthStart(today());
    _load();
  }

  @override
  void didUpdateWidget(covariant ExpensesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) {
      _load();
    }
  }

  Future<void> _refresh() => _load(showOverlay: false);

  Future<void> _load({bool showOverlay = true}) async {
    setState(() {
      if (showOverlay) _loading = true;
      _failed = false;
    });
    try {
      final walletsFuture =
          widget.wallets?.list(widget.home.id) ?? Future.value(<Wallet>[]);
      final (categories, members, items, wallets, incomes) =
          await (
            widget.expenses.listCategories(widget.home.id),
            widget.homesApi.listMembers(widget.home.id),
            widget.expenses.list(widget.home.id, month: _month),
            walletsFuture,
            widget.incomes.list(widget.home.id, month: _month),
          ).wait;
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _members = members;
        _monthItems = items;
        _wallets = wallets;
        _incomeTotal = incomes.fold<double>(0, (s, i) => s + i.amountVnd);
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load expenses", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  void _onMonthChanged(DateTime value) {
    setState(() => _month = monthStart(value));
    _load();
  }

  Future<void> _openForm({Expense? existing}) async {
    if (_categories.isEmpty) return;
    await showExpenseForm(
      context: context,
      home: widget.home,
      expenses: widget.expenses,
      photos: widget.photos,
      categories: _categories,
      members: _members,
      currentUserId: widget.currentUserId,
      wallets: _wallets,
      walletService: widget.wallets,
      existing: existing,
      onSaved: _load,
    );
  }

  Future<bool> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.deleteExpense),
            content: const Text(S.deleteExpenseConfirm),
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
    if (confirmed != true || !mounted) return false;
    try {
      final path = expense.receiptPhotoPath;
      if (path != null && path.isNotEmpty) {
        await widget.photos.remove(path);
      }
      final walletSvc = widget.wallets;
      if (walletSvc != null && expense.walletId != null) {
        await walletSvc.revertExpense(expense.id);
      }
      await widget.expenses.delete(expense.id);
      return true;
    } catch (e) {
      AppLog.e("Delete expense failed", error: e);
      return false;
    }
  }

  void _openIncome() {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: IncomeRoutePage(home: widget.home, services: widget.services),
      ),
    );
  }

  void _openCategories() {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: ExpenseCategoriesScreen(
          home: widget.home,
          expenses: widget.expenses,
        ),
      ),
    );
  }

  Map<DateTime, List<Expense>> _groupByDay() {
    final map = <DateTime, List<Expense>>{};
    for (final expense in _monthItems) {
      final day = DateTime(
        expense.expenseDate.year,
        expense.expenseDate.month,
        expense.expenseDate.day,
      );
      (map[day] ??= []).add(expense);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    // Top inset comes from TransactionsHub segmented padding (8 under seg ->
    // month at y 179). Do not add another shellListPadding.top here.
    const listPadding = EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.lg);

    if (_loading && _monthItems.isEmpty && _categories.isEmpty) {
      return ListView(
        padding: listPadding,
        children: const [
          SkeletonBox(width: double.infinity, height: 110, borderRadius: 8),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(width: 116, height: 24, borderRadius: 8),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: double.infinity, height: 254, borderRadius: 8),
        ],
      );
    }

    if (_failed && _monthItems.isEmpty && _categories.isEmpty) {
      return ListView(
        padding: listPadding,
        children: [
          ErrorView(
            message: S.loadFailedTitle,
            description: S.loadFailedHint,
            onRetry: _load,
          ),
        ],
      );
    }

    final colors = context.appColors;
    final total = totalAmount(_monthItems);
    final who = whoSpentRows(members: _members, expenses: _monthItems);
    final byDay = _groupByDay();
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    final empty = _monthItems.isEmpty;

    return AppRefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: listPadding,
        children: [
          AnimatedEntrance(
            index: 0,
            child: MonthStepper(month: _month, onChanged: _onMonthChanged),
          ),
          const SizedBox(height: AppSpacing.sm), // 8 -> summary at y 235
          AnimatedEntrance(
            index: 1,
            child: _SummaryCard(
              key: const ValueKey("expenses-summary-card"),
              month: _month.month,
              total: total,
              incomeTotal: _incomeTotal,
              onIncomeTap: _openIncome,
            ),
          ),
          if (empty) ...[
            const SizedBox(height: AppSpacing.lg),
            const AnimatedEntrance(
              index: 2,
              child: EmptyStateView(
                message: S.noExpenses,
                icon: Icons.shopping_bag_outlined,
                description: S.noExpensesHint,
              ),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.lg),
            AnimatedEntrance(
              index: 2,
              child: SectionHeader(title: S.whoSpent),
            ),
            const SizedBox(height: AppSpacing.sm),
            AnimatedEntrance(
              index: 3,
              child: _WhoSpentCard(
                key: const ValueKey("expenses-who-card"),
                rows: who,
                monthTotal: total,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedEntrance(
              index: 4,
              child: SectionHeader(
                key: const ValueKey("expenses-items-header"),
                title: S.expenseItems,
                linkLabel: "${S.category} ›",
                onLink: _openCategories,
              ),
            ),
            for (var d = 0; d < days.length; d++) ...[
              SizedBox(height: d == 0 ? AppSpacing.sm : 12),
              Text(
                key: d == 0 ? const ValueKey("expenses-day0") : null,
                DateFormat("EEEE, dd/MM", "vi").format(days[d]),
                style: TextStyle(
                  fontFamily: AppFonts.nunito,
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListGroup(
                key: d == 0 ? const ValueKey("expenses-day0-list") : null,
                children: [
                  for (var i = 0; i < byDay[days[d]]!.length; i++)
                    _ExpenseRow(
                      expense: byDay[days[d]]![i],
                      showDivider: i < byDay[days[d]]!.length - 1,
                      onTap:
                          () => _openForm(existing: byDay[days[d]]![i]),
                      onDelete: () async {
                        final expense = byDay[days[d]]![i];
                        final ok = await _confirmDelete(expense);
                        if (!ok) return false;
                        if (!context.mounted) return false;
                        setState(() {
                          _monthItems =
                              _monthItems
                                  .where((e) => e.id != expense.id)
                                  .toList();
                        });
                        showAppToast(
                          context,
                          S.toastExpenseDeleted,
                          kind: AppToastKind.destructive,
                        );
                        return true;
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    super.key,
    required this.month,
    required this.total,
    required this.incomeTotal,
    required this.onIncomeTap,
  });

  final int month;
  final double total;
  final double incomeTotal;
  final VoidCallback onIncomeTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.totalSpendMonth(month),
                  style: TextStyle(
                    fontFamily: AppFonts.nunito,
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Spec amount band 272–311 (39) for 28/36 text; full row width.
                SizedBox(
                  key: const ValueKey("expenses-summary-amount"),
                  width: double.infinity,
                  height: 39,
                  child: Text(
                    VndFormat.format(total),
                    style: TextStyle(
                      fontFamily: AppFonts.nunito,
                      fontSize: 28,
                      height: 36 / 28,
                      fontWeight: FontWeight.w800,
                      color: colors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: colors.border),
          InkWell(
            key: const ValueKey("expenses-income-row"),
            onTap: onIncomeTap,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.incomeMonthLabel(month),
                        style: TextStyle(
                          fontFamily: AppFonts.nunito,
                          fontSize: 14,
                          height: 20 / 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      incomeTotal > 0
                          ? VndFormat.format(incomeTotal)
                          : S.incomeNone,
                      style: TextStyle(
                        fontFamily: AppFonts.nunito,
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w700,
                        color:
                            incomeTotal > 0
                                ? colors.success
                                : colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhoSpentCard extends StatelessWidget {
  const _WhoSpentCard({
    super.key,
    required this.rows,
    required this.monthTotal,
  });

  final List<WhoSpentRow> rows;
  final double monthTotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListGroup(
      children: [
        for (var i = 0; i < rows.length; i++)
          _WhoSpentRow(
            key: ValueKey("who-row-$i"),
            row: rows[i],
            ratio: monthTotal <= 0 ? 0 : rows[i].amountVnd / monthTotal,
            showDivider: i < rows.length - 1,
            colors: colors,
          ),
      ],
    );
  }
}

class _WhoSpentRow extends StatelessWidget {
  const _WhoSpentRow({
    super.key,
    required this.row,
    required this.ratio,
    required this.showDivider,
    required this.colors,
  });

  final WhoSpentRow row;
  final double ratio;
  final bool showDivider;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final initial =
        row.name.isNotEmpty ? row.name.characters.first.toUpperCase() : "?";
    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accent.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: AppFonts.nunito,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              row.name,
                              style: TextStyle(
                                fontFamily: AppFonts.nunito,
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            VndFormat.format(row.amountVnd),
                            style: TextStyle(
                              fontFamily: AppFonts.nunito,
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ProgressBar(
                        key: ValueKey("who-bar-${row.userId}"),
                        value: ratio,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, indent: 64, color: colors.border),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.expense,
    required this.showDivider,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final bool showDivider;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final categoryColor = colors.categoryColor(
      expense.category?.colorKey ?? "other",
    );
    final note = expense.note?.trim();
    final payer = expense.paidByName ?? "";
    final subtitle = [
      if (payer.isNotEmpty) payer,
      if (note != null && note.isNotEmpty) note,
    ].join(" · ");

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: colors.error.withValues(alpha: 0.18),
        child: Icon(Icons.delete_outline, color: colors.error),
      ),
      child: ListGroupRow(
        title: expense.category?.name ?? S.category,
        subtitle: subtitle.isEmpty ? null : subtitle,
        height: ListGroupRowHeight.h56,
        showDivider: showDivider,
        leading: ListGroupIcon(
          icon: AppIcons.expenseCategory(
            expense.category?.iconKey ?? "more_horiz",
          ),
          color: categoryColor,
        ),
        trailing: Text(
          VndFormat.format(expense.amountVnd),
          style: TextStyle(
            fontFamily: AppFonts.nunito,
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
