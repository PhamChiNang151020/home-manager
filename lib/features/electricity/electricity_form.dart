import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/theme/app_colors.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:image_picker/image_picker.dart";
import "package:intl/intl.dart";

Future<void> showElectricityForm({
  required BuildContext context,
  required Home home,
  required ElectricityService electricity,
  required BillPhotoService photos,
  ElectricityPeriod? existing,
  ElectricityPeriod? previousPeriod,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
    ),
    builder: (context) {
      return _ElectricityFormSheet(
        home: home,
        electricity: electricity,
        photos: photos,
        existing: existing,
        previousPeriod: previousPeriod,
        onSaved: onSaved,
      );
    },
  );
}

class _ElectricityFormSheet extends StatefulWidget {
  const _ElectricityFormSheet({
    required this.home,
    required this.electricity,
    required this.photos,
    required this.onSaved,
    this.existing,
    this.previousPeriod,
  });

  final Home home;
  final ElectricityService electricity;
  final BillPhotoService photos;
  final ElectricityPeriod? existing;
  final ElectricityPeriod? previousPeriod;
  final VoidCallback onSaved;

  @override
  State<_ElectricityFormSheet> createState() => _ElectricityFormSheetState();
}

class _ElectricityFormSheetState extends State<_ElectricityFormSheet> {
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
    final existing = widget.existing;
    final previousPeriod = widget.previousPeriod;
    _month = existing?.periodMonth ??
        DateTime(DateTime.now().year, DateTime.now().month);
    _previous = TextEditingController(
      text: (existing?.previousKwh ?? previousPeriod?.newKwh)?.toString() ?? "",
    );
    _next = TextEditingController(text: existing?.newKwh?.toString() ?? "");
    _amount = TextEditingController(
      text: existing == null ? "" : existing.amountVnd.toStringAsFixed(0),
    );
    _note = TextEditingController(text: existing?.note ?? "");
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
    _amount.text = MeterMath.amountVnd(
      consumptionKwh: used,
      kwhRate: widget.home.kwhRate,
    ).toStringAsFixed(0);
  }

  Future<void> _save() async {
    try {
      double? prev;
      double? neu;
      double? used;
      final money = double.tryParse(
        _amount.text.replaceAll(".", "").replaceAll(",", "."),
      );
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
      String? photoPath = widget.existing?.photoPath;
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

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existing == null ? S.addPeriod : S.editPeriod,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(S.month),
              subtitle: Text(DateFormat("MM/yyyy").format(_month)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _month,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _month = DateTime(picked.year, picked.month));
                }
              },
            ),
            if (_isMeter) ...[
              if (widget.previousPeriod == null && widget.existing == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    S.firstPeriodHint,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              TextField(
                controller: _previous,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: S.previousKwh),
                onChanged: (_) => setState(_recompute),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _next,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: S.newKwh),
                onChanged: (_) => setState(_recompute),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TextField(
              controller: _amount,
              readOnly: _isMeter,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: S.amount),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: S.note),
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
                  style: const TextStyle(color: AppColors.error),
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
