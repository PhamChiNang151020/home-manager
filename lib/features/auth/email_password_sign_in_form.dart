import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
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
        SizedBox(height: AppSpacing.md),
        Text(
          S.signInHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildEmailField(colors),
        SizedBox(height: AppSpacing.md),
        _buildPasswordField(colors),
        _buildForgotPasswordButton(colors),
        if (_generalError != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            _generalError!,
            style: TextStyle(
              color: colors.error,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        SizedBox(height: AppSpacing.sm),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(S.signInLoading, style: const TextStyle(color: Colors.white)),
                  ],
                )
              : const Text(S.signIn),
        ),
        SizedBox(height: AppSpacing.lg),
        _buildDivider(colors),
        SizedBox(height: AppSpacing.lg),
        _buildGoogleButton(colors),
        SizedBox(height: AppSpacing.sm),
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
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
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
        Container(
          constraints: const BoxConstraints(minHeight: 20),
          padding: const EdgeInsets.only(top: 4),
          alignment: Alignment.centerLeft,
          child: _emailError != null
              ? Text(
                  _emailError!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.33,
                    color: colors.error,
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
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
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
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFF475569),
              ),
              onPressed: () {
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
              ? Text(
                  _passwordError!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.33,
                    color: colors.error,
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
          onPressed: widget.onForgotPassword,
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
      onPressed: () async {
        await widget.authService.signInWithGoogle();
      },
      icon: SvgPicture.asset(
        'assets/brand/google_logo_18.svg',
        width: 18,
        height: 18,
      ),
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
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: widget.onCreateAccount,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text(S.createAccount),
        ),
      ],
    );
  }
}
