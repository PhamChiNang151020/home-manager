import "package:flutter/material.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/expenses/expense_category_chart.dart";
import "package:home_manager/features/expenses/expense_category_style.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/month_stepper_field.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:intl/intl.dart";

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({
    super.key,
    required this.home,
    required this.expenses,
    required this.homesApi,
    required this.photos,
    required this.currentUserId,
  });

  final Home home;
  final ExpenseService expenses;
  final HomeService homesApi;
  final BillPhotoService photos;
  final String currentUserId;

  @override
  ExpensesPageState createState() => ExpensesPageState();
}

class ExpensesPageState extends State<ExpensesPage> {
  List<Expense> _items = [];
  List<ExpenseCategory> _categories = [];
  List<HomeMember> _members = [];
  bool _loading = true;
  String? _error;
  late DateTime _month;
  String? _filterCategoryId;
  String? _filterPaidBy;

  @override
  void initState() {
    super.initState();
    _month = currentMonth();
    _load();
  }

  @override
  void didUpdateWidget(covariant ExpensesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await widget.expenses.listCategories(widget.home.id);
      final members = await widget.homesApi.listMembers(widget.home.id);
      final items = await widget.expenses.list(
        widget.home.id,
        month: _month,
        categoryId: _filterCategoryId,
        paidBy: _filterPaidBy,
      );
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _members = members;
        _items = items;
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load expenses", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  void openAddForm() => _openForm();

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
      await widget.expenses.delete(expense.id);
      return true;
    } catch (e) {
      AppLog.e("Delete expense failed", error: e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_loading && _items.isEmpty && _categories.isEmpty) {
      return const LoadingView();
    }

    final colors = context.appColors;
    final spend = spendByCategory(_items);

    return LoadingOverlay(
      loading: _loading,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppSpacing.shellListPadding,
          children: [
            AnimatedEntrance(
              index: 0,
              child: MonthStepperField(
                month: _month,
                onChanged: (value) {
                  setState(() => _month = value);
                  _load();
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: LabeledDropdownField<String?>(
                    label: S.category,
                    value: _filterCategoryId,
                    items: [
                      SelectOption(
                        value: null,
                        builder: (_) => const Text(S.filterAll),
                      ),
                      for (final category in _categories)
                        SelectOption(
                          value: category.id,
                          builder: (_) => Text(category.name),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _filterCategoryId = value);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: LabeledDropdownField<String?>(
                    label: S.paidBy,
                    value: _filterPaidBy,
                    items: [
                      SelectOption(
                        value: null,
                        builder: (_) => const Text(S.filterAll),
                      ),
                      for (final member in _members)
                        SelectOption(
                          value: member.userId,
                          builder:
                              (_) => Text(
                                member.displayName ??
                                    member.email ??
                                    member.userId,
                              ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _filterPaidBy = value);
                      _load();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (_items.isEmpty)
              const EmptyStateView(message: S.noExpenses)
            else ...[
              AnimatedEntrance(
                index: 1,
                child: ExpenseCategoryChart(spend: spend),
              ),
              const AnimatedEntrance(
                index: 2,
                child: SectionHeader(title: S.history),
              ),
              for (var i = 0; i < _items.length; i++)
                AnimatedEntrance(
                  index: 3 + i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Builder(
                      builder: (context) {
                        final expense = _items[i];
                        final categoryColor = colors.categoryColor(
                          expense.category?.colorKey ?? "other",
                        );
                        return Dismissible(
                          key: ValueKey(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cardRadius,
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: colors.error,
                            ),
                          ),
                          confirmDismiss: (_) => _confirmDelete(expense),
                          onDismissed: (_) {
                            setState(() {
                              _items =
                                  _items
                                      .where((e) => e.id != expense.id)
                                      .toList();
                            });
                          },
                          child: AppCard(
                            onTap: () => _openForm(existing: expense),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                ExpenseCategoryIcon(
                                  iconKey:
                                      expense.category?.iconKey ?? "more_horiz",
                                  color: categoryColor,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.category?.name ?? S.category,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                      ),
                                      Text(
                                        "${DateFormat("dd/MM").format(expense.expenseDate)}"
                                        "${expense.paidByName == null ? "" : " · ${expense.paidByName}"}",
                                        style: TextStyle(
                                          color: colors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MoneyText(amount: expense.amountVnd),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
