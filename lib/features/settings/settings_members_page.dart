import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/domain/join_link.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/services/pwa_install_runtime.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:qr_flutter/qr_flutter.dart";

class SettingsMembersPage extends StatefulWidget {
  const SettingsMembersPage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.invites,
    this.joinShareUrl,
  });

  final Home home;
  final HomeService homesApi;
  final InviteService invites;
  final String? joinShareUrl;

  @override
  State<SettingsMembersPage> createState() => _SettingsMembersPageState();
}

class _SettingsMembersPageState extends State<SettingsMembersPage> {
  final _inviteEmail = TextEditingController();
  List<HomeMember> _members = [];
  List<HomeInvite> _pending = [];
  HomeJoinLink? _joinLink;
  String? _error;
  bool _sending = false;
  bool _joinBusy = false;

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

  String get _shareBase => widget.joinShareUrl ?? currentPwaShareUrl();

  Future<void> _load() async {
    try {
      final members = await widget.homesApi.listMembers(widget.home.id);
      final pending =
          widget.home.isOwner
              ? await widget.invites.listPending(widget.home.id)
              : <HomeInvite>[];
      HomeJoinLink? joinLink;
      if (widget.home.isOwner) {
        joinLink = await widget.invites.createOrGetJoinLink(widget.home.id);
      }
      if (mounted) {
        setState(() {
          _members = members;
          _pending = pending;
          _joinLink = joinLink;
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
      final inviteId = await widget.invites.invite(
        homeId: widget.home.id,
        email: email,
      );
      _inviteEmail.clear();
      try {
        await widget.invites.sendInviteEmail(inviteId);
        await _load();
        if (mounted) {
          showAppToast(context, S.toastInviteEmailSent(email));
        }
      } catch (e) {
        await _load();
        if (mounted) {
          setState(() => _error = "${S.toastInviteEmailFailed}\n$e");
          showAppToast(
            context,
            S.toastInviteEmailFailed,
            kind: AppToastKind.destructive,
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resendInviteEmail(HomeInvite invite) async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.invites.sendInviteEmail(invite.id);
      await _load();
      if (mounted) {
        showAppToast(context, S.toastInviteEmailSent(invite.email));
      }
    } catch (e) {
      await _load();
      if (mounted) {
        setState(() => _error = "${S.toastInviteEmailFailed}\n$e");
        showAppToast(
          context,
          S.toastInviteEmailFailed,
          kind: AppToastKind.destructive,
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _rotateJoinLink() async {
    setState(() {
      _joinBusy = true;
      _error = null;
    });
    try {
      final link = await widget.invites.createOrGetJoinLink(
        widget.home.id,
        rotate: true,
      );
      if (mounted) {
        setState(() => _joinLink = link);
        showAppToast(context, S.joinQrRotated);
      }
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _joinBusy = false);
    }
  }

  Future<void> _revokeJoinLink() async {
    setState(() {
      _joinBusy = true;
      _error = null;
    });
    try {
      await widget.invites.revokeJoinLink(widget.home.id);
      if (mounted) {
        setState(() => _joinLink = null);
        showAppToast(context, S.joinQrRevoked, kind: AppToastKind.destructive);
      }
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    } finally {
      if (mounted) setState(() => _joinBusy = false);
    }
  }

  Future<void> _copyJoinUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    showAppToast(context, S.joinQrCopied);
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
      if (mounted) {
        showAppToast(
          context,
          S.toastInviteCancelled,
          kind: AppToastKind.destructive,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final owner = widget.home.isOwner;
    final joinUrl =
        _joinLink == null
            ? null
            : JoinLink.httpsJoinUrl(
              baseUrl: _shareBase,
              token: _joinLink!.token,
            );

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsMembers)),
      body: MobileViewport(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            const SectionHeader(title: S.members),
            for (final member in _members) _MemberTile(member: member),
            if (owner) ...[
              const SectionHeader(title: S.joinQrTitle),
              if (joinUrl != null)
                JoinQrSection(
                  joinUrl: joinUrl,
                  expiresAt: _joinLink!.expiresAt,
                  busy: _joinBusy,
                  onCopy: () => _copyJoinUrl(joinUrl),
                  onRegenerate: _rotateJoinLink,
                  onRevoke: _revokeJoinLink,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: OutlinedButton(
                    onPressed: _joinBusy ? null : _rotateJoinLink,
                    child: Text(_joinBusy ? S.sending : S.joinQrCreate),
                  ),
                ),
              const SectionHeader(title: S.invite),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  S.inviteScopeHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ),
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
                    onResend:
                        _sending ? null : () => _resendInviteEmail(invite),
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

class JoinQrSection extends StatelessWidget {
  const JoinQrSection({
    super.key,
    required this.joinUrl,
    required this.expiresAt,
    required this.busy,
    required this.onCopy,
    required this.onRegenerate,
    required this.onRevoke,
  });

  final String joinUrl;
  final DateTime expiresAt;
  final bool busy;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.joinQrHint,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: QrImageView(
                data: joinUrl,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "${S.joinQrExpiryHint} ${expiresAt.toLocal().day.toString().padLeft(2, "0")}/${expiresAt.toLocal().month.toString().padLeft(2, "0")}/${expiresAt.toLocal().year}",
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: busy ? null : onCopy,
          icon: const Icon(Icons.copy_outlined, size: 18),
          label: const Text(S.joinQrCopy),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onRegenerate,
                child: const Text(S.joinQrRegenerate),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onRevoke,
                child: const Text(S.joinQrRevoke),
              ),
            ),
          ],
        ),
      ],
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
  const _PendingInviteTile({
    required this.invite,
    required this.onCancel,
    this.onResend,
  });

  final HomeInvite invite;
  final VoidCallback onCancel;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sent = invite.emailSent;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            sent
                ? colors.success.withValues(alpha: 0.2)
                : colors.warningMuted(),
        child: Icon(
          sent ? Icons.mark_email_read_outlined : Icons.mail_outline,
          color: sent ? colors.success : colors.warning,
          size: 18,
        ),
      ),
      title: Text(invite.email),
      subtitle: Text(
        sent
            ? "${S.pendingInviteHint} · ${S.inviteEmailSentHint}"
            : "${S.pendingInviteHint} · ${S.inviteEmailNotSentHint}",
        style: TextStyle(color: colors.textMuted, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onResend,
            icon: const Icon(Icons.refresh),
            iconSize: 18,
            color: colors.textSecondary,
            tooltip: S.resendInviteEmail,
          ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            iconSize: 18,
            color: colors.textSecondary,
            tooltip: S.cancelInvite,
          ),
        ],
      ),
    );
  }
}
