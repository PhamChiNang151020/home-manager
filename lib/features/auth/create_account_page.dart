import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:home_manager/features/shared/auth_card.dart";

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  Future<void> _handleCreateAccount() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool hasError = false;

    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _emailError = S.errorInvalidEmail;
      });
      hasError = true;
    }

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
      await widget.authService.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.message.contains("User already registered") ||
            e.message.contains("user_already_exists") ||
            e.message.contains("email_exists") ||
            e.message.contains("already been registered")) {
          _emailError = S.errorEmailExists;
        } else if (e.message.contains("weak_password") ||
            e.message.contains("Password")) {
          _passwordError = S.errorPasswordTooShort;
        } else if (e.message.contains("rate_limit") ||
            e.message.contains("over_request_rate_limit") ||
            e.message.contains("over_email_send_rate_limit")) {
          _passwordError = S.errorRateLimit;
        } else {
          _passwordError = S.errorGeneric;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _passwordError = S.errorNetwork;
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
                          S.createAccount,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Container(height: AppSpacing.md),
                        _buildEmailField(colors),
                        Container(height: AppSpacing.md),
                        _buildPasswordField(colors),
                        Container(height: AppSpacing.md),
                        _buildConfirmPasswordField(colors),
                        Container(height: AppSpacing.sm),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
                          child: FilledButton(
                          onPressed: _isLoading ? null : _handleCreateAccount,
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
                                    Text(S.createAccountLoading, style: const TextStyle(color: Colors.white)),
                                  ],
                                )
                              : const Text(S.createAccount),
                        ),
                        ),
                        Container(height: AppSpacing.md),
                        _buildSignInFooter(colors),
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

  Widget _buildBackButton(AppColorScheme colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 24),
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
            hintText: S.passwordPlaceholder8,
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
          S.passwordConfirmLabel,
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
          onSubmitted: (_) => _handleCreateAccount(),
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

  Widget _buildSignInFooter(AppColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.hasAccount,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
        Container(width: 4),
        TextButton(
          onPressed: _isLoading ? () {} : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
          ),
          child: const Text(S.signIn),
        ),
      ],
    );
  }
}
