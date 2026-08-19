import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/theme/app_spacing.dart";

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
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.home.name);
    _rate = TextEditingController(text: widget.home.kwhRate.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
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
        kwhRate: widget.home.trackingMode == TrackingMode.meter
            ? double.tryParse(_rate.text.replaceAll(",", "."))
            : null,
      );
      widget.onChanged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.home.isOwner;
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsHome)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            controller: _name,
            enabled: owner,
            decoration: const InputDecoration(labelText: S.homeName),
          ),
          if (widget.home.trackingMode == TrackingMode.meter) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _rate,
              enabled: owner,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: S.kwhRate),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (owner) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text(S.save),
            ),
          ],
        ],
      ),
    );
  }
}
