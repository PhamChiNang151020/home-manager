import "dart:typed_data";

import "package:flutter/material.dart";
import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/electricity_service.dart";
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
}) async {
  final isMeter = home.trackingMode == TrackingMode.meter;
  var month = existing?.periodMonth ?? DateTime(DateTime.now().year, DateTime.now().month);
  final previous = TextEditingController(
    text: (existing?.previousKwh ?? previousPeriod?.newKwh)?.toString() ?? "",
  );
  final next = TextEditingController(text: existing?.newKwh?.toString() ?? "");
  final amount = TextEditingController(
    text: existing == null ? "" : existing.amountVnd.toStringAsFixed(0),
  );
  final note = TextEditingController(text: existing?.note ?? "");
  Uint8List? photoBytes;
  String? error;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            void recompute() {
              if (!isMeter) {
                return;
              }
              final prev = double.tryParse(previous.text.replaceAll(",", "."));
              final neu = double.tryParse(next.text.replaceAll(",", "."));
              if (prev == null || neu == null) {
                return;
              }
              final used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
              amount.text = MeterMath.amountVnd(
                consumptionKwh: used,
                kwhRate: home.kwhRate,
              ).toStringAsFixed(0);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    existing == null ? S.addPeriod : S.editPeriod,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(S.month),
                    subtitle: Text(DateFormat("MM/yyyy").format(month)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: month,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => month = DateTime(picked.year, picked.month));
                      }
                    },
                  ),
                  if (isMeter) ...[
                    if (previousPeriod == null && existing == null)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(S.firstPeriodHint),
                      ),
                    TextField(
                      controller: previous,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: S.previousKwh),
                      onChanged: (_) => setState(recompute),
                    ),
                    TextField(
                      controller: next,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: S.newKwh),
                      onChanged: (_) => setState(recompute),
                    ),
                  ],
                  TextField(
                    controller: amount,
                    readOnly: isMeter,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: S.amount),
                  ),
                  TextField(
                    controller: note,
                    decoration: const InputDecoration(labelText: S.note),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final file = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                        maxWidth: 1600,
                      );
                      if (file != null) {
                        photoBytes = await file.readAsBytes();
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.photo_camera),
                    label: Text(photoBytes == null ? S.pickPhoto : "${S.photo} ✓"),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      try {
                        double? prev;
                        double? neu;
                        double? used;
                        final money = double.tryParse(amount.text.replaceAll(".", "").replaceAll(",", "."));
                        if (isMeter) {
                          prev = double.tryParse(previous.text.replaceAll(",", "."));
                          neu = double.tryParse(next.text.replaceAll(",", "."));
                          if (prev == null || neu == null) {
                            setState(() => error = S.firstPeriodHint);
                            return;
                          }
                          if (neu < prev) {
                            setState(() => error = S.invalidReadings);
                            return;
                          }
                          used = MeterMath.consumption(previousKwh: prev, newKwh: neu);
                        } else if (money == null || money <= 0) {
                          setState(() => error = S.invalidAmount);
                          return;
                        }
                        String? photoPath = existing?.photoPath;
                        if (photoBytes != null) {
                          photoPath = await photos.upload(
                            homeId: home.id,
                            month: month,
                            bytes: photoBytes!,
                          );
                        }
                        await electricity.upsert(
                          homeId: home.id,
                          periodMonth: month,
                          amountVnd: isMeter
                              ? MeterMath.amountVnd(
                                  consumptionKwh: used!,
                                  kwhRate: home.kwhRate,
                                )
                              : money!,
                          previousKwh: prev,
                          newKwh: neu,
                          consumptionKwh: used,
                          photoPath: photoPath,
                          note: note.text.trim().isEmpty ? null : note.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        onSaved();
                      } catch (e) {
                        setState(() => error = "$e");
                      }
                    },
                    child: const Text(S.save),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  previous.dispose();
  next.dispose();
  amount.dispose();
  note.dispose();
}
