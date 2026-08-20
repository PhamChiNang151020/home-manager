import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/bill_photo_viewer.dart";
import "package:home_manager/features/expenses/expense_category_style.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";

Future<void> showExpenseForm({
  required BuildContext context,
  required Home home,
  required ExpenseService expenses,
  required BillPhotoService photos,
  required List<ExpenseCategory> categories,
  required List<HomeMember> members,
  required String currentUserId,
  Expense? existing,
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
    builder: (context) {
      return _ExpenseFormSheet(
        home: home,
        expenses: expenses,
        photos: photos,
        categories: categories,
        members: members,
        currentUserId: currentUserId,
        existing: existing,
        onSaved: onSaved,
      );
    },
  );
}

class _ExpenseFormSheet extends StatefulWidget {
  const _ExpenseFormSheet({
    required this.home,
    required this.expenses,
    required this.photos,
    required this.categories,
    required this.members,
    required this.currentUserId,
    required this.onSaved,
    this.existing,
  });

  final Home home;
  final ExpenseService expenses;
  final BillPhotoService photos;
  final List<ExpenseCategory> categories;
  final List<HomeMember> members;
  final String currentUserId;
  final Expense? existing;
  final VoidCallback onSaved;

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late String _categoryId;
  late String _paidBy;
  late DateTime _date;
  Uint8List? _photoBytes;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amount = TextEditingController(
      text: existing == null ? "" : VndFormat.input(existing.amountVnd),
    );
    _note = TextEditingController(text: existing?.note ?? "");
    _categoryId = existing?.categoryId ?? widget.categories.first.id;
    _paidBy = existing?.paidBy ?? widget.currentUserId;
    _date = existing?.expenseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final money = VndFormat.parse(_amount.text);
    if (money == null || money <= 0) {
      setState(() => _error = S.invalidExpenseAmount);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final existing = widget.existing;
      late final Expense saved;
      if (existing == null) {
        saved = await widget.expenses.insert(
          homeId: widget.home.id,
          categoryId: _categoryId,
          paidBy: _paidBy,
          amountVnd: money,
          expenseDate: _date,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
      } else {
        saved = await widget.expenses.update(
          id: existing.id,
          categoryId: _categoryId,
          paidBy: _paidBy,
          amountVnd: money,
          expenseDate: _date,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          receiptPhotoPath: existing.receiptPhotoPath,
        );
      }

      var photoPath = saved.receiptPhotoPath;
      if (_photoBytes != null) {
        photoPath = await widget.photos.upload(
          homeId: widget.home.id,
          month: _date,
          bytes: _photoBytes!,
          kind: BillPhotoKind.expense,
          expenseId: saved.id,
        );
        await widget.expenses.update(
          id: saved.id,
          categoryId: _categoryId,
          paidBy: _paidBy,
          amountVnd: money,
          expenseDate: _date,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          receiptPhotoPath: photoPath,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final existing = widget.existing;
    final hasPhoto =
        existing?.receiptPhotoPath != null &&
        existing!.receiptPhotoPath!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            FormTitle(title: existing == null ? S.addExpense : S.editExpense),
            LabeledMoneyField(label: S.amount, controller: _amount),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledDropdownField<String>(
              label: S.category,
              value: _categoryId,
              items: [
                for (final category in widget.categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExpenseCategoryIcon(
                          iconKey: category.iconKey,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(category.name),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _categoryId = value);
              },
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledDropdownField<String>(
              label: S.paidBy,
              value: _paidBy,
              items: [
                if (widget.members.every((member) => member.userId != _paidBy))
                  DropdownMenuItem(value: _paidBy, child: Text(_paidBy)),
                for (final member in widget.members)
                  DropdownMenuItem(
                    value: member.userId,
                    child: Text(
                      member.displayName ?? member.email ?? member.userId,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _paidBy = value);
              },
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledPickerField(
              label: S.expenseDate,
              value: DateFormat("dd/MM/yyyy").format(_date),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  cancelText: S.cancel,
                  confirmText: S.ok,
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(label: S.note, controller: _note),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () async {
                final file = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                  maxWidth: 1600,
                );
                if (file != null) {
                  final bytes = await file.readAsBytes();
                  setState(() => _photoBytes = bytes);
                }
              },
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                _photoBytes != null || hasPhoto ? "${S.photo} ✓" : S.pickPhoto,
              ),
            ),
            if (hasPhoto && _photoBytes == null)
              TextButton(
                onPressed:
                    () => showBillPhotoViewer(
                      context: context,
                      photoPath: existing.receiptPhotoPath!,
                      photos: widget.photos,
                    ),
                child: const Text(S.hasPhoto),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_error!, style: TextStyle(color: colors.error)),
              ),
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
