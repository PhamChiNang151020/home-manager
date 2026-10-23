import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class EmailPasswordSignInForm extends StatefulWidget {
  const EmailPasswordSignInForm({
    super.key,
    required this.authService,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  final AuthService authService;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  @override
  State<EmailPasswordSignInForm> createState() =>
      _EmailPasswordSignInFormState();
}

class _EmailPasswordSignInFormState extends State<EmailPasswordSignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  void _validateEmail() {
    setState(() {
      if (_emailController.text.trim().isEmpty) {
        _emailError = null;
      } else if (!_isValidEmail(_emailController.text.trim())) {
        _emailError = S.errorInvalidEmail;
      } else {
        _emailError = null;
      }
    });
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) _emailError = S.errorInvalidEmail;
        if (password.isEmpty) _passwordError = S.errorInvalidCredentials;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _emailError = S.errorInvalidEmail;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.message.contains("Invalid login credentials") ||
            e.message.contains("invalid_credentials")) {
          _passwordError = S.errorInvalidCredentials;
        } else if (e.message.contains("Email not confirmed")) {
          _generalError = S.errorGeneric;
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          S.signInHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEmailField(colors),
        const SizedBox(height: AppSpacing.md),
        _buildPasswordField(colors),
        _buildForgotPasswordButton(colors),
        if (_generalError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _generalError!,
            style: TextStyle(
              color: colors.error,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        FilledButton(
          onPressed: _isLoading ? null : _handleSignIn,
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.bgBase,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(S.signInLoading),
                  ],
                )
              : const Text(S.signIn),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildDivider(colors),
        const SizedBox(height: AppSpacing.lg),
        _buildGoogleButton(colors),
        const SizedBox(height: AppSpacing.sm),
        _buildCreateAccountFooter(colors),
      ],
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
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) {
            if (_emailError != null) {
              setState(() {
                _emailError = null;
              });
            }
          },
          onSubmitted: (_) {
            _passwordFocusNode.requestFocus();
          },
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
        SizedBox(
          height: 16,
          child: _emailError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
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

  Widget _buildPasswordField(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.passwordLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          autofillHints: const [AutofillHints.password],
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() {
                _passwordError = null;
              });
            }
          },
          onSubmitted: (_) => _handleSignIn(),
          decoration: InputDecoration(
            hintText: S.passwordPlaceholder,
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
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
        SizedBox(
          height: 16,
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

  Widget _buildForgotPasswordButton(AppColorScheme colors) {
    return Align(
      alignment: Alignment.centerRight,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: TextButton(
          onPressed: _isLoading ? null : widget.onForgotPassword,
          child: Text(S.forgotPassword),
        ),
      ),
    );
  }

  Widget _buildDivider(AppColorScheme colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            S.orDivider,
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton(AppColorScheme colors) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () async {
        await widget.authService.signInWithGoogle();
      },
      icon: const Icon(Icons.g_mobiledata, size: 20),
      label: const Text(S.signInGoogle),
    );
  }

  Widget _buildCreateAccountFooter(AppColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.noAccount,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _isLoading ? null : widget.onCreateAccount,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(S.createAccount),
        ),
      ],
    );
  }
}
