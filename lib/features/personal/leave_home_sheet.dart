import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/app_sheet.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/form_title.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

Future<bool> showLeaveHomeSheet({
  required BuildContext context,
  required Home home,
  required HomeService homesApi,
  required String currentUserId,
}) async {
  final members = await homesApi.listMembers(home.id);
  if (!context.mounted) return false;
  final left = await showAppSheet<bool>(
    context: context,
    builder:
        (context) => LeaveHomeSheet(
          home: home,
          members: members,
          currentUserId: currentUserId,
          onLeave:
              ({String? newOwnerId}) =>
                  homesApi.leaveHome(homeId: home.id, newOwnerId: newOwnerId),
        ),
  );
  return left == true;
}

class LeaveHomeButton extends StatefulWidget {
  const LeaveHomeButton({
    super.key,
    required this.home,
    required this.homesApi,
    required this.currentUserId,
    required this.onLeft,
  });

  final Home home;
  final HomeService homesApi;
  final String currentUserId;
  final VoidCallback onLeft;

  @override
  State<LeaveHomeButton> createState() => _LeaveHomeButtonState();
}

class _LeaveHomeButtonState extends State<LeaveHomeButton> {
  List<HomeMember>? _members;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    if (widget.home.isOwner) {
      _loadMembers();
    }
  }

  @override
  void didUpdateWidget(LeaveHomeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id ||
        oldWidget.home.isOwner != widget.home.isOwner) {
      _members = null;
      if (widget.home.isOwner) {
        _loadMembers();
      }
    }
  }

  Future<void> _loadMembers() async {
    try {
      final members = await widget.homesApi.listMembers(widget.home.id);
      if (mounted) setState(() => _members = members);
    } catch (_) {
      if (mounted) setState(() => _members = const []);
    }
  }

  bool get _isSoleOwner {
    if (!widget.home.isOwner) return false;
    final members = _members;
    if (members == null || members.isEmpty) return false;
    return members.every((member) => member.userId == widget.currentUserId);
  }

  bool get _waitingMembers => widget.home.isOwner && _members == null;

  Future<void> _open() async {
    if (_opening || _isSoleOwner) return;
    setState(() => _opening = true);
    try {
      final left = await showLeaveHomeSheet(
        context: context,
        home: widget.home,
        homesApi: widget.homesApi,
        currentUserId: widget.currentUserId,
      );
      if (left && mounted) widget.onLeft();
    } catch (e) {
      if (mounted) {
        showAppToast(context, "$e", kind: AppToastKind.destructive);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final soleOwner = _isSoleOwner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (soleOwner)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              S.leaveHomeSoleOwnerHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ),
        OutlinedButton(
          onPressed: soleOwner || _opening || _waitingMembers ? null : _open,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.error,
            side: BorderSide(color: colors.error),
            minimumSize: const Size.fromHeight(AppSpacing.touchMin),
          ),
          child: Text(_opening ? S.leavingHome : S.leaveHome),
        ),
      ],
    );
  }
}

class LeaveHomeSheet extends StatefulWidget {
  const LeaveHomeSheet({
    super.key,
    required this.home,
    required this.members,
    required this.currentUserId,
    required this.onLeave,
  });

  final Home home;
  final List<HomeMember> members;
  final String currentUserId;
  final Future<void> Function({String? newOwnerId}) onLeave;

  @override
  State<LeaveHomeSheet> createState() => _LeaveHomeSheetState();
}

class _LeaveHomeSheetState extends State<LeaveHomeSheet> {
  static const _noneOwner = "";

  String _newOwnerId = _noneOwner;
  String? _error;
  bool _submitting = false;

  List<HomeMember> get _others =>
      widget.members
          .where((member) => member.userId != widget.currentUserId)
          .toList();

  bool get _isSoleOwner => widget.home.isOwner && _others.isEmpty;

  String _labelOf(HomeMember member) =>
      member.displayName ?? member.email ?? member.userId;

  Future<void> _confirm() async {
    if (_submitting || _isSoleOwner) return;
    if (widget.home.isOwner && _newOwnerId.isEmpty) {
      setState(() => _error = S.leaveHomeNewOwnerHint);
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      await widget.onLeave(
        newOwnerId: widget.home.isOwner ? _newOwnerId : null,
      );
      if (!mounted) return;
      popWithAppToast(
        context,
        S.toastLeftHome,
        result: true,
        kind: AppToastKind.destructive,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "$e";
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final others = _others;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FormTitle(title: S.leaveHomeConfirmTitle),
            Text(
              S.leaveHomeConfirmHint,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
            if (_isSoleOwner) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                S.leaveHomeSoleOwnerHint,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.error),
              ),
            ] else if (widget.home.isOwner) ...[
              const SizedBox(height: AppSpacing.lg),
              LabeledDropdownField<String>(
                label: S.leaveHomeNewOwner,
                value: _newOwnerId,
                helperText: S.leaveHomeNewOwnerHint,
                items: [
                  SelectOption(
                    value: _noneOwner,
                    builder: (_) => const Text(S.leaveHomePickOwner),
                  ),
                  for (final member in others)
                    SelectOption(
                      value: member.userId,
                      builder: (_) => Text(_labelOf(member)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _newOwnerId = value;
                      _error = null;
                    });
                  }
                },
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_error!, style: TextStyle(color: colors.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _submitting || _isSoleOwner ? null : _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                minimumSize: const Size.fromHeight(AppSpacing.touchMin),
              ),
              child:
                  _submitting
                      ? const AppLoader.compact(color: Colors.white)
                      : const Text(S.leaveHomeConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
