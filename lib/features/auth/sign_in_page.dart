import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/services/join_link_store.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/auth/create_account_page.dart";
import "package:home_manager/features/auth/email_password_sign_in_form.dart";
import "package:home_manager/features/auth/forgot_password_page.dart";
import "package:home_manager/features/auth/join_invite_banner.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "package:home_manager/features/shared/auth_card.dart";

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.authService, this.error});

  final AuthService authService;
  final String? error;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  /// `null` while the pending join token is still loading.
  bool? _hasJoinInvite;

  @override
  void initState() {
    super.initState();
    _loadJoinInvite();
  }

  Future<void> _loadJoinInvite() async {
    final token = await JoinLinkStore.read();
    if (!mounted) return;
    setState(() => _hasJoinInvite = token != null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final showBanner = _hasJoinInvite == true;
    // Flutter web reports viewPadding.top == 0; keep banner below the
    // Dynamic Island band (y 83 = 59 + scroll padding 24) when a token is set.
    final viewPaddingTop = MediaQuery.viewPaddingOf(context).top;
    final extraTop = showBanner && viewPaddingTop == 0 ? 59.0 : 0.0;

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
            child: Padding(
              padding: EdgeInsets.only(top: extraTop),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: MobileViewport(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showBanner) ...[
                          const JoinInviteBanner(),
                          // Visual gap banner -> card top is 16; AuthCard has
                          // no vertical margin (unlike Material CardTheme).
                          const SizedBox(height: 16),
                        ],
                        AuthCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Center(child: AppBrandLogo(size: 64)),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                S.appName,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppSpacing.xs),
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
                              if (widget.error != null) ...[
                                SizedBox(height: AppSpacing.md),
                                Text(
                                  widget.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colors.error),
                                ),
                              ],
                              EmailPasswordSignInForm(
                                authService: widget.authService,
                                onForgotPassword: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder:
                                          (_) => ForgotPasswordPage(
                                            authService: widget.authService,
                                          ),
                                    ),
                                  );
                                },
                                onCreateAccount: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder:
                                          (_) => CreateAccountPage(
                                            authService: widget.authService,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ],
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
}

class MissingConfigPage extends StatelessWidget {
  const MissingConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: Text(S.missingConfig)),
      ),
    );
  }
}
