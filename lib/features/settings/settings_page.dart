import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/ics_export_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/services/web_file_saver.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.invites,
    required this.onChanged,
    required this.onSignOut,
  });

  final Home home;
  final HomeService homesApi;
  final InviteService invites;
  final VoidCallback onChanged;
  final VoidCallback onSignOut;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _name;
  late final TextEditingController _rate;
  late final TextEditingController _photoDay;
  late final TextEditingController _payday;
  late final TextEditingController _remind;
  late final TextEditingController _inviteEmail;
  List<HomeMember> _members = [];
  List<HomeInvite> _pending = [];
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.home.name);
    _rate = TextEditingController(text: widget.home.kwhRate.toStringAsFixed(0));
    _photoDay = TextEditingController(text: widget.home.photoDueDay?.toString() ?? "");
    _payday = TextEditingController(text: widget.home.paydayDay?.toString() ?? "");
    _remind = TextEditingController(text: widget.home.remindDay?.toString() ?? "");
    _inviteEmail = TextEditingController();
    _loadPeople();
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) {
      _name.text = widget.home.name;
      _rate.text = widget.home.kwhRate.toStringAsFixed(0);
      _photoDay.text = widget.home.photoDueDay?.toString() ?? "";
      _payday.text = widget.home.paydayDay?.toString() ?? "";
      _remind.text = widget.home.remindDay?.toString() ?? "";
      _loadPeople();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    _photoDay.dispose();
    _payday.dispose();
    _remind.dispose();
    _inviteEmail.dispose();
    super.dispose();
  }

  Future<void> _loadPeople() async {
    try {
      final members = await widget.homesApi.listMembers(widget.home.id);
      final pending = widget.home.isOwner
          ? await widget.invites.listPending(widget.home.id)
          : <HomeInvite>[];
      if (mounted) {
        setState(() {
          _members = members;
          _pending = pending;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "$e");
      }
    }
  }

  int? _day(TextEditingController c) {
    final text = c.text.trim();
    if (text.isEmpty) {
      return null;
    }
    final value = int.tryParse(text);
    if (value == null || value < 1 || value > 31) {
      return null;
    }
    return value;
  }

  Future<void> _save() async {
    if (!widget.home.isOwner) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.homesApi.updateSettings(
        homeId: widget.home.id,
        name: _name.text.trim(),
        kwhRate: double.tryParse(_rate.text.replaceAll(",", ".")),
        photoDueDay: _day(_photoDay),
        paydayDay: _day(_payday),
        remindDay: _day(_remind),
      );
      widget.onChanged();
    } catch (e) {
      setState(() => _error = "$e");
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.home.isOwner;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!owner) const Text(S.roleOwnerOnly),
        TextField(
          controller: _name,
          enabled: owner,
          decoration: const InputDecoration(labelText: S.homeName),
        ),
        if (widget.home.trackingMode == TrackingMode.meter)
          TextField(
            controller: _rate,
            enabled: owner,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: S.kwhRate),
          ),
        TextField(
          controller: _photoDay,
          enabled: owner,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.photoDueDay, helperText: S.dayOfMonth),
        ),
        TextField(
          controller: _payday,
          enabled: owner,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.payday),
        ),
        TextField(
          controller: _remind,
          enabled: owner,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: S.remindDay),
        ),
        const SizedBox(height: 12),
        if (owner)
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text(S.save),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            final ics = const IcsExportService().buildCalendar(widget.home);
            saveTextFile(filename: "${widget.home.name}.ics", content: ics);
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text(S.exportIcs),
        ),
        const Divider(height: 32),
        Text(S.members, style: Theme.of(context).textTheme.titleMedium),
        for (final member in _members)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(member.displayName ?? member.email ?? member.userId),
            subtitle: Text(member.role == "owner" ? S.owner : S.member),
          ),
        if (owner) ...[
          const SizedBox(height: 8),
          Text(S.invite, style: Theme.of(context).textTheme.titleMedium),
          TextField(
            controller: _inviteEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: S.inviteEmail),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () async {
                final email = _inviteEmail.text.trim();
                if (email.isEmpty) {
                  return;
                }
                try {
                  await widget.invites.invite(homeId: widget.home.id, email: email);
                  _inviteEmail.clear();
                  await _loadPeople();
                } catch (e) {
                  setState(() => _error = "$e");
                }
              },
              child: const Text(S.sendInvite),
            ),
          ),
          if (_pending.isNotEmpty) Text(S.pendingInvites, style: Theme.of(context).textTheme.titleSmall),
          for (final invite in _pending) ListTile(title: Text(invite.email), dense: true),
        ],
        if (_error != null)
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const Divider(height: 32),
        TextButton(
          onPressed: widget.onSignOut,
          child: const Text(S.signOut),
        ),
      ],
    );
  }
}
