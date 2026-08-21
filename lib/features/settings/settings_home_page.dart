import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/labeled_money_field.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

class SettingsHomePage extends StatefulWidget {
  const SettingsHomePage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.onChanged,
  });

  final Home home;
  final HomeService homesApi;
  final VoidCallback onChanged;

  @override
  State<SettingsHomePage> createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends State<SettingsHomePage> {
  late final TextEditingController _name;
  late final TextEditingController _rate;
  late final TextEditingController _m3Rate;
  String? _error;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.home.name);
    _rate = TextEditingController(text: VndFormat.input(widget.home.kwhRate));
    _m3Rate = TextEditingController(text: VndFormat.input(widget.home.m3Rate));
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    _m3Rate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!widget.home.isOwner) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.homesApi.updateSettings(
        homeId: widget.home.id,
        name: _name.text.trim(),
        kwhRate:
            widget.home.trackingMode == TrackingMode.meter
                ? VndFormat.parse(_rate.text)
                : null,
        m3Rate:
            widget.home.trackingMode == TrackingMode.meter
                ? VndFormat.parse(_m3Rate.text)
                : null,
      );
      widget.onChanged();
      if (mounted) {
        popWithAppToast(context, S.toastHomeSaved);
      }
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteHome() async {
    if (!widget.home.isOwner || _deleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.deleteHome),
            content: const Text(S.deleteHomeConfirm),
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

    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await widget.homesApi.deleteHome(widget.home.id);
      widget.onChanged();
      if (mounted) {
        popWithAppToast(
          context,
          S.toastHomeDeleted,
          result: true,
          kind: AppToastKind.destructive,
        );
      }
    } catch (e, st) {
      AppLog.e("Delete home failed", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _deleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.home.isOwner;
    final colors = context.appColors;
    final busy = _saving || _deleting;
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsHome)),
      body: MobileViewport(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            LabeledTextField(
              label: S.homeName,
              controller: _name,
              enabled: owner && !busy,
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            Text(
              S.trackingMode,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.home.trackingMode == TrackingMode.meter
                  ? S.modeMeter
                  : S.modeInvoice,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.home.trackingMode == TrackingMode.meter
                  ? S.modeMeterHint
                  : S.modeInvoiceHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
            if (widget.home.trackingMode == TrackingMode.meter) ...[
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledMoneyField(
                label: S.kwhRate,
                controller: _rate,
                enabled: owner && !busy,
                suffix: "đ/kWh",
              ),
              const SizedBox(height: AppSpacing.formFieldGap),
              LabeledMoneyField(
                label: S.m3Rate,
                controller: _m3Rate,
                enabled: owner && !busy,
                suffix: "đ/m³",
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (owner) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: busy ? null : _save,
                child: const Text(S.save),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                S.deleteHomeHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: busy ? null : _deleteHome,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                ),
                child: Text(_deleting ? S.deletingHome : S.deleteHome),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
