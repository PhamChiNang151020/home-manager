import "package:flutter/material.dart";
import "package:home_manager/core/domain/invite_code.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_toast.dart";

/// Logged-in empty-home screen: account card, add home, 6-box invite code.
class EmptyHomeView extends StatefulWidget {
  const EmptyHomeView({
    super.key,
    required this.email,
    required this.onAddHome,
    required this.onSignOut,
    required this.onAcceptCode,
    required this.onAcceptToken,
    this.onJoined,
  });

  final String email;
  final VoidCallback onAddHome;
  final VoidCallback onSignOut;
  final Future<void> Function(String code) onAcceptCode;
  final Future<void> Function(String token) onAcceptToken;
  final VoidCallback? onJoined;

  @override
  State<EmptyHomeView> createState() => EmptyHomeViewState();
}

@visibleForTesting
class EmptyHomeViewState extends State<EmptyHomeView> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  String _code = "";
  String? _pendingToken;
  String? _error;
  bool _locked = false;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_locked &&
      !_submitting &&
      (_pendingToken != null || InviteCode.isValidNormalized(_code));

  void _clearErrorOnEdit() {
    if (_error != null && !_locked) {
      setState(() => _error = null);
    }
  }

  void _onFieldChanged(String raw) {
    final token = InviteCode.tokenFromPaste(raw);
    if (token != null) {
      _controller.value = const TextEditingValue(
        text: "",
        selection: TextSelection.collapsed(offset: 0),
      );
      setState(() {
        _pendingToken = token;
        _code = "";
        _error = null;
        _locked = false;
      });
      return;
    }

    final normalized = InviteCode.normalize(raw);
    final clipped =
        normalized.length > InviteCode.length
            ? normalized.substring(0, InviteCode.length)
            : normalized;
    if (_controller.text != clipped) {
      _controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
    }
    setState(() {
      _pendingToken = null;
      _code = clipped;
      if (_error != null && !_locked) _error = null;
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_pendingToken != null) {
        await widget.onAcceptToken(_pendingToken!);
      } else {
        await widget.onAcceptCode(_code);
      }
      if (!mounted) return;
      showAppToast(context, S.joinedHome);
      widget.onJoined?.call();
    } catch (e) {
      if (!mounted) return;
      final mapped = mapInviteCodeError(e);
      setState(() {
        switch (mapped) {
          case InviteCodeAcceptError.tooManyAttempts:
            _locked = true;
            _code = "";
            _pendingToken = null;
            _controller.clear();
            _error = S.inviteCodeLocked;
          case InviteCodeAcceptError.invalidOrExpired:
            _error = S.inviteCodeInvalid;
          case InviteCodeAcceptError.other:
            _error = S.inviteCodeOtherError;
        }
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.lg),
      children: [
        _AccountCard(email: widget.email),
        const SizedBox(height: AppSpacing.lg),
        Text(
          S.emptyHomeTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          S.emptyHomeHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onAddHome,
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: AppFonts.nunito,
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text(S.addHome),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _InviteCard(
          code: _code,
          error: _error,
          locked: _locked,
          submitting: _submitting,
          canSubmit: _canSubmit,
          focus: _focus,
          controller: _controller,
          onChanged: _onFieldChanged,
          onSubmit: _submit,
          onClearError: _clearErrorOnEdit,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onSignOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
              textStyle: const TextStyle(
                fontFamily: AppFonts.nunito,
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              ),
            ),
            child: const Text(S.signOut),
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accent.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.person, size: 24, color: colors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.signedInLabel,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.code,
    required this.error,
    required this.locked,
    required this.submitting,
    required this.canSubmit,
    required this.focus,
    required this.controller,
    required this.onChanged,
    required this.onSubmit,
    required this.onClearError,
  });

  final String code;
  final String? error;
  final bool locked;
  final bool submitting;
  final bool canSubmit;
  final FocusNode focus;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClearError;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasError = error != null && !locked;
    final showLockError = error != null && locked;

    return Container(
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
            S.receiveInvite,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: Text(
              S.receiveInviteHint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w400,
                color: colors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          InviteCodeBoxes(
            code: code,
            focusedIndex: locked || submitting ? -1 : code.length.clamp(0, 5),
            hasError: hasError,
            accentFocus: submitting,
            enabled: !locked && !submitting,
            focusNode: focus,
            controller: controller,
            onChanged: onChanged,
            onTap: onClearError,
          ),
          if (error != null) ...[
            SizedBox(height: locked ? 4 : 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error, size: 16, color: colors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: (hasError || showLockError) ? 12 : 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: canSubmit ? onSubmit : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                // Loading uses disabled + 60% fill (no focus overlay from
                // onPressed: () {}). Idle disabled stays at 38%.
                disabledBackgroundColor: colors.accent.withValues(
                  alpha: submitting ? 0.6 : 0.38,
                ),
                disabledForegroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontFamily: AppFonts.nunito,
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child:
                  submitting
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(S.enteringHome),
                        ],
                      )
                      : const Text(S.enterHome),
            ),
          ),
        ],
      ),
    );
  }
}

/// Six visual boxes over one hidden [TextField] (paste link or type code).
class InviteCodeBoxes extends StatelessWidget {
  const InviteCodeBoxes({
    super.key,
    required this.code,
    required this.focusedIndex,
    required this.hasError,
    required this.enabled,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
    this.accentFocus = false,
    this.onTap,
  });

  final String code;
  final int focusedIndex;
  final bool hasError;
  final bool accentFocus;
  final bool enabled;
  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;

  static const boxSize = Size(47, 48);
  static const gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: boxSize.height,
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < InviteCode.length; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                _box(context, i, colors),
              ],
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.01,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                maxLength: 512,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: const [],
                style: const TextStyle(color: Colors.transparent),
                cursorColor: Colors.transparent,
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(BuildContext context, int index, AppColorScheme colors) {
    final char = index < code.length ? code[index] : "";
    final isFocused =
        enabled &&
        (accentFocus || (focusedIndex == index && focusNode.hasFocus));
    final borderColor =
        hasError
            ? colors.error
            : (isFocused || accentFocus)
            ? colors.accent
            : colors.border;
    final borderWidth = (hasError || isFocused || accentFocus) ? 2.0 : 1.0;

    return Container(
      width: boxSize.width,
      height: boxSize.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Text(
        char,
        style: TextStyle(
          fontSize: 22,
          height: 28 / 22,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
