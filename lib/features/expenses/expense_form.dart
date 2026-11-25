import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/electricity/bill_photo_viewer.dart";
import "package:home_manager/features/expenses/expense_category_style.dart";
import "package:home_manager/features/expenses/expense_wallet_field.dart";
import "package:home_manager/features/shared/app_sheet.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/datetime_picker.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/wallet/wallet_picker_sheet.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";
import "package:supabase_flutter/supabase_flutter.dart";

Future<void> showExpenseForm({
  required BuildContext context,
  required Home home,
  required ExpenseService expenses,
  required BillPhotoService photos,
  required List<ExpenseCategory> categories,
  required List<HomeMember> members,
  required String currentUserId,
  List<Wallet> wallets = const [],
  WalletService? walletService,
  Expense? existing,
  required VoidCallback onSaved,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (context) {
      return _ExpenseFormSheet(
        home: home,
        expenses: expenses,
        photos: photos,
        categories: categories,
        members: members,
        currentUserId: currentUserId,
        wallets: wallets,
        walletService: walletService,
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
    required this.wallets,
    required this.onSaved,
    this.walletService,
    this.existing,
  });

  final Home home;
  final ExpenseService expenses;
  final BillPhotoService photos;
  final List<ExpenseCategory> categories;
  final List<HomeMember> members;
  final String currentUserId;
  final List<Wallet> wallets;
  final WalletService? walletService;
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
  String? _walletId;
  bool _walletReady = false;
  Uint8List? _photoBytes;
  String? _error;
  bool _overBalance = false;
  bool _saving = false;
  /// Set after a successful insert when wallet debit may still fail; retry
  /// updates this id instead of inserting a duplicate.
  String? _createdExpenseId;

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
    _walletId = existing?.walletId;
    _amount.addListener(_onAmountChanged);
    _resolveDefaultWallet();
  }

  Future<void> _resolveDefaultWallet() async {
    if (widget.existing != null) {
      setState(() => _walletReady = true);
      return;
    }
    if (widget.wallets.isEmpty) {
      setState(() {
        _walletId = null;
        _walletReady = true;
      });
      return;
    }
    String? lastId;
    final svc = widget.walletService;
    if (svc != null) {
      try {
        lastId = await svc.lastUsedWalletId(
          homeId: widget.home.id,
          userId: widget.currentUserId,
        );
      } catch (_) {
        lastId = null;
      }
    }
    if (!mounted) return;
    final ids = widget.wallets.map((w) => w.id).toSet();
    setState(() {
      if (lastId != null && ids.contains(lastId)) {
        _walletId = lastId;
      } else {
        _walletId = widget.wallets.first.id;
      }
      _walletReady = true;
      _recomputeOverBalance();
    });
  }

  void _onAmountChanged() {
    setState(_recomputeOverBalance);
  }

  double get _availableBalance {
    final id = _walletId;
    if (id == null) return double.infinity;
    Wallet? wallet;
    for (final w in widget.wallets) {
      if (w.id == id) {
        wallet = w;
        break;
      }
    }
    if (wallet == null) return 0;
    var available = wallet.balanceVnd;
    final existing = widget.existing;
    if (existing != null &&
        existing.walletId != null &&
        existing.walletId == id) {
      available += existing.amountVnd;
    }
    return available;
  }

  void _recomputeOverBalance() {
    final money = VndFormat.parse(_amount.text);
    if (money == null || _walletId == null) {
      _overBalance = false;
      return;
    }
    _overBalance = money > _availableBalance;
  }

  bool get _canSave => !_saving && !_overBalance;

  @override
  void dispose() {
    _amount.removeListener(_onAmountChanged);
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickWallet() async {
    if (widget.wallets.isEmpty) return;
    final money = VndFormat.parse(_amount.text);
    final result = await showWalletPickerSheet(
      context: context,
      wallets: widget.wallets,
      selectedWalletId: _walletId,
      amountVnd: money,
    );
    if (!mounted || result == null) return;
    setState(() {
      if (identical(result, walletPickerNone)) {
        _walletId = null;
      } else if (result is String) {
        _walletId = result;
      }
      _overBalance = false;
      _recomputeOverBalance();
    });
  }

  Future<void> _save() async {
    final money = VndFormat.parse(_amount.text);
    if (money == null || money <= 0) {
      setState(() => _error = S.invalidExpenseAmount);
      return;
    }
    if (_overBalance || _saving) return;
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final existing = widget.existing;
      late final Expense saved;
      if (existing == null) {
        final retryId = _createdExpenseId;
        if (retryId != null) {
          // Wallet debit failed earlier — update the same row, do not insert.
          saved = await widget.expenses.update(
            id: retryId,
            categoryId: _categoryId,
            paidBy: _paidBy,
            amountVnd: money,
            expenseDate: _date,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
        } else {
          saved = await widget.expenses.insert(
            homeId: widget.home.id,
            categoryId: _categoryId,
            paidBy: _paidBy,
            amountVnd: money,
            expenseDate: _date,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
          _createdExpenseId = saved.id;
        }
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

      final walletSvc = widget.walletService;
      if (walletSvc != null) {
        if (existing != null || _createdExpenseId != null) {
          // Revert any prior debit before (re)applying.
          try {
            await walletSvc.revertExpense(saved.id);
          } catch (_) {
            // First apply has nothing to revert.
          }
        }
        final selected = _walletId;
        if (selected != null && selected.isNotEmpty) {
          await walletSvc.applyExpense(
            expenseId: saved.id,
            walletId: selected,
            amount: money,
          );
        }
      }

      if (!mounted) return;
      _createdExpenseId = null;
      popWithAppToast(
        context,
        existing == null ? S.toastExpenseAdded : S.toastExpenseSaved,
        then: widget.onSaved,
      );
    } catch (e) {
      final insufficient =
          e is PostgrestException &&
          e.message.toLowerCase().contains("insufficient balance");
      if (!mounted) return;
      setState(() {
        if (insufficient) {
          _overBalance = true;
          _error = null;
        } else {
          _error = "$e";
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Wallet? get _selectedWallet {
    final id = _walletId;
    if (id == null) return null;
    for (final w in widget.wallets) {
      if (w.id == id) return w;
    }
    return null;
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
            FormTitle(title: existing == null ? S.addExpense : S.editExpense),
            LabeledMoneyField(label: S.amount, controller: _amount),
            const SizedBox(height: AppSpacing.formFieldGap),
            if (_walletReady) ...[
              ExpenseWalletField(
                wallet: _selectedWallet,
                enabled: widget.wallets.isNotEmpty,
                overBalance: _overBalance,
                onTap: _pickWallet,
              ),
              // Spec: field B+36–B+100, over-balance B+104–B+120 (4px gap).
              const SizedBox(height: 4),
              // Always reserve error line height (16) so layout does not jump.
              SizedBox(
                height: 16,
                child:
                    _overBalance
                        ? Text(
                          S.walletOverBalance,
                          style: TextStyle(
                            fontFamily: AppFonts.nunito,
                            fontSize: 12,
                            height: 16 / 12,
                            color: colors.error,
                          ),
                        )
                        : null,
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
            ],
            LabeledDropdownField<String>(
              label: S.category,
              value: _categoryId,
              items: [
                for (final category in widget.categories)
                  SelectOption(
                    value: category.id,
                    builder:
                        (_) => Row(
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
                  SelectOption(
                    value: _paidBy,
                    builder:
                        (_) => Text(widget.existing?.paidByName ?? _paidBy),
                  ),
                for (final member in widget.members)
                  SelectOption(
                    value: member.userId,
                    builder:
                        (_) => Text(
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
                final picked = await showAppDatePicker(
                  context: context,
                  initialDate: _date,
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(label: S.note, controller: _note),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
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
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _photoBytes != null ? S.photoSelected : S.pickPhoto,
                    ),
                  ),
                ),
                if (hasPhoto || _photoBytes != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _photoBytes != null
                              ? null
                              : () => showBillPhotoViewer(
                                context: context,
                                photoPath: existing!.receiptPhotoPath!,
                                photos: widget.photos,
                              ),
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        _photoBytes != null ? S.pickPhoto : S.viewPhoto,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_error!, style: TextStyle(color: colors.error)),
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: colors.accent.withValues(
                    alpha: 0.38,
                  ),
                  disabledForegroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.nunito,
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text(S.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
