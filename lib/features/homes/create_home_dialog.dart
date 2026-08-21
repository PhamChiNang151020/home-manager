import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

Future<void> showCreateHomeDialog({
  required BuildContext context,
  required HomeService homesApi,
  required VoidCallback onCreated,
}) async {
  final name = TextEditingController();
  var mode = TrackingMode.meter;
  final rate = TextEditingController(text: VndFormat.input(3500));

  await showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const FormTitle(title: S.addHome),
            titlePadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LabeledTextField(label: S.homeName, controller: name),
                  const SizedBox(height: AppSpacing.formFieldGap),
                  LabeledDropdownField<TrackingMode>(
                    label: S.trackingMode,
                    value: mode,
                    helperText:
                        mode == TrackingMode.meter
                            ? S.modeMeterHint
                            : S.modeInvoiceHint,
                    items: [
                      SelectOption(
                        value: TrackingMode.meter,
                        builder: (_) => const Text(S.modeMeter),
                      ),
                      SelectOption(
                        value: TrackingMode.invoice,
                        builder: (_) => const Text(S.modeInvoice),
                      ),
                    ],
                    onChanged: (value) => setState(() => mode = value ?? mode),
                  ),
                  if (mode == TrackingMode.meter) ...[
                    const SizedBox(height: AppSpacing.formFieldGap),
                    LabeledMoneyField(
                      label: S.kwhRate,
                      controller: rate,
                      suffix: "đ/kWh",
                    ),
                  ],
                ],
              ),
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
                    kwhRate: VndFormat.parse(rate.text) ?? 3500,
                  );
                  if (context.mounted) {
                    popWithAppToast(
                      context,
                      S.toastHomeCreated,
                      then: onCreated,
                    );
                  } else {
                    onCreated();
                  }
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
