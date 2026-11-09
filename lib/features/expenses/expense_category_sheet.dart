import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_sheet.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:supabase_flutter/supabase_flutter.dart";

const _colorKeys = ["food", "loan", "health", "tuition", "other"];

String normalizeCategoryName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.length <= 30) return trimmed;
  return trimmed.substring(0, 30);
}

String categoryErrorMessage(Object error) {
  if (error is PostgrestException) {
    return switch (error.code) {
      "23505" => S.categoryNameTaken,
      "23503" => S.categoryDeleteInUse,
      _ => S.errorGeneric,
    };
  }
  return S.errorGeneric;
}

Future<bool> showExpenseCategorySheet({
  required BuildContext context,
  required ExpenseService expenses,
  required String homeId,
  ExpenseCategory? existing,
}) async {
  final saved = await showAppSheet<bool>(
    context: context,
    showDragHandle: false,
    builder:
        (context) => _ExpenseCategorySheet(
          expenses: expenses,
          homeId: homeId,
          existing: existing,
        ),
  );
  return saved == true;
}

class _ExpenseCategorySheet extends StatefulWidget {
  const _ExpenseCategorySheet({
    required this.expenses,
    required this.homeId,
    this.existing,
  });

  final ExpenseService expenses;
  final String homeId;
  final ExpenseCategory? existing;

  @override
  State<_ExpenseCategorySheet> createState() => _ExpenseCategorySheetState();
}

class _ExpenseCategorySheetState extends State<_ExpenseCategorySheet> {
  late final TextEditingController _name;
  late String _iconKey;
  late String _colorKey;
  String? _fieldError;
  String? _deleteError;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;
  bool get _canDelete =>
      _isEdit && widget.existing!.isDefault == false;
  bool get _canSave => normalizeCategoryName(_name.text).isNotEmpty && !_saving;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? "");
    _iconKey = existing?.iconKey ?? AppIcons.expenseCategoryKeys.first;
    _colorKey = existing?.colorKey ?? _colorKeys.first;
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = normalizeCategoryName(_name.text);
    if (name.isEmpty) return;
    setState(() {
      _fieldError = null;
      _deleteError = null;
      _saving = true;
    });
    try {
      final existing = widget.existing;
      if (existing == null) {
        await widget.expenses.createCategory(
          homeId: widget.homeId,
          name: name,
          iconKey: _iconKey,
          colorKey: _colorKey,
        );
      } else {
        await widget.expenses.updateCategory(
          id: existing.id,
          name: name,
          iconKey: _iconKey,
          colorKey: _colorKey,
        );
      }
      if (!mounted) return;
      popWithAppToast(context, S.toastSaved, result: true);
    } catch (e, st) {
      AppLog.e("Save category failed", error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _fieldError = categoryErrorMessage(e);
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.deleteCategoryTitle),
            content: const Text(S.deleteCategoryConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(S.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(S.delete),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _deleteError = null;
      _saving = true;
    });
    try {
      await widget.expenses.deleteCategory(widget.existing!.id);
      if (!mounted) return;
      Navigator.pop(context, true);
      // Toast after pop via caller — show here if still mounted root.
    } catch (e, st) {
      AppLog.e("Delete category failed", error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _deleteError = categoryErrorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md + bottomInset + viewInsets,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 36,
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Text(
              _isEdit ? S.editCategory : S.addCategory,
              style: const TextStyle(
                fontFamily: AppFonts.nunito,
                fontSize: 18,
                height: 24 / 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              S.categoryName,
              style: TextStyle(
                fontFamily: AppFonts.nunito,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 48,
              child: TextField(
                controller: _name,
                autofocus: !_isEdit,
                maxLength: 30,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                onChanged: (_) {
                  if (_fieldError != null) {
                    setState(() => _fieldError = null);
                  }
                },
                decoration: InputDecoration(
                  counterText: "",
                  errorText: null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                      color:
                          _fieldError != null ? colors.error : colors.border,
                      width: _fieldError != null ? 1.5 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(
                      color:
                          _fieldError != null ? colors.error : colors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // Spec 06: field 450–498, error slot 502–518 (4px gap).
            const SizedBox(height: 4),
            SizedBox(
              height: 16,
              child:
                  _fieldError == null
                      ? null
                      : Text(
                        _fieldError!,
                        style: TextStyle(
                          fontFamily: AppFonts.nunito,
                          fontSize: 12,
                          height: 16 / 12,
                          color: colors.error,
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            Text(
              S.categoryIcon,
              style: TextStyle(
                fontFamily: AppFonts.nunito,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            _IconGrid(
              selected: _iconKey,
              colorKey: _colorKey,
              onSelected: (key) => setState(() => _iconKey = key),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              S.categoryColor,
              style: TextStyle(
                fontFamily: AppFonts.nunito,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            _ColorRow(
              selected: _colorKey,
              onSelected: (key) => setState(() => _colorKey = key),
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
            // Spec 07: Lưu 658–706, error 714–746 (32), Xoá 754–802.
            if (_deleteError != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, size: 16, color: colors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _deleteError!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.nunito,
                          fontSize: 12,
                          height: 16 / 12,
                          color: colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_canDelete) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: _saving ? null : _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.error,
                    textStyle: const TextStyle(
                      fontFamily: AppFonts.nunito,
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text(S.deleteCategory),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconGrid extends StatelessWidget {
  const _IconGrid({
    required this.selected,
    required this.colorKey,
    required this.onSelected,
  });

  final String selected;
  final String colorKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = colors.categoryColor(colorKey);
    return SizedBox(
      height: 104,
      child: GridView.count(
        crossAxisCount: 6,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 54 / 48,
        children: [
          for (final key in AppIcons.expenseCategoryKeys)
            InkWell(
              key: ValueKey("cat-icon-$key"),
              onTap: () => onSelected(key),
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              child: Container(
                width: 54,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      selected == key
                          ? tint.withValues(alpha: 0.12)
                          : colors.bgElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  border:
                      selected == key
                          ? Border.all(color: tint, width: 2)
                          : Border.all(color: colors.border),
                ),
                child: Icon(
                  AppIcons.expenseCategory(key),
                  size: 20,
                  color: selected == key ? tint : colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          for (final key in _colorKeys) ...[
            SizedBox(
              width: 48,
              height: 48,
              child: InkWell(
                key: ValueKey("cat-color-$key"),
                onTap: () => onSelected(key),
                customBorder: const CircleBorder(),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.categoryColor(key),
                      border:
                          selected == key
                              ? Border.all(color: colors.textPrimary, width: 2)
                              : null,
                    ),
                    child:
                        selected == key
                            ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ),
              ),
            ),
            if (key != _colorKeys.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
