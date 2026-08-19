import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/domain/electricity_validation.dart";
import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/bill_photo_viewer.dart";
import "package:home_manager/features/electricity/period_month_conflict.dart";
import "package:home_manager/features/shared/datetime_picker.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/month_picker.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";

String _saveErrorMessage(ElectricitySaveError error) {
  switch (error) {
    case ElectricitySaveError.missingReadings:
      return S.firstPeriodHint;
    case ElectricitySaveError.invalidReadings:
      return S.invalidReadings;
    case ElectricitySaveError.invalidAmount:
      return S.invalidAmount;
  }
}

Future<void> showElectricityAddForm({
  required BuildContext context,
  required Home home,
  required ElectricityService electricity,
  required BillPhotoService photos,
  ElectricityPeriod? previousPeriod,
  required List<ElectricityPeriod> existingPeriods,
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
      return _ElectricityAddSheet(
        home: home,
        electricity: electricity,
        photos: photos,
        previousPeriod: previousPeriod,
        existingPeriods: existingPeriods,
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
  required List<ElectricityPeriod> existingPeriods,
  required VoidCallback onSaved,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: _ElectricityPeriodDialog(
            home: home,
            electricity: electricity,
            photos: photos,
            existing: existing,
            previousPeriod: previousPeriod,
            existingPeriods: existingPeriods,
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
    required this.existingPeriods,
    this.previousPeriod,
  });

  final Home home;
  final ElectricityService electricity;
  final BillPhotoService photos;
  final List<ElectricityPeriod> existingPeriods;
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
  late DateTime _recordedAt;
  Uint8List? _photoBytes;
  String? _error;
  String? _duplicateHint;

  bool get _isMeter => widget.home.trackingMode == TrackingMode.meter;

  void _updateDuplicateHint() {
    final duplicate = findPeriodForMonth(widget.existingPeriods, _month);
    _duplicateHint = duplicate == null ? null : S.duplicatePeriodHint;
  }

  Future<bool> _confirmDuplicateIfNeeded() async {
    final duplicate = findPeriodForMonth(widget.existingPeriods, _month);
    if (duplicate == null) return true;
    return confirmDuplicatePeriodMonth(context, _month);
  }

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
    _recordedAt = DateTime.now();
    _previous = TextEditingController(
      text: widget.previousPeriod?.newKwh?.toString() ?? "",
    );
    _next = TextEditingController();
    _amount = TextEditingController();
    _note = TextEditingController();
    _updateDuplicateHint();
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
    final prev = ElectricityValidation.parseKwh(_previous.text);
    final neu = ElectricityValidation.parseKwh(_next.text);
    if (prev == null || neu == null) return;
    final used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
    _amount.text = VndFormat.input(
      MeterMath.amountVnd(consumptionKwh: used, kwhRate: widget.home.kwhRate),
    );
  }

  Future<void> _save() async {
    try {
      double? prev;
      double? neu;
      double? used;
      final money = VndFormat.parse(_amount.text);
      if (_isMeter) {
        prev = ElectricityValidation.parseKwh(_previous.text);
        neu = ElectricityValidation.parseKwh(_next.text);
        final error = ElectricityValidation.validateMeterReadings(prev, neu);
        if (error != null) {
          setState(() => _error = _saveErrorMessage(error));
          return;
        }
        used = MeterMath.consumption(previousKwh: prev!, newKwh: neu!);
      } else {
        final error = ElectricityValidation.validateInvoiceAmount(money);
        if (error != null) {
          setState(() => _error = _saveErrorMessage(error));
          return;
        }
      }
      if (!await _confirmDuplicateIfNeeded()) return;

      setState(() => _error = null);
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
        amountVnd:
            _isMeter
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
        recordedAt: _recordedAt,
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      setState(() => _error = "$e");
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(context: context, initialDate: _month);
    if (picked != null) {
      setState(() {
        _month = DateTime(picked.year, picked.month);
        _updateDuplicateHint();
      });
    }
  }

  Future<void> _pickRecordedAt() async {
    final picked = await showDateTimePicker(
      context: context,
      initialDateTime: _recordedAt,
    );
    if (picked != null) {
      setState(() => _recordedAt = picked);
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
            if (_duplicateHint != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  _duplicateHint!,
                  style: TextStyle(color: colors.warning),
                ),
              ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledPickerField(
              label: S.recordedAt,
              value: DateFormat("dd/MM/yyyy HH:mm").format(_recordedAt),
              onTap: _pickRecordedAt,
              trailing: const Icon(Icons.schedule_outlined),
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
              label: Text(_photoBytes == null ? S.pickPhoto : "${S.photo} ✓"),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_error!, style: TextStyle(color: colors.error)),
              ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: _save, child: const Text(S.save)),
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
    required this.existingPeriods,
    this.previousPeriod,
  });

  final Home home;
  final ElectricityService electricity;
  final BillPhotoService photos;
  final ElectricityPeriod existing;
  final List<ElectricityPeriod> existingPeriods;
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
  late DateTime _recordedAt;
  Uint8List? _photoBytes;
  String? _error;
  String? _duplicateHint;
  bool _editing = false;
  bool _saving = false;

  bool get _isMeter => widget.home.trackingMode == TrackingMode.meter;

  void _updateDuplicateHint() {
    final duplicate = findPeriodForMonth(
      widget.existingPeriods,
      _month,
      excludeId: widget.existing.id,
    );
    _duplicateHint = duplicate == null ? null : S.duplicatePeriodHint;
  }

  Future<bool> _confirmDuplicateIfNeeded() async {
    final duplicate = findPeriodForMonth(
      widget.existingPeriods,
      _month,
      excludeId: widget.existing.id,
    );
    if (duplicate == null) return true;
    return confirmDuplicatePeriodMonth(context, _month);
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _month = existing.periodMonth;
    _recordedAt = existing.recordedAt.toLocal();
    _previous = TextEditingController(
      text: existing.previousKwh?.toString() ?? "",
    );
    _next = TextEditingController(text: existing.newKwh?.toString() ?? "");
    _amount = TextEditingController(text: VndFormat.input(existing.amountVnd));
    _note = TextEditingController(text: existing.note ?? "");
    _updateDuplicateHint();
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
    final prev = ElectricityValidation.parseKwh(_previous.text);
    final neu = ElectricityValidation.parseKwh(_next.text);
    if (prev == null || neu == null) return;
    final used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
    _amount.text = VndFormat.input(
      MeterMath.amountVnd(consumptionKwh: used, kwhRate: widget.home.kwhRate),
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
        prev = ElectricityValidation.parseKwh(_previous.text);
        neu = ElectricityValidation.parseKwh(_next.text);
        final error = ElectricityValidation.validateMeterReadings(prev, neu);
        if (error != null) {
          setState(() => _error = _saveErrorMessage(error));
          return;
        }
        used = MeterMath.consumption(previousKwh: prev!, newKwh: neu!);
      } else {
        final error = ElectricityValidation.validateInvoiceAmount(money);
        if (error != null) {
          setState(() => _error = _saveErrorMessage(error));
          return;
        }
      }
      if (!await _confirmDuplicateIfNeeded()) return;

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
        amountVnd:
            _isMeter
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
        editingId: widget.existing.id,
        editingOriginalMonth: widget.existing.periodMonth,
        recordedAt: _recordedAt,
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
    final picked = await showMonthPicker(context: context, initialDate: _month);
    if (picked != null) {
      setState(() {
        _month = DateTime(picked.year, picked.month);
        _updateDuplicateHint();
      });
    }
  }

  Future<void> _pickRecordedAt() async {
    if (!_editing) return;
    final picked = await showDateTimePicker(
      context: context,
      initialDateTime: _recordedAt,
    );
    if (picked != null) {
      setState(() => _recordedAt = picked);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
    final hasPhoto =
        widget.existing.photoPath != null &&
        widget.existing.photoPath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── header ────────────────────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                FormTitle(title: _editing ? S.editPeriod : S.detailPeriod),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    color: colors.textSecondary,
                    tooltip: S.cancel,
                  ),
                ),
              ],
            ),
            if (!_editing) ...[
              // ── VIEW MODE ─────────────────────────────────────────────
              _PeriodDetailView(
                existing: widget.existing,
                colors: colors,
                isMeter: _isMeter,
                onViewPhoto:
                    hasPhoto
                        ? () => showBillPhotoViewer(
                          context: context,
                          photoPath: widget.existing.photoPath!,
                          photos: widget.photos,
                        )
                        : null,
              ),
            ] else ...[
              // ── EDIT MODE ─────────────────────────────────────────────
              LabeledPickerField(
                label: S.month,
                value: DateFormat("MM/yyyy").format(_month),
                enabled: true,
                onTap: _pickMonth,
              ),
              if (_duplicateHint != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    _duplicateHint!,
                    style: TextStyle(color: colors.warning),
                  ),
                ),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledPickerField(
                label: S.recordedAt,
                value: DateFormat("dd/MM/yyyy HH:mm").format(_recordedAt),
                enabled: true,
                onTap: _pickRecordedAt,
                trailing: const Icon(Icons.schedule_outlined),
              ),
              if (_isMeter) ...[
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
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(
                        _photoBytes != null ? "${S.photo} ✓" : S.pickPhoto,
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
                                  photoPath: widget.existing.photoPath!,
                                  photos: widget.photos,
                                ),
                        icon: const Icon(Icons.image_outlined),
                        label: Text(
                          _photoBytes != null ? S.pickPhoto : S.hasPhoto,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(_error!, style: TextStyle(color: colors.error)),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child:
                      _editing
                          ? FilledButton(
                            onPressed: _saving ? null : _save,
                            child: const Text(S.save),
                          )
                          : FilledButton(
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

String _fmtKwhForm(double? kwh) {
  if (kwh == null) return "–";
  final rounded = kwh.round();
  return kwh == rounded.toDouble()
      ? rounded.toString()
      : kwh.toStringAsFixed(1);
}

// ── Period detail view (read-only, 2-column info layout) ───────────────────

class _PeriodDetailView extends StatelessWidget {
  const _PeriodDetailView({
    required this.existing,
    required this.colors,
    required this.isMeter,
    required this.onViewPhoto,
  });

  final ElectricityPeriod existing;
  final AppColorScheme colors;
  final bool isMeter;
  final VoidCallback? onViewPhoto;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat("MM/yyyy").format(existing.periodMonth);
    final recordedLabel = DateFormat(
      "dd/MM/yyyy HH:mm",
    ).format(existing.recordedAt.toLocal());
    final hasNote = existing.note != null && existing.note!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        // ── tháng ─────────────────────────────────────────────────────────
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: S.month,
          value: monthLabel,
          colors: colors,
        ),
        const Divider(height: AppSpacing.md),
        // ── số tiền ───────────────────────────────────────────────────────
        _InfoRow(
          icon: Icons.payments_outlined,
          label: S.amount,
          value: VndFormat.format(existing.amountVnd),
          valueColor: colors.accent,
          valueBold: true,
          colors: colors,
        ),
        if (isMeter) ...[
          const Divider(height: AppSpacing.md),
          // ── số cũ → số mới ─────────────────────────────────────────────
          _InfoRow(
            icon: Icons.electric_meter_outlined,
            label: S.consumption,
            value:
                "${_fmtKwhForm(existing.previousKwh)} → ${_fmtKwhForm(existing.newKwh)} kWh"
                "${existing.consumptionKwh != null ? "  (${_fmtKwhForm(existing.consumptionKwh!)} kWh)" : ""}",
            colors: colors,
          ),
        ],
        const Divider(height: AppSpacing.md),
        // ── ngày ghi + ảnh (2 cột) ────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoRow(
                icon: Icons.schedule_outlined,
                label: S.recordedAt,
                value: recordedLabel,
                colors: colors,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _InfoRow(
                icon: Icons.image_outlined,
                label: S.photo,
                value: existing.photoPath != null ? S.hasPhoto : S.noPhoto,
                valueColor:
                    existing.photoPath != null
                        ? colors.success
                        : colors.textMuted,
                onTap: onViewPhoto,
                colors: colors,
              ),
            ),
          ],
        ),
        const Divider(height: AppSpacing.md),
        // ── trạng thái + ghi chú (2 cột) ─────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoRow(
                icon: Icons.check_circle_outline,
                label: S.paid,
                value: existing.isPaid ? S.paid : S.unpaid,
                valueColor:
                    existing.isPaid ? colors.success : colors.textSecondary,
                colors: colors,
              ),
            ),
            if (hasNote) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoRow(
                  icon: Icons.notes_outlined,
                  label: S.note,
                  value: existing.note!,
                  colors: colors,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
    this.valueBold = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final AppColorScheme colors;
  final Color? valueColor;
  final bool valueBold;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      style: TextStyle(
        color: valueColor ?? colors.textPrimary,
        fontWeight: valueBold ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          onTap != null
              ? DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colors.accent.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: valueWidget,
              )
              : valueWidget,
        ],
      ),
    );
  }
}
