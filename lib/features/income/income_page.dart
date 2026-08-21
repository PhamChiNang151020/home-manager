import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_balance.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/income.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/month_stepper_field.dart";
import "package:home_manager/features/shared/section_header.dart";

class IncomeRoutePage extends StatelessWidget {
  const IncomeRoutePage({
    super.key,
    required this.home,
    required this.services,
  });

  final Home home;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.income,
      titleIcon: AppIcons.income,
      body: IncomePage(home: home, services: services),
    );
  }
}

class IncomePage extends StatefulWidget {
  const IncomePage({super.key, required this.home, required this.services});

  final Home home;
  final AppServices services;

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  late DateTime _month;
  List<HomeMember> _members = [];
  final Map<String, TextEditingController> _amounts = {};
  MonthBalance? _balance;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _month = currentMonth();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _amounts.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final members = await widget.services.homes.listMembers(widget.home.id);
      final incomes = await widget.services.incomes.list(
        widget.home.id,
        month: _month,
      );
      final electricity = await widget.services.electricity.list(
        widget.home.id,
      );
      final water = await widget.services.water.list(widget.home.id);
      final expenses = await widget.services.expenses.list(
        widget.home.id,
        month: _month,
      );

      final incomeByUser = <String, Income>{
        for (final item in incomes) item.userId: item,
      };

      for (final controller in _amounts.values) {
        controller.dispose();
      }
      _amounts.clear();
      for (final member in members) {
        final existing = incomeByUser[member.userId];
        _amounts[member.userId] = TextEditingController(
          text:
              existing == null || existing.amountVnd == 0
                  ? ""
                  : VndFormat.input(existing.amountVnd),
        );
      }

      final elecMonth = electricity
          .where(
            (p) =>
                p.periodMonth.year == _month.year &&
                p.periodMonth.month == _month.month,
          )
          .fold<double>(0, (sum, p) => sum + p.amountVnd);
      final waterMonth = water
          .where(
            (p) =>
                p.periodMonth.year == _month.year &&
                p.periodMonth.month == _month.month,
          )
          .fold<double>(0, (sum, p) => sum + p.amountVnd);

      if (!mounted) return;
      setState(() {
        _members = members;
        _balance = computeMonthBalance(
          income: incomes.fold<double>(0, (sum, item) => sum + item.amountVnd),
          electricity: elecMonth,
          water: waterMonth,
          expenses: expenses.fold<double>(
            0,
            (sum, item) => sum + item.amountVnd,
          ),
        );
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load incomes", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      for (final member in _members) {
        final amount =
            VndFormat.parse(_amounts[member.userId]?.text ?? "") ?? 0;
        await widget.services.incomes.upsert(
          homeId: widget.home.id,
          userId: member.userId,
          incomeMonth: _month,
          amountVnd: amount,
          source: S.salary,
        );
      }
      await _load();
      if (mounted) showAppToast(context, S.toastIncomeSaved);
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_loading && _members.isEmpty) {
      return const LoadingOverlay(loading: true, child: SizedBox.expand());
    }

    final colors = context.appColors;
    final balance = _balance;

    return LoadingOverlay(
      loading: _loading || _saving,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          MonthStepperField(
            month: _month,
            onChanged: (value) {
              setState(() => _month = value);
              _load();
            },
          ),
          if (balance != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                children: [
                  _BalanceRow(
                    label: S.monthIncome,
                    amount: balance.income,
                    color: colors.success,
                  ),
                  _BalanceRow(
                    label: S.electricity,
                    amount: -balance.electricity,
                    color: colors.textPrimary,
                  ),
                  _BalanceRow(
                    label: S.water,
                    amount: -balance.water,
                    color: colors.textPrimary,
                  ),
                  _BalanceRow(
                    label: S.expenses,
                    amount: -balance.expenses,
                    color: colors.textPrimary,
                  ),
                  const Divider(),
                  _BalanceRow(
                    label: S.monthNet,
                    amount: balance.net,
                    color: balance.net >= 0 ? colors.success : colors.error,
                    bold: true,
                  ),
                ],
              ),
            ),
          ],
          const SectionHeader(title: S.salary),
          if (_members.isEmpty)
            Text(S.noIncome, style: TextStyle(color: colors.textMuted))
          else
            for (final member in _members) ...[
              LabeledMoneyField(
                label: member.displayName ?? member.email ?? member.userId,
                controller: _amounts[member.userId]!,
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
            ],
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text(S.addIncome),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.label,
    required this.amount,
    required this.color,
    this.bold = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          MoneyText(
            amount: amount,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
