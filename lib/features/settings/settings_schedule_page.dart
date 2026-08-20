import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/ics_export_service.dart";
import "package:home_manager/core/services/web_file_saver.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

class SettingsSchedulePage extends StatefulWidget {
  const SettingsSchedulePage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.onChanged,
  });

  final Home home;
  final HomeService homesApi;
  final VoidCallback onChanged;

  @override
  State<SettingsSchedulePage> createState() => _SettingsSchedulePageState();
}

class _SettingsSchedulePageState extends State<SettingsSchedulePage> {
  late final TextEditingController _photoDay;
  late final TextEditingController _payday;
  late final TextEditingController _remind;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _photoDay = TextEditingController(
      text: widget.home.photoDueDay?.toString() ?? "",
    );
    _payday = TextEditingController(
      text: widget.home.paydayDay?.toString() ?? "",
    );
    _remind = TextEditingController(
      text: widget.home.remindDay?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    _photoDay.dispose();
    _payday.dispose();
    _remind.dispose();
    super.dispose();
  }

  int? _day(TextEditingController c) {
    final text = c.text.trim();
    if (text.isEmpty) return null;
    final value = int.tryParse(text);
    if (value == null || value < 1 || value > 31) return null;
    return value;
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
        photoDueDay: _day(_photoDay),
        paydayDay: _day(_payday),
        remindDay: _day(_remind),
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
      appBar: AppBar(title: const Text(S.settingsSchedule)),
      body: MobileViewport(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            LabeledTextField(
              label: S.photoDueDay,
              controller: _photoDay,
              enabled: owner,
              keyboardType: TextInputType.number,
              helperText: S.dayOfMonth,
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(
              label: S.payday,
              controller: _payday,
              enabled: owner,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.formFieldGap),
            LabeledTextField(
              label: S.remindDay,
              controller: _remind,
              enabled: owner,
              keyboardType: TextInputType.number,
            ),
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
                onPressed: _saving ? null : _save,
                child: const Text(S.save),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                final ics = const IcsExportService().buildCalendar(widget.home);
                saveTextFile(filename: "${widget.home.name}.ics", content: ics);
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text(S.exportIcs),
            ),
          ],
        ),
      ),
    );
  }
}
