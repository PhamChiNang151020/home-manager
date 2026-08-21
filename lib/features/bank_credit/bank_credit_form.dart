import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/domain/bank_brand.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/services/bank_account_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/bank_logo.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/month_picker.dart";
import "package:intl/intl.dart";

Future<void> showBankAccountForm({
  required BuildContext context,
  required String homeId,
  required BankAccountService bank,
  BankAccount? existing,
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
        (context) => _BankAccountFormSheet(
          homeId: homeId,
          bank: bank,
          existing: existing,
          onSaved: onSaved,
        ),
  );
}

class _BankAccountFormSheet extends StatefulWidget {
  const _BankAccountFormSheet({
    required this.homeId,
    required this.bank,
    required this.onSaved,
    this.existing,
  });

  final String homeId;
  final BankAccountService bank;
  final BankAccount? existing;
  final VoidCallback onSaved;

  @override
  State<_BankAccountFormSheet> createState() => _BankAccountFormSheetState();
}

class _BankAccountFormSheetState extends State<_BankAccountFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _limit;
  late final TextEditingController _statementDay;
  late final TextEditingController _dueDay;
  late final TextEditingController _note;
  String? _error;
  bool _saving = false;
  String _logoName = "";
  bool _customBank = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final initialName = e?.bankName ?? "";
    _name = TextEditingController(text: initialName);
    _logoName = initialName;
    _customBank =
        initialName.isNotEmpty &&
        !BankBrand.popular.any((b) => b.name == initialName);
    _name.addListener(() {
      if (_logoName != _name.text) {
        setState(() => _logoName = _name.text);
      }
    });
    _limit = TextEditingController(
      text: e == null ? "" : VndFormat.input(e.creditLimit),
    );
    _statementDay = TextEditingController(
      text: e == null ? "15" : "${e.statementDay}",
    );
    _dueDay = TextEditingController(text: e == null ? "25" : "${e.dueDay}");
    _note = TextEditingController(text: e?.note ?? "");
  }

  void _selectBank(String name) {
    setState(() {
      _customBank = false;
      _name.text = name;
      _logoName = name;
    });
  }

  void _enableCustomBank() {
    setState(() {
      _customBank = true;
      if (BankBrand.popular.any((b) => b.name == _name.text)) {
        _name.clear();
        _logoName = "";
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    _statementDay.dispose();
    _dueDay.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final limit = VndFormat.parse(_limit.text);
    final stmt = int.tryParse(_statementDay.text.trim());
    final due = int.tryParse(_dueDay.text.trim());
    if (_name.text.trim().isEmpty) {
      setState(() => _error = S.bankPickHint);
      return;
    }
    if (limit == null || limit <= 0) {
      setState(() => _error = S.invalidAmount);
      return;
    }
    if (stmt == null ||
        due == null ||
        stmt < 1 ||
        stmt > 31 ||
        due < 1 ||
        due > 31) {
      setState(() => _error = S.invalidDay);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.bank.upsertAccount(
        homeId: widget.homeId,
        bankName: _name.text.trim(),
        creditLimit: limit,
        statementDay: stmt,
        dueDay: due,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        editingId: widget.existing?.id,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
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
            FormTitle(
              title:
                  widget.existing == null
                      ? S.addBankAccount
                      : S.editBankAccount,
            ),
            Text(
              S.bankPickHint,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final bank in BankBrand.popular)
                  _BankPickTile(
                    name: bank.name,
                    selected: !_customBank && _name.text == bank.name,
                    onTap: () => _selectBank(bank.name),
                  ),
                _BankPickTile(
                  name: S.bankOther,
                  selected: _customBank,
                  onTap: _enableCustomBank,
                  custom: true,
                ),
              ],
            ),
            if (_customBank) ...[
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(
                label: S.bankName,
                controller: _name,
                hint: "Vietcombank, Techcombank…",
                prefix: BankLogo(bankName: _logoName, size: 24),
              ),
            ] else if (_name.text.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  BankLogo(bankName: _name.text, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _name.text,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledMoneyField(label: S.creditLimit, controller: _limit),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(
              label: S.statementDay,
              controller: _statementDay,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              maxLength: 2,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hint: "1–31",
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(
              label: S.dueDay,
              controller: _dueDay,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              maxLength: 2,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              hint: "1–31",
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

class _BankPickTile extends StatelessWidget {
  const _BankPickTile({
    required this.name,
    required this.selected,
    required this.onTap,
    this.custom = false,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;
  final bool custom;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.accentMuted(0.28) : colors.bgElevated,
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        child: Container(
          width: 104,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(
              color: selected ? colors.accent : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (custom)
                Icon(
                  Icons.edit_outlined,
                  size: 28,
                  color: selected ? colors.accent : colors.textSecondary,
                )
              else
                BankLogo(bankName: name, size: 32),
              const SizedBox(height: AppSpacing.xs),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showBankPeriodForm({
  required BuildContext context,
  required BankAccount account,
  required BankAccountService bank,
  BankAccountPeriod? existing,
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
        (context) => _BankPeriodFormSheet(
          account: account,
          bank: bank,
          existing: existing,
          onSaved: onSaved,
        ),
  );
}

class _BankPeriodFormSheet extends StatefulWidget {
  const _BankPeriodFormSheet({
    required this.account,
    required this.bank,
    required this.onSaved,
    this.existing,
  });

  final BankAccount account;
  final BankAccountService bank;
  final BankAccountPeriod? existing;
  final VoidCallback onSaved;

  @override
  State<_BankPeriodFormSheet> createState() => _BankPeriodFormSheetState();
}

class _BankPeriodFormSheetState extends State<_BankPeriodFormSheet> {
  late DateTime _month;
  late final TextEditingController _used;
  late final TextEditingController _due;
  late final TextEditingController _made;
  late final TextEditingController _note;
  bool _isPaid = false;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _month =
        e?.periodMonth ?? DateTime(DateTime.now().year, DateTime.now().month);
    _used = TextEditingController(
      text: e == null ? "" : VndFormat.input(e.balanceUsed),
    );
    _due = TextEditingController(
      text: e == null ? "" : VndFormat.input(e.paymentDue),
    );
    _made = TextEditingController(
      text: e == null ? "0" : VndFormat.input(e.paymentMade),
    );
    _note = TextEditingController(text: e?.note ?? "");
    _isPaid = e?.isPaid ?? false;
  }

  @override
  void dispose() {
    _used.dispose();
    _due.dispose();
    _made.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final used = VndFormat.parse(_used.text);
    final due = VndFormat.parse(_due.text);
    final made = VndFormat.parse(_made.text) ?? 0;
    if (used == null || due == null || used < 0 || due < 0) {
      setState(() => _error = S.invalidAmount);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.bank.upsertPeriod(
        bankAccountId: widget.account.id,
        periodMonth: _month,
        balanceUsed: used,
        paymentDue: due,
        paymentMade: made,
        isPaid: _isPaid,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        editingId: widget.existing?.id,
        editingOriginalMonth: widget.existing?.periodMonth,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
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
            FormTitle(
              title:
                  widget.existing == null ? S.addBankPeriod : S.editBankPeriod,
            ),
            LabeledPickerField(
              label: S.month,
              value: DateFormat("MM/yyyy").format(_month),
              onTap: () async {
                final picked = await showMonthPicker(
                  context: context,
                  initialDate: _month,
                );
                if (picked != null) setState(() => _month = picked);
              },
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledMoneyField(label: S.balanceUsed, controller: _used),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledMoneyField(label: S.paymentDue, controller: _due),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledMoneyField(label: S.paymentMade, controller: _made),
            const SizedBox(height: AppSpacing.formFieldGap),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_isPaid ? S.paid : S.unpaid),
              value: _isPaid,
              onChanged: (v) => setState(() => _isPaid = v),
            ),
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
