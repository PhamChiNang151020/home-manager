import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";

Future<void> showCreateHomeDialog({
  required BuildContext context,
  required HomeService homesApi,
  required VoidCallback onCreated,
}) async {
  final name = TextEditingController();
  var mode = TrackingMode.meter;
  final rate = TextEditingController(text: "3500");

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(S.addHome),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: S.homeName),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TrackingMode>(
                  value: mode,
                  decoration: const InputDecoration(labelText: S.trackingMode),
                  items: const [
                    DropdownMenuItem(value: TrackingMode.meter, child: Text(S.modeMeter)),
                    DropdownMenuItem(value: TrackingMode.invoice, child: Text(S.modeInvoice)),
                  ],
                  onChanged: (value) => setState(() => mode = value ?? mode),
                ),
                if (mode == TrackingMode.meter)
                  TextField(
                    controller: rate,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: S.kwhRate),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(S.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  final trimmed = name.text.trim();
                  if (trimmed.isEmpty) {
                    return;
                  }
                  await homesApi.createHome(
                    name: trimmed,
                    mode: mode,
                    kwhRate: double.tryParse(rate.text.replaceAll(",", ".")) ?? 3500,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  onCreated();
                },
                child: const Text(S.save),
              ),
            ],
          );
        },
      );
    },
  );
  name.dispose();
  rate.dispose();
}
