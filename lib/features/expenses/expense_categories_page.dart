import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/expenses/expense_category_sheet.dart";
import "package:home_manager/features/shared/app_refresh_indicator.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/shared/skeleton.dart";

/// Pushable page with sticky add button for owners.
class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({
    super.key,
    required this.home,
    required this.expenses,
  });

  final Home home;
  final ExpenseService expenses;

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  final _pageKey = GlobalKey<_ExpenseCategoriesBodyState>();

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.expenseCategoriesTitle,
      actionLabel: widget.home.isOwner ? S.addCategory : null,
      onAction:
          widget.home.isOwner
              ? () => _pageKey.currentState?.openAdd()
              : null,
      body: _ExpenseCategoriesBody(
        key: _pageKey,
        home: widget.home,
        expenses: widget.expenses,
      ),
    );
  }
}

class _ExpenseCategoriesBody extends StatefulWidget {
  const _ExpenseCategoriesBody({
    super.key,
    required this.home,
    required this.expenses,
  });

  final Home home;
  final ExpenseService expenses;

  @override
  State<_ExpenseCategoriesBody> createState() => _ExpenseCategoriesBodyState();
}

class _ExpenseCategoriesBodyState extends State<_ExpenseCategoriesBody> {
  List<ExpenseCategory> _items = [];
  bool _loading = true;
  bool _failed = false;

  bool get isOwner => widget.home.isOwner;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showOverlay = true}) async {
    setState(() {
      if (showOverlay) _loading = true;
      _failed = false;
    });
    try {
      final items = await widget.expenses.listCategories(widget.home.id);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load categories", error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> openAdd() async {
    final saved = await showExpenseCategorySheet(
      context: context,
      expenses: widget.expenses,
      homeId: widget.home.id,
    );
    if (saved) await _load(showOverlay: false);
  }

  Future<void> _openEdit(ExpenseCategory category) async {
    if (!isOwner) return;
    final saved = await showExpenseCategorySheet(
      context: context,
      expenses: widget.expenses,
      homeId: widget.home.id,
      existing: category,
    );
    if (saved) await _load(showOverlay: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _items.isEmpty) {
      return ListView(
        padding: AppSpacing.shellListPadding,
        children: const [
          SkeletonBox(width: 280, height: 20, borderRadius: 8),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: double.infinity, height: 338, borderRadius: 16),
        ],
      );
    }

    if (_failed && _items.isEmpty) {
      return ListView(
        padding: AppSpacing.shellListPadding,
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

    return AppRefreshIndicator(
      onRefresh: () => _load(showOverlay: false),
      child: ListView(
        padding: AppSpacing.shellListPadding,
        children: [
          Text(
            S.expenseCategoriesHint,
            style: TextStyle(
              fontFamily: AppFonts.nunito,
              fontSize: 14,
              height: 20 / 14,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListGroup(
            children: [
              for (var i = 0; i < _items.length; i++)
                _CategoryRow(
                  key: ValueKey(_items[i].id),
                  category: _items[i],
                  showDivider: i < _items.length - 1,
                  showChevron: isOwner,
                  onTap: isOwner ? () => _openEdit(_items[i]) : null,
                ),
            ],
          ),
          if (!isOwner) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.lock, size: 20, color: colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.categoriesOwnerOnly,
                    style: TextStyle(
                      fontFamily: AppFonts.nunito,
                      fontSize: 14,
                      height: 20 / 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    super.key,
    required this.category,
    required this.showDivider,
    required this.showChevron,
    this.onTap,
  });

  final ExpenseCategory category;
  final bool showDivider;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final row = SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            ListGroupIcon(
              icon: AppIcons.expenseCategory(category.iconKey),
              color: colors.categoryColor(category.colorKey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontFamily: AppFonts.nunito,
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (category.isDefault)
              Text(
                S.categoryDefault,
                style: TextStyle(
                  fontFamily: AppFonts.nunito,
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: colors.textMuted),
            ],
          ],
        ),
      ),
    );

    return Column(
      children: [
        if (onTap == null) row else InkWell(onTap: onTap, child: row),
        if (showDivider)
          Divider(height: 1, thickness: 1, indent: 64, color: colors.border),
      ],
    );
  }
}
