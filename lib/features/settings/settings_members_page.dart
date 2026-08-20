import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/section_header.dart";

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
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inviteEmail.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final members = await widget.homesApi.listMembers(widget.home.id);
      final pending =
          widget.home.isOwner
              ? await widget.invites.listPending(widget.home.id)
              : <HomeInvite>[];
      if (mounted) {
        setState(() {
          _members = members;
          _pending = pending;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    }
  }

  Future<void> _sendInvite() async {
    final email = _inviteEmail.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.invites.invite(homeId: widget.home.id, email: email);
      _inviteEmail.clear();
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _cancelInvite(HomeInvite invite) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.cancelInvite),
            content: Text("${S.cancelInviteConfirm} ${invite.email}?"),
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
    try {
      await widget.invites.cancel(invite.id);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final owner = widget.home.isOwner;

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsMembers)),
      body: MobileViewport(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          const SectionHeader(title: S.members),
          for (final member in _members) _MemberTile(member: member),
          if (owner) ...[
            const SectionHeader(title: S.invite),
            LabeledTextField(
              label: S.inviteEmail,
              controller: _inviteEmail,
              keyboardType: TextInputType.emailAddress,
              hint: "example@gmail.com",
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _sendInvite,
                icon:
                    _sending
                        ? const AppLoader.compact(color: Colors.white)
                        : const Icon(Icons.send_outlined, size: 18),
                label: Text(_sending ? S.sending : S.sendInvite),
              ),
            ),
            if (_pending.isNotEmpty) ...[
              const SectionHeader(title: S.pendingInvites),
              for (final invite in _pending)
                _PendingInviteTile(
                  invite: invite,
                  onCancel: () => _cancelInvite(invite),
                ),
            ],
          ],
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(_error!, style: TextStyle(color: colors.error)),
            ),
        ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final HomeMember member;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = member.displayName ?? member.email ?? member.userId;
    final sub =
        member.email != null && member.displayName != null
            ? member.email!
            : null;
    final isOwner = member.role == "owner";

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colors.accentMuted(),
        child: Text(
          label.isNotEmpty ? label[0].toUpperCase() : "?",
          style: TextStyle(color: colors.accent, fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(label),
      subtitle: sub != null ? Text(sub) : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isOwner ? colors.accentMuted() : colors.bgElevated,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Text(
          isOwner ? S.owner : S.member,
          style: TextStyle(
            color: isOwner ? colors.accent : colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PendingInviteTile extends StatelessWidget {
  const _PendingInviteTile({required this.invite, required this.onCancel});
  final HomeInvite invite;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: colors.warningMuted(),
        child: Icon(Icons.mail_outline, color: colors.warning, size: 18),
      ),
      title: Text(invite.email),
      subtitle: Text(
        S.pendingInviteHint,
        style: TextStyle(color: colors.textMuted, fontSize: 12),
      ),
      trailing: IconButton(
        onPressed: onCancel,
        icon: const Icon(Icons.close),
        iconSize: 18,
        color: colors.textSecondary,
        tooltip: S.cancelInvite,
      ),
    );
  }
}
