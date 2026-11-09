import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/domain/invite_code.dart";
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

  Future<void> _copyInviteCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    showAppToast(context, S.inviteCodeCopied);
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

  String _formatExpiry(DateTime expiresAt) {
    final local = expiresAt.toLocal();
    final d = local.day.toString().padLeft(2, "0");
    final m = local.month.toString().padLeft(2, "0");
    return "$d/$m/${local.year}";
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
            padding: const EdgeInsets.fromLTRB(0, AppSpacing.md, 0, AppSpacing.lg),
            children: [
              SectionHeader(title: S.members.toUpperCase(), dense: true),
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
                const SizedBox(height: AppSpacing.md),
                SectionHeader(title: S.joinQrTitle.toUpperCase(), dense: true),
                const SizedBox(height: 8),
                if (_joinLoading)
                  const JoinQrPlaceholder()
                else if (joinUrl != null)
                  JoinQrSection(
                    joinUrl: joinUrl,
                    code: _joinLink!.code,
                    expiresAt: _joinLink!.expiresAt,
                    busy: _joinBusy,
                    onCopyLink: () => _copyJoinUrl(joinUrl),
                    onCopyCode:
                        _joinLink!.code == null
                            ? null
                            : () => _copyInviteCode(_joinLink!.code!),
                    onRegenerate: _rotateJoinLink,
                    onRevoke: _revokeJoinLink,
                    expiryLabel: S.inviteCodeExpiry(
                      _formatExpiry(_joinLink!.expiresAt),
                    ),
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
              width: 148 + AppSpacing.md * 2,
              height: 148 + AppSpacing.md * 2,
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
    required this.onCopyLink,
    required this.onRegenerate,
    required this.onRevoke,
    required this.expiryLabel,
    this.code,
    this.onCopyCode,
  });

  final String joinUrl;
  final String? code;
  final DateTime expiresAt;
  final bool busy;
  final VoidCallback onCopyLink;
  final VoidCallback? onCopyCode;
  final VoidCallback onRegenerate;
  final VoidCallback onRevoke;
  final String expiryLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final displayCode =
        code == null || code!.isEmpty ? null : InviteCode.formatDisplay(code!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.joinQrHint,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (displayCode != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.inviteCodeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          displayCode,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 28,
                            height: 36 / 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 143,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed:
                              busy || onCopyCode == null ? null : onCopyCode,
                          icon: Icon(
                            Icons.content_copy,
                            size: 18,
                            color: colors.accent,
                          ),
                          label: Text(
                            S.inviteCodeCopy,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.accent,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.inputRadius,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expiryLabel,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
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
                size: 148,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: busy ? null : onCopyLink,
            icon: Icon(Icons.content_copy, size: 18, color: colors.accent),
            label: Text(
              S.joinQrCopy,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.accent,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: busy ? null : onRegenerate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.inputRadius,
                      ),
                    ),
                  ),
                  child: const Text(S.joinQrRegenerate),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: busy ? null : onRevoke,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.inputRadius,
                      ),
                    ),
                  ),
                  child: const Text(S.joinQrRevoke),
                ),
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
    final isOwner = member.role == "owner";

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.accent.withValues(alpha: 0.12),
            child: Text(
              label.isNotEmpty ? label[0].toUpperCase() : "?",
              style: TextStyle(
                color: colors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  isOwner ? S.owner : S.member,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.person_remove_rounded),
              tooltip: S.removeMember,
              color: colors.error,
            ),
        ],
      ),
    );
  }
}
