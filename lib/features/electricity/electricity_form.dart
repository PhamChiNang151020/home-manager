import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";

Future<void> showElectricityAddForm({
  required BuildContext context,
  required Home home,
  required ElectricityService electricity,
  required BillPhotoService photos,
  ElectricityPeriod? previousPeriod,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
    ),
    builder: (context) {
      return _ElectricityAddSheet(
        home: home,
        electricity: electricity,
        photos: photos,
        previousPeriod: previousPeriod,
        onSaved: onSaved,
      );
    },
  );
}

Future<void> showElectricityPeriodDialog({
  required BuildContext context,
  required Home home,
  required ElectricityService electricity,
  required BillPhotoService photos,
  required ElectricityPeriod existing,
  ElectricityPeriod? previousPeriod,
  required VoidCallback onSaved,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: _ElectricityPeriodDialog(
            home: home,
            electricity: electricity,
            photos: photos,
            existing: existing,
            previousPeriod: previousPeriod,
            onSaved: onSaved,
          ),
        ),
      );
    },
  );
}

class _ElectricityAddSheet extends StatefulWidget {
  const _ElectricityAddSheet({
    required this.home,
    required this.electricity,
    required this.photos,
    required this.onSaved,
    this.previousPeriod,
  });

  final Home home;
  final ElectricityService electricity;
  final BillPhotoService photos;
  final ElectricityPeriod? previousPeriod;
  final VoidCallback onSaved;

  @override
  State<_ElectricityAddSheet> createState() => _ElectricityAddSheetState();
}

class _ElectricityAddSheetState extends State<_ElectricityAddSheet> {
  late final TextEditingController _previous;
  late final TextEditingController _next;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _month;
  Uint8List? _photoBytes;
  String? _error;

  bool get _isMeter => widget.home.trackingMode == TrackingMode.meter;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
    _previous = TextEditingController(
      text: widget.previousPeriod?.newKwh?.toString() ?? "",
    );
    _next = TextEditingController();
    _amount = TextEditingController();
    _note = TextEditingController();
  }

  @override
  void dispose() {
    _previous.dispose();
    _next.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _recompute() {
    if (!_isMeter) return;
    final prev = double.tryParse(_previous.text.replaceAll(",", "."));
    final neu = double.tryParse(_next.text.replaceAll(",", "."));
    if (prev == null || neu == null) return;
    final used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
    _amount.text = VndFormat.input(
      MeterMath.amountVnd(
        consumptionKwh: used,
        kwhRate: widget.home.kwhRate,
      ),
    );
  }

  Future<void> _save() async {
    try {
      double? prev;
      double? neu;
      double? used;
      final money = VndFormat.parse(_amount.text);
      if (_isMeter) {
        prev = double.tryParse(_previous.text.replaceAll(",", "."));
        neu = double.tryParse(_next.text.replaceAll(",", "."));
        if (prev == null || neu == null) {
          setState(() => _error = S.firstPeriodHint);
          return;
        }
        if (neu < prev) {
          setState(() => _error = S.invalidReadings);
          return;
        }
        used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
      } else if (money == null || money <= 0) {
        setState(() => _error = S.invalidAmount);
        return;
      }
      String? photoPath;
      if (_photoBytes != null) {
        photoPath = await widget.photos.upload(
          homeId: widget.home.id,
          month: _month,
          bytes: _photoBytes!,
        );
      }
      await widget.electricity.upsert(
        homeId: widget.home.id,
        periodMonth: _month,
        amountVnd: _isMeter
            ? MeterMath.amountVnd(
                consumptionKwh: used!,
                kwhRate: widget.home.kwhRate,
              )
            : money!,
        previousKwh: prev,
        newKwh: neu,
        consumptionKwh: used,
        photoPath: photoPath,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      setState(() => _error = "$e");
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.year, picked.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
            FormTitle(title: S.addPeriod),
            LabeledPickerField(
              label: S.month,
              value: DateFormat("MM/yyyy").format(_month),
              onTap: _pickMonth,
            ),
            if (_isMeter) ...[
              if (widget.previousPeriod == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    S.firstPeriodHint,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(
                label: S.previousKwh,
                controller: _previous,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(_recompute),
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(
                label: S.newKwh,
                controller: _next,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(_recompute),
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
            ] else
              const SizedBox(height: AppSpacing.formFieldGap),
            LabeledMoneyField(
              label: S.amount,
              controller: _amount,
              readOnly: _isMeter,
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(
              label: S.note,
              controller: _note,
            ),
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
              label: Text(_photoBytes == null ? S.pickPhoto : "${S.photo} ✓"),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  _error!,
                  style: TextStyle(color: colors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _save,
              child: const Text(S.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElectricityPeriodDialog extends StatefulWidget {
  const _ElectricityPeriodDialog({
    required this.home,
    required this.electricity,
    required this.photos,
    required this.existing,
    required this.onSaved,
    this.previousPeriod,
  });

  final Home home;
  final ElectricityService electricity;
  final BillPhotoService photos;
  final ElectricityPeriod existing;
  final ElectricityPeriod? previousPeriod;
  final VoidCallback onSaved;

  @override
  State<_ElectricityPeriodDialog> createState() =>
      _ElectricityPeriodDialogState();
}

class _ElectricityPeriodDialogState extends State<_ElectricityPeriodDialog> {
  late final TextEditingController _previous;
  late final TextEditingController _next;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late DateTime _month;
  Uint8List? _photoBytes;
  String? _error;
  bool _editing = false;
  bool _saving = false;

  bool get _isMeter => widget.home.trackingMode == TrackingMode.meter;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _month = existing.periodMonth;
    _previous = TextEditingController(
      text: existing.previousKwh?.toString() ?? "",
    );
    _next = TextEditingController(text: existing.newKwh?.toString() ?? "");
    _amount = TextEditingController(
      text: VndFormat.input(existing.amountVnd),
    );
    _note = TextEditingController(text: existing.note ?? "");
  }

  @override
  void dispose() {
    _previous.dispose();
    _next.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _recompute() {
    if (!_isMeter || !_editing) return;
    final prev = double.tryParse(_previous.text.replaceAll(",", "."));
    final neu = double.tryParse(_next.text.replaceAll(",", "."));
    if (prev == null || neu == null) return;
    final used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
    _amount.text = VndFormat.input(
      MeterMath.amountVnd(
        consumptionKwh: used,
        kwhRate: widget.home.kwhRate,
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      double? prev;
      double? neu;
      double? used;
      final money = VndFormat.parse(_amount.text);
      if (_isMeter) {
        prev = double.tryParse(_previous.text.replaceAll(",", "."));
        neu = double.tryParse(_next.text.replaceAll(",", "."));
        if (prev == null || neu == null) {
          setState(() => _error = S.firstPeriodHint);
          return;
        }
        if (neu < prev) {
          setState(() => _error = S.invalidReadings);
          return;
        }
        used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
      } else if (money == null || money <= 0) {
        setState(() => _error = S.invalidAmount);
        return;
      }
      String? photoPath = widget.existing.photoPath;
      if (_photoBytes != null) {
        photoPath = await widget.photos.upload(
          homeId: widget.home.id,
          month: _month,
          bytes: _photoBytes!,
        );
      }
      await widget.electricity.upsert(
        homeId: widget.home.id,
        periodMonth: _month,
        amountVnd: _isMeter
            ? MeterMath.amountVnd(
                consumptionKwh: used!,
                kwhRate: widget.home.kwhRate,
              )
            : money!,
        previousKwh: prev,
        newKwh: neu,
        consumptionKwh: used,
        photoPath: photoPath,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickMonth() async {
    if (!_editing) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _month = DateTime(picked.year, picked.month));
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(S.deletePeriod),
        content: const Text(S.deletePeriodConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(S.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _error = null);
    try {
      final path = widget.existing.photoPath;
      if (path != null && path.isNotEmpty) {
        await widget.photos.remove(path);
      }
      await widget.electricity.delete(widget.existing.id);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      setState(() => _error = "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasPhoto = widget.existing.photoPath != null &&
        widget.existing.photoPath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            FormTitle(title: S.editPeriod),
            LabeledPickerField(
              label: S.month,
              value: DateFormat("MM/yyyy").format(_month),
              enabled: _editing,
              onTap: _pickMonth,
            ),
            if (_isMeter) ...[
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(
                label: S.previousKwh,
                controller: _previous,
                enabled: _editing,
                readOnly: !_editing,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(_recompute),
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledTextField(
                label: S.newKwh,
                controller: _next,
                enabled: _editing,
                readOnly: !_editing,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(_recompute),
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
            ] else
              const SizedBox(height: AppSpacing.formFieldGap),
            LabeledMoneyField(
              label: S.amount,
              controller: _amount,
              enabled: _editing,
              readOnly: _isMeter || !_editing,
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(
              label: S.note,
              controller: _note,
              enabled: _editing,
              readOnly: !_editing,
            ),
            if (_editing) ...[
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
                  _photoBytes != null ? "${S.photo} ✓" : S.pickPhoto,
                ),
              ),
            ] else if (hasPhoto) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                S.hasPhoto,
                style: TextStyle(color: colors.textSecondary),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  _error!,
                  style: TextStyle(color: colors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _editing
                      ? FilledButton(
                          onPressed: _saving ? null : _save,
                          child: const Text(S.save),
                        )
                      : OutlinedButton(
                          onPressed: () => setState(() => _editing = true),
                          child: const Text(S.edit),
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _confirmDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error),
                    ),
                    child: const Text(S.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
