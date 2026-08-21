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
        Material(
          color: colors.bgBase,
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
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
              SavingsPage(
                home: widget.home,
                savings: widget.services.savings,
              ),
            ],
          ),
        ),
      ],
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
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
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
