import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_page.dart";
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/personal_debts/personal_debts_page.dart";
import "package:home_manager/features/savings/savings_page.dart";
import "package:home_manager/features/water/water_page.dart";

class TransactionsHubPage extends StatefulWidget {
  const TransactionsHubPage({
    super.key,
    required this.home,
    required this.services,
    required this.currentUserId,
  });

  final Home home;
  final AppServices services;
  final String currentUserId;

  @override
  State<TransactionsHubPage> createState() => _TransactionsHubPageState();
}

class _TransactionsHubPageState extends State<TransactionsHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _utilitySegment = 0;
  int _creditSegment = 0;

  /// The four labels never fit a phone width, so each edge fades only while
  /// there is really something scrolled past it.
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  bool _onTabScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.horizontal) return false;
    final left = metrics.extentBefore > 1;
    final right = metrics.extentAfter > 1;
    if (left != _canScrollLeft || right != _canScrollRight) {
      setState(() {
        _canScrollLeft = left;
        _canScrollRight = right;
      });
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onTabScroll,
              child: Material(
                color: colors.bgBase,
                child: TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  // Material's scrollable default is startOffset, which
                  // indents the first tab 52px past everything else.
                  tabAlignment: TabAlignment.start,
                  labelColor: colors.accent,
                  unselectedLabelColor: colors.textMuted,
                  indicatorColor: colors.accent,
                  tabs: const [
                    Tab(text: S.tabUtilities),
                    Tab(text: S.tabDaily),
                    Tab(text: S.tabCreditDebt),
                    Tab(text: S.tabSavings),
                  ],
                ),
              ),
            ),
            _TabEdgeFade(visible: _canScrollLeft, trailing: false),
            _TabEdgeFade(visible: _canScrollRight, trailing: true),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _SegmentedHost(
                labels: const [S.electricity, S.water],
                index: _utilitySegment,
                onChanged: (i) => setState(() => _utilitySegment = i),
                child:
                    _utilitySegment == 0
                        ? ElectricityPage(
                          home: widget.home,
                          electricity: widget.services.electricity,
                          photos: widget.services.photos,
                        )
                        : WaterPage(
                          home: widget.home,
                          water: widget.services.water,
                          photos: widget.services.photos,
                        ),
              ),
              ExpensesPage(
                home: widget.home,
                expenses: widget.services.expenses,
                homesApi: widget.services.homes,
                photos: widget.services.photos,
                currentUserId: widget.currentUserId,
              ),
              _SegmentedHost(
                labels: const [S.bankCredit, S.personalDebts],
                index: _creditSegment,
                onChanged: (i) => setState(() => _creditSegment = i),
                child:
                    _creditSegment == 0
                        ? BankCreditPage(
                          home: widget.home,
                          bank: widget.services.bankAccounts,
                        )
                        : PersonalDebtsPage(
                          home: widget.home,
                          debts: widget.services.personalDebts,
                          currentUserId: widget.currentUserId,
                        ),
              ),
              SavingsPage(home: widget.home, savings: widget.services.savings),
            ],
          ),
        ),
      ],
    );
  }
}

/// Softens whichever edge of the tab strip has labels scrolled past it.
class _TabEdgeFade extends StatelessWidget {
  const _TabEdgeFade({required this.visible, required this.trailing});

  final bool visible;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    final base = context.appColors.bgBase;
    return Positioned(
      top: 0,
      bottom: 0,
      left: trailing ? null : 0,
      right: trailing ? 0 : null,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: AppSpacing.lg,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: trailing ? Alignment.centerLeft : Alignment.centerRight,
                end: trailing ? Alignment.centerRight : Alignment.centerLeft,
                colors: [base.withValues(alpha: 0), base],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentedHost extends StatelessWidget {
  const _SegmentedHost({
    required this.labels,
    required this.index,
    required this.onChanged,
    required this.child,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Stretch so the control lines up with the page content instead of
      // sitting centred at its intrinsic width.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: SegmentedButton<int>(
            segments: [
              for (var i = 0; i < labels.length; i++)
                ButtonSegment(value: i, label: Text(labels[i])),
            ],
            selected: {index},
            onSelectionChanged: (set) => onChanged(set.first),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
