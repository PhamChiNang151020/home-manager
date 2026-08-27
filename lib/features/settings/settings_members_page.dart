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
import "package:home_manager/features/shared/section_header.dart";
import "package:qr_flutter/qr_flutter.dart";

class SettingsMembersPage extends StatefulWidget {
  const SettingsMembersPage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.invites,
    this.currentUserId,
    this.joinShareUrl,
  });

  final Home home;
  final HomeService homesApi;
  final InviteService invites;
  final String? currentUserId;
  final String? joinShareUrl;

  @override
  State<SettingsMembersPage> createState() => _SettingsMembersPageState();
}

class _SettingsMembersPageState extends State<SettingsMembersPage> {
  List<HomeMember> _members = [];
  HomeJoinLink? _joinLink;
  String? _error;
  bool _joinLoading = false;
  bool _joinBusy = false;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _joinLoading = widget.home.isOwner;
    _load();
  }

  String get _shareBase => widget.joinShareUrl ?? currentPwaShareUrl();

  Future<void> _load() async {
    final membersTask = widget.homesApi.listMembers(widget.home.id);
    final joinTask =
        widget.home.isOwner
            ? widget.invites.createOrGetJoinLink(widget.home.id)
            : Future<HomeJoinLink?>.value(null);

    try {
      final members = await membersTask;
      if (mounted) {
        setState(() {
          _members = members;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = "$e");
    }

    try {
      final joinLink = await joinTask;
      if (mounted) {
        setState(() {
          _joinLink = joinLink;
          _joinLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _joinLoading = false;
          _error = "$e";
        });
      }
    }
  }

  String _removeError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains("cannot remove yourself")) {
      return S.removeMemberSelf;
    }
    if (lower.contains("cannot remove") && lower.contains("owner")) {
      return S.removeMemberOwner;
    }
    if (lower.contains("only owner")) {
      return S.roleOwnerOnly;
    }
    return raw;
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

  Future<void> _removeMember(HomeMember member) async {
    final label = member.displayName ?? member.email ?? member.userId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.removeMemberTitle),
            content: Text(S.removeMemberConfirmHint(label)),
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
                child: const Text(S.removeMember),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _removing = true;
      _error = null;
    });
    try {
      await widget.homesApi.removeMember(
        homeId: widget.home.id,
        userId: member.userId,
      );
      final members = await widget.homesApi.listMembers(widget.home.id);
      if (mounted) {
        setState(() => _members = members);
        showAppToast(
          context,
          S.toastMemberRemoved,
          kind: AppToastKind.destructive,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = _removeError("$e"));
    } finally {
      if (mounted) setState(() => _removing = false);
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

    return LoadingOverlay(
      loading: _joinBusy || _removing,
      child: Scaffold(
        appBar: AppBar(title: const Text(S.settingsMembers)),
        body: MobileViewport(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              const SectionHeader(title: S.members),
              for (final member in _members)
                _MemberTile(
                  member: member,
                  canRemove:
                      owner &&
                      member.userId != widget.currentUserId &&
                      member.role != "owner",
                  onRemove: () => _removeMember(member),
                ),
              if (owner) ...[
                const SectionHeader(title: S.joinQrTitle),
                if (_joinLoading)
                  const JoinQrPlaceholder()
                else if (joinUrl != null)
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
                      child: const Text(S.joinQrCreate),
                    ),
                  ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(_error!, style: TextStyle(color: colors.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class JoinQrPlaceholder extends StatelessWidget {
  const JoinQrPlaceholder({super.key});

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
            child: const SizedBox(
              width: 220 + AppSpacing.md * 2,
              height: 220 + AppSpacing.md * 2,
              child: Center(child: AppLoader.compact()),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          S.joinQrLoading,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
      ],
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
  const _MemberTile({
    required this.member,
    required this.canRemove,
    required this.onRemove,
  });

  final HomeMember member;
  final bool canRemove;
  final VoidCallback onRemove;

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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.person_remove_rounded),
              tooltip: S.removeMember,
              color: colors.error,
            ),
          Container(
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
        ],
      ),
    );
  }
}
