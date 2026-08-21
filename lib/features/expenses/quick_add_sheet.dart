import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/domain/receipt_amount_parser.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/ocr_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/expenses/expense_category_style.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/datetime_picker.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";

/// Returns `true` when the user asked to open the full expense form instead.
Future<bool> showQuickAddSheet({
  required BuildContext context,
  required Home home,
  required ExpenseService expenses,
  required BillPhotoService photos,
  required List<ExpenseCategory> categories,
  required List<HomeMember> members,
  required String currentUserId,
  required VoidCallback onSaved,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (context) {
      return _QuickAddSheet(
        home: home,
        expenses: expenses,
        photos: photos,
        categories: categories,
        members: members,
        currentUserId: currentUserId,
        onSaved: onSaved,
      );
    },
  );
  return result == true;
}

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet({
    required this.home,
    required this.expenses,
    required this.photos,
    required this.categories,
    required this.members,
    required this.currentUserId,
    required this.onSaved,
  });

  final Home home;
  final ExpenseService expenses;
  final BillPhotoService photos;
  final List<ExpenseCategory> categories;
  final List<HomeMember> members;
  final String currentUserId;
  final VoidCallback onSaved;

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _date;
  bool _expanded = false;
  bool _saving = false;
  bool _ocrBusy = false;
  String? _error;
  Uint8List? _photoBytes;
  bool _ocrFilled = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _note = TextEditingController();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickAndOcr() async {
    if (_ocrBusy || _saving) return;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _ocrBusy = true;
        _error = null;
      });

      final text = await recognizeReceiptText(bytes);
      final parsed = parseReceiptAmount(text);
      if (!mounted) return;
      if (parsed == null) {
        showAppToast(context, S.receiptAmountFailed, kind: AppToastKind.info);
        setState(() {
          _ocrBusy = false;
          _ocrFilled = false;
        });
        return;
      }
      setState(() {
        _amount.text = VndFormat.input(parsed);
        _ocrFilled = true;
        _ocrBusy = false;
      });
    } catch (e, st) {
      AppLog.e("Receipt OCR failed", error: e, stackTrace: st);
      if (!mounted) return;
      showAppToast(context, S.receiptAmountFailed, kind: AppToastKind.info);
      setState(() => _ocrBusy = false);
    }
  }

  Future<void> _saveWithCategory(ExpenseCategory category) async {
    final money = VndFormat.parse(_amount.text);
    if (money == null || money <= 0) {
      setState(() => _error = S.invalidExpenseAmount);
      return;
    }
    if (_saving || _ocrBusy) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final saved = await widget.expenses.insert(
        homeId: widget.home.id,
        categoryId: category.id,
        paidBy: widget.currentUserId,
        amountVnd: money,
        expenseDate: _date,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );

      if (_photoBytes != null) {
        final photoPath = await widget.photos.upload(
          homeId: widget.home.id,
          month: _date,
          bytes: _photoBytes!,
          kind: BillPhotoKind.expense,
          expenseId: saved.id,
        );
        await widget.expenses.update(
          id: saved.id,
          categoryId: category.id,
          paidBy: widget.currentUserId,
          amountVnd: money,
          expenseDate: _date,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          receiptPhotoPath: photoPath,
        );
      }

      if (!mounted) return;
      popWithAppToast(context, S.toastExpenseAdded, then: widget.onSaved);
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openFullForm() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_ocrBusy) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.35,
        child: const LoadingView(message: S.readingReceiptAmount),
      );
    }

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
            Row(
              children: [
                const Expanded(child: FormTitle(title: S.quickAddExpense)),
                IconButton(
                  tooltip: S.quickAddExpand,
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.more_horiz,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: LabeledMoneyField(
                    label: S.amount,
                    controller: _amount,
                    autofocus: true,
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                      if (_ocrFilled) setState(() => _ocrFilled = false);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: IconButton.filledTonal(
                    tooltip: S.pickPhoto,
                    onPressed: _saving ? null : _pickAndOcr,
                    icon: Icon(
                      _photoBytes != null
                          ? Icons.photo_camera
                          : Icons.photo_camera_outlined,
                    ),
                  ),
                ),
              ],
            ),
            if (_ocrFilled)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  S.receiptAmountHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
              ),
            if (_expanded) ...[
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
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_error!, style: TextStyle(color: colors.error)),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              S.category,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final categoryColor = colors.categoryColor(category.colorKey);
                return Material(
                  color: colors.bgElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    onTap: _saving ? null : () => _saveWithCategory(category),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ExpenseCategoryIcon(
                            iconKey: category.iconKey,
                            size: 28,
                            color: categoryColor,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            category.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _saving ? null : _openFullForm,
              child: const Text(S.quickAddMoreDetails),
            ),
          ],
        ),
      ),
    );
  }
}
