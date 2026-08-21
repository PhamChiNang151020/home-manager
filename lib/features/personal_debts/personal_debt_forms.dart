import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/personal_debt.dart";
import "package:home_manager/core/services/personal_debt_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/datetime_picker.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:intl/intl.dart";

Future<void> showPersonalDebtForm({
  required BuildContext context,
  required String homeId,
  required PersonalDebtService debts,
  required String currentUserId,
  PersonalDebt? existing,
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
        (context) => _DebtFormSheet(
          homeId: homeId,
          debts: debts,
          currentUserId: currentUserId,
          existing: existing,
          onSaved: onSaved,
        ),
  );
}

class _DebtFormSheet extends StatefulWidget {
  const _DebtFormSheet({
    required this.homeId,
    required this.debts,
    required this.currentUserId,
    required this.onSaved,
    this.existing,
  });

  final String homeId;
  final PersonalDebtService debts;
  final String currentUserId;
  final PersonalDebt? existing;
  final VoidCallback onSaved;

  @override
  State<_DebtFormSheet> createState() => _DebtFormSheetState();
}

class _DebtFormSheetState extends State<_DebtFormSheet> {
  late String _direction;
  late final TextEditingController _name;
  late final TextEditingController _principal;
  late final TextEditingController _rate;
  late final TextEditingController _note;
  DateTime? _due;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _direction = e?.direction ?? "i_owe";
    _name = TextEditingController(text: e?.counterpartyName ?? "");
    _principal = TextEditingController(
      text: e == null ? "" : VndFormat.input(e.principalAmount),
    );
    _rate = TextEditingController(
      text: e?.interestRate == null ? "" : "${e!.interestRate}",
    );
    _note = TextEditingController(text: e?.note ?? "");
    _due = e?.dueDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _principal.dispose();
    _rate.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = VndFormat.parse(_principal.text);
    if (_name.text.trim().isEmpty ||
        (widget.existing == null && (amount == null || amount <= 0))) {
      setState(() => _error = S.invalidAmount);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.existing == null) {
        await widget.debts.create(
          homeId: widget.homeId,
          direction: _direction,
          counterpartyName: _name.text.trim(),
          principalAmount: amount!,
          dueDate: _due,
          interestRate: double.tryParse(_rate.text.trim().replaceAll(",", ".")),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          createdBy: widget.currentUserId,
        );
      } else {
        await widget.debts.updateDebt(
          id: widget.existing!.id,
          direction: _direction,
          counterpartyName: _name.text.trim(),
          dueDate: _due,
          interestRate: double.tryParse(_rate.text.trim().replaceAll(",", ".")),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
      }
      if (!mounted) return;
      popWithAppToast(
        context,
        widget.existing == null ? S.toastDebtAdded : S.toastDebtSaved,
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
            FormTitle(title: widget.existing == null ? S.addDebt : S.editDebt),
            Text(
              S.debtDirection,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: "i_owe", label: Text(S.iOwe)),
                ButtonSegment(value: "owed_to_me", label: Text(S.owedToMe)),
              ],
              selected: {_direction},
              onSelectionChanged: (s) => setState(() => _direction = s.first),
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(label: S.counterparty, controller: _name),
            if (widget.existing == null) ...[
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledMoneyField(
                label: S.principalAmount,
                controller: _principal,
              ),
            ],
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledPickerField(
              label: S.dueDate,
              value:
                  _due == null ? "—" : DateFormat("dd/MM/yyyy").format(_due!),
              onTap: () async {
                final picked = await showAppDatePicker(
                  context: context,
                  initialDate: _due ?? DateTime.now(),
                );
                if (picked != null) setState(() => _due = picked);
              },
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(
              label: S.interestRate,
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
      ),
    );
  }
}

Future<void> showPersonalDebtDetail({
  required BuildContext context,
  required PersonalDebt debt,
  required PersonalDebtService debts,
  required VoidCallback onChanged,
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
        (context) =>
            _DebtDetailSheet(debt: debt, debts: debts, onChanged: onChanged),
  );
}

class _DebtDetailSheet extends StatefulWidget {
  const _DebtDetailSheet({
    required this.debt,
    required this.debts,
    required this.onChanged,
  });

  final PersonalDebt debt;
  final PersonalDebtService debts;
  final VoidCallback onChanged;

  @override
  State<_DebtDetailSheet> createState() => _DebtDetailSheetState();
}

class _DebtDetailSheetState extends State<_DebtDetailSheet> {
  List<PersonalDebtPayment> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final payments = await widget.debts.listPayments(widget.debt.id);
    if (!mounted) return;
    setState(() {
      _payments = payments;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormTitle(title: widget.debt.counterpartyName),
              Text(
                widget.debt.iOwe ? S.iOwe : S.owedToMe,
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.remainingAmount),
                  MoneyText(amount: widget.debt.remainingAmount),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed:
                    widget.debt.isSettled
                        ? null
                        : () async {
                          await showAddPaymentForm(
                            context: context,
                            debt: widget.debt,
                            debts: widget.debts,
                            onSaved: () {
                              widget.onChanged();
                              _load();
                            },
                          );
                        },
                child: const Text(S.addPayment),
              ),
              const SectionHeader(title: S.paymentHistory),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_payments.isEmpty)
                Text("—", style: TextStyle(color: colors.textMuted))
              else
                for (final p in _payments)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: MoneyText(amount: p.amount),
                    subtitle: Text(DateFormat("dd/MM/yyyy").format(p.paidDate)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showAddPaymentForm({
  required BuildContext context,
  required PersonalDebt debt,
  required PersonalDebtService debts,
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
        (context) =>
            _PaymentFormSheet(debt: debt, debts: debts, onSaved: onSaved),
  );
}

class _PaymentFormSheet extends StatefulWidget {
  const _PaymentFormSheet({
    required this.debt,
    required this.debts,
    required this.onSaved,
  });

  final PersonalDebt debt;
  final PersonalDebtService debts;
  final VoidCallback onSaved;

  @override
  State<_PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<_PaymentFormSheet> {
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
      await widget.debts.addPayment(
        debtId: widget.debt.id,
        amount: amount,
        paidDate: _date,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      popWithAppToast(context, S.toastDebtPaymentAdded, then: widget.onSaved);
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
          const FormTitle(title: S.addPayment),
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
