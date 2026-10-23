import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:home_manager/features/auth/auth_button_theme.dart";
import "package:home_manager/features/shared/auth_card.dart";

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    required this.authService,
    this.initialEmail,
  });

  final AuthService authService;
  final String? initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _emailSent = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();

    setState(() {
      _emailError = null;
    });

    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _emailError = S.errorInvalidEmail;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        _emailSent = true;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.message.contains("rate_limit") ||
            e.message.contains("over_email_send_rate_limit")) {
          _emailError = S.errorRateLimit;
        } else {
          _emailError = S.errorGeneric;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = S.errorNetwork;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return ColoredBox(
      color: colors.bgBase,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.bgBase, colors.bgSurface],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: MobileViewport(
                  child: AuthCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _emailSent
                        ? _buildSuccessView(colors)
                        : _buildFormView(colors),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBackButton(colors),
        const Center(child: AppBrandLogo(size: 64)),
        Container(height: AppSpacing.md),
        Text(
          S.appName,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        Container(height: AppSpacing.xs),
        Text(
          S.appTagline,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(
            color: colors.textSecondary,
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(height: AppSpacing.md),
        Text(
          S.forgotPasswordTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        Container(height: AppSpacing.sm),
        Text(
          S.forgotPasswordHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        Container(height: 14),
        _buildEmailField(colors),
        Container(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
          child: FilledButton(
          onPressed: _isLoading ? null : _handleSendResetLink,
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white,
                        ),
                      ),
                    ),
                    Container(width: 8),
                    Text(S.sendResetLinkLoading, style: const TextStyle(color: Colors.white)),
                  ],
                )
              : const Text(S.sendResetLink),
        ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 8),
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accent.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.check,
              size: 28,
              color: colors.accent,
            ),
          ),
        ),
        Container(height: 14),
        Text(
          S.resetLinkSentTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
            color: colors.textPrimary,
          ),
        ),
        Container(height: AppSpacing.sm),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Nunito',
              color: colors.textSecondary,
            letterSpacing: 0,
            ),
            children: _buildResetMessageSpans(colors),
          ),
        ),
        Container(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
          child: FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(S.backToSignInButton),
        ),
        ),
      ],
    );
  }

  List<TextSpan> _buildResetMessageSpans(AppColorScheme colors) {
    final email = _emailController.text.trim();
    final message = S.resetLinkSentMessage(email);
    
    final emailStart = message.indexOf(email);
    if (emailStart == -1) {
      return [TextSpan(text: message)];
    }
    
    final beforeEmail = message.substring(0, emailStart);
    final afterEmail = message.substring(emailStart + email.length);
    
    return [
      TextSpan(text: beforeEmail),
      TextSpan(
        text: email,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      TextSpan(text: afterEmail),
    ];
  }

  Widget _buildBackButton(AppColorScheme colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 49),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(S.backToSignIn),
      ),
    );
  }

  Widget _buildEmailField(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.emailLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        Container(height: 4),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          style: const TextStyle(fontSize: 14),
          autofillHints: const [AutofillHints.email],
          autofocus: widget.initialEmail == null,
          onChanged: (_) {
            if (_emailError != null) {
              setState(() {
                _emailError = null;
              });
            }
          },
          onSubmitted: (_) => _handleSendResetLink(),
          decoration: InputDecoration(
            hintText: S.emailPlaceholder,
            errorText: null,
            errorBorder: _emailError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            focusedErrorBorder: _emailError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            border: _emailError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            enabledBorder: _emailError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 20),
          padding: const EdgeInsets.only(top: 4),
          alignment: Alignment.centerLeft,
          child: _emailError != null
              ? Padding(
                  padding: EdgeInsets.zero,
                  child: Text(
                    _emailError!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.error,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
