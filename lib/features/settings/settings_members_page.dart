import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

class SettingsMembersPage extends StatefulWidget {
  const SettingsMembersPage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.invites,
  });

  final Home home;
  final HomeService homesApi;
  final InviteService invites;

  @override
  State<SettingsMembersPage> createState() => _SettingsMembersPageState();
}

class _SettingsMembersPageState extends State<SettingsMembersPage> {
  final _inviteEmail = TextEditingController();
  List<HomeMember> _members = [];
  List<HomeInvite> _pending = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  @override
  void dispose() {
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
      if (mounted) setState(() => _error = "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = widget.home.isOwner;
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsMembers)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(S.members, style: Theme.of(context).textTheme.titleMedium),
          for (final member in _members)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(member.displayName ?? member.email ?? member.userId),
              subtitle: Text(member.role == "owner" ? S.owner : S.member),
            ),
          if (owner) ...[
            const SizedBox(height: AppSpacing.md),
            Text(S.invite, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            LabeledTextField(
              label: S.inviteEmail,
              controller: _inviteEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  final email = _inviteEmail.text.trim();
                  if (email.isEmpty) return;
                  try {
                    await widget.invites.invite(
                      homeId: widget.home.id,
                      email: email,
                    );
                    _inviteEmail.clear();
                    await _loadPeople();
                  } catch (e) {
                    setState(() => _error = "$e");
                  }
                },
                child: const Text(S.sendInvite),
              ),
            ),
            if (_pending.isNotEmpty)
              Text(S.pendingInvites, style: Theme.of(context).textTheme.titleSmall),
            for (final invite in _pending)
              ListTile(title: Text(invite.email), dense: true),
          ],
          if (_error != null)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ),
    );
  }
}
