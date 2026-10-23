import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:home_manager/features/shared/auth_card.dart";

class SetNewPasswordPage extends StatefulWidget {
  const SetNewPasswordPage({
    super.key,
    required this.authService,
    required this.email,
  });

  final AuthService authService;
  final String email;

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    bool hasError = false;

    if (password.length < 8) {
      setState(() {
        _passwordError = S.errorPasswordTooShort;
      });
      hasError = true;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = S.errorPasswordMismatch;
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.updatePassword(password);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.message.contains("same_password") ||
            e.message.contains("Same password")) {
          _generalError = S.errorSamePassword;
        } else if (e.message.contains("weak_password") ||
            e.message.contains("Password")) {
          _passwordError = S.errorPasswordTooShort;
        } else if (e.message.contains("expired") ||
            e.message.contains("invalid") ||
            e.statusCode == "401") {
          _generalError = S.errorLinkExpired;
        } else if (e.message.contains("rate_limit") ||
            e.message.contains("over_request_rate_limit")) {
          _generalError = S.errorRateLimit;
        } else {
          _generalError = S.errorGeneric;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = S.errorNetwork;
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                          S.setPasswordTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Container(height: AppSpacing.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Nunito',
                                color: colors.textSecondary,
                                letterSpacing: 0,
                              ),
                              children: [
                                const TextSpan(text: "Cho tài khoản "),
                                TextSpan(
                                  text: widget.email,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(height: AppSpacing.md),
                        _buildPasswordField(colors),
                        Container(height: AppSpacing.md),
                        _buildConfirmPasswordField(colors),
                        if (_generalError != null) ...[
                          Container(height: AppSpacing.sm),
                          Text(
                            _generalError!,
                            style: TextStyle(
                              color: colors.error,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_generalError == S.errorLinkExpired) ...[
                            Container(height: AppSpacing.xs),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    },
                              child: const Text(S.forgotPassword),
                            ),
                          ],
                        ],
                        Container(height: AppSpacing.sm),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
                          child: FilledButton(
                          onPressed: _isLoading ? null : _handleSetPassword,
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
                                    Text(S.setPasswordLoading, style: const TextStyle(color: Colors.white)),
                                  ],
                                )
                              : const Text(S.setPasswordButton),
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.passwordNewLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        Container(height: 4),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() {
                _passwordError = null;
              });
            }
          },
          onSubmitted: (_) {
          },
          decoration: InputDecoration(
            hintText: S.passwordNewPlaceholder,
            errorText: null,
            errorBorder: _passwordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            focusedErrorBorder: _passwordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            border: _passwordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            enabledBorder: _passwordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
              tooltip: _obscurePassword ? S.showPassword : S.hidePassword,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 20),
          padding: const EdgeInsets.only(top: 4),
          alignment: Alignment.centerLeft,
          child: _passwordError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _passwordError!,
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

  Widget _buildConfirmPasswordField(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.passwordConfirmLabelShort,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        Container(height: 4),
        TextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) {
            if (_confirmPasswordError != null) {
              setState(() {
                _confirmPasswordError = null;
              });
            }
          },
          onSubmitted: (_) => _handleSetPassword(),
          decoration: InputDecoration(
            hintText: S.passwordConfirmPlaceholder,
            errorText: null,
            errorBorder: _confirmPasswordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            focusedErrorBorder: _confirmPasswordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            border: _confirmPasswordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            enabledBorder: _confirmPasswordError != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide(color: colors.error, width: 1.5),
                  )
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
              tooltip: _obscureConfirmPassword ? S.showPassword : S.hidePassword,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 20),
          padding: const EdgeInsets.only(top: 4),
          alignment: Alignment.centerLeft,
          child: _confirmPasswordError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _confirmPasswordError!,
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
