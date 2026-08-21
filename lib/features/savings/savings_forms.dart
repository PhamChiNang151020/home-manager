import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/savings.dart";
import "package:home_manager/core/services/savings_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/datetime_picker.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:intl/intl.dart";

Future<void> showSavingsForm({
  required BuildContext context,
  required String homeId,
  required SavingsService savings,
  Savings? existing,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder:
        (context) => _SavingsFormSheet(
          homeId: homeId,
          savings: savings,
          existing: existing,
          onSaved: onSaved,
        ),
  );
}

class _SavingsFormSheet extends StatefulWidget {
  const _SavingsFormSheet({
    required this.homeId,
    required this.savings,
    required this.onSaved,
    this.existing,
  });

  final String homeId;
  final SavingsService savings;
  final Savings? existing;
  final VoidCallback onSaved;

  @override
  State<_SavingsFormSheet> createState() => _SavingsFormSheetState();
}

class _SavingsFormSheetState extends State<_SavingsFormSheet> {
  late String _type;
  late final TextEditingController _name;
  late final TextEditingController _bank;
  late final TextEditingController _rate;
  late final TextEditingController _term;
  late final TextEditingController _target;
  late final TextEditingController _current;
  late final TextEditingController _note;
  DateTime? _maturity;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? "goal";
    _name = TextEditingController(text: e?.name ?? "");
    _bank = TextEditingController(text: e?.bankName ?? "");
    _rate = TextEditingController(
      text: e?.interestRate == null ? "" : "${e!.interestRate}",
    );
    _term = TextEditingController(
      text: e?.termMonths == null ? "" : "${e!.termMonths}",
    );
    _target = TextEditingController(
      text: e?.targetAmount == null ? "" : VndFormat.input(e!.targetAmount!),
    );
    _current = TextEditingController(
      text: e == null ? "" : VndFormat.input(e.currentAmount),
    );
    _note = TextEditingController(text: e?.note ?? "");
    _maturity = e?.maturityDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _bank.dispose();
    _rate.dispose();
    _term.dispose();
    _target.dispose();
    _current.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = S.invalidAmount);
      return;
    }
    final current = VndFormat.parse(_current.text) ?? 0;
    final target = VndFormat.parse(_target.text);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.savings.upsert(
        homeId: widget.homeId,
        type: _type,
        name: _name.text.trim(),
        bankName:
            _type == "term_deposit" && _bank.text.trim().isNotEmpty
                ? _bank.text.trim()
                : null,
        interestRate:
            _type == "term_deposit"
                ? double.tryParse(_rate.text.trim().replaceAll(",", "."))
                : null,
        termMonths:
            _type == "term_deposit" ? int.tryParse(_term.text.trim()) : null,
        maturityDate: _type == "term_deposit" ? _maturity : null,
        targetAmount: _type == "goal" ? target : null,
        currentAmount: widget.existing?.currentAmount ?? current,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        editingId: widget.existing?.id,
      );
      if (!mounted) return;
      popWithAppToast(
        context,
        widget.existing == null ? S.toastSavingsAdded : S.toastSavingsSaved,
        then: widget.onSaved,
      );
    } catch (e) {
      setState(() {
        _error = "$e";
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isDeposit = _type == "term_deposit";
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            FormTitle(
              title: widget.existing == null ? S.addSavings : S.editSavings,
            ),
            Text(S.savingsType, style: TextStyle(color: colors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "goal", label: Text(S.savingsGoal)),
                ButtonSegment(
                  value: "term_deposit",
                  label: Text(S.termDeposit),
                ),
              ],
              selected: {_type},
              onSelectionChanged:
                  widget.existing == null
                      ? (s) => setState(() => _type = s.first)
                      : null,
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(label: S.savingsName, controller: _name),
            if (isDeposit) ...[
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(label: S.bankName, controller: _bank),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(
                label: S.interestRate,
                controller: _rate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(
                label: S.termMonths,
                controller: _term,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledPickerField(
                label: S.maturityDate,
                value:
                    _maturity == null
                        ? "—"
                        : DateFormat("dd/MM/yyyy").format(_maturity!),
                onTap: () async {
                  final picked = await showAppDatePicker(
                    context: context,
                    initialDate: _maturity ?? DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 30),
                  );
                  if (picked != null) setState(() => _maturity = picked);
                },
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledMoneyField(label: S.targetAmount, controller: _target),
            ],
            if (widget.existing == null) ...[
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledMoneyField(label: S.currentAmount, controller: _current),
            ],
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(label: S.note, controller: _note),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: TextStyle(color: colors.error)),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text(S.save),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showContributionForm({
  required BuildContext context,
  required Savings item,
  required SavingsService savings,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder:
        (context) => _ContributionFormSheet(
          item: item,
          savings: savings,
          onSaved: onSaved,
        ),
  );
}

class _ContributionFormSheet extends StatefulWidget {
  const _ContributionFormSheet({
    required this.item,
    required this.savings,
    required this.onSaved,
  });

  final Savings item;
  final SavingsService savings;
  final VoidCallback onSaved;

  @override
  State<_ContributionFormSheet> createState() => _ContributionFormSheetState();
}

class _ContributionFormSheetState extends State<_ContributionFormSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late DateTime _date;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = VndFormat.parse(_amount.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = S.invalidAmount);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.savings.addContribution(
        savingsId: widget.item.id,
        amount: amount,
        contributedDate: _date,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      popWithAppToast(context, S.toastContributionAdded, then: widget.onSaved);
    } catch (e) {
      setState(() {
        _error = "$e";
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormTitle(title: S.addContribution),
          LabeledMoneyField(label: S.amount, controller: _amount),
          const SizedBox(height: AppSpacing.formFieldGap),
          LabeledPickerField(
            label: S.expenseDate,
            value: DateFormat("dd/MM/yyyy").format(_date),
            onTap: () async {
              final picked = await showAppDatePicker(
                context: context,
                initialDate: _date,
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: AppSpacing.formFieldGap),
          LabeledTextField(label: S.note, controller: _note),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: TextStyle(color: colors.error)),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text(S.save),
          ),
        ],
      ),
    );
  }
}
