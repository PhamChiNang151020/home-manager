import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/auth/create_account_page.dart";
import "package:home_manager/features/auth/email_password_sign_in_form.dart";
import "package:home_manager/features/auth/forgot_password_page.dart";
import "package:home_manager/features/pwa/install_home_screen_banner.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "package:home_manager/features/shared/app_card.dart";

class SignInPage extends StatelessWidget {
  const SignInPage({
    super.key,
    required this.authService,
    this.error,
  });

  final AuthService authService;
  final String? error;

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const InstallHomeScreenBanner(),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Center(child: AppBrandLogo(size: 64)),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              S.appName,
                              style: Theme.of(context).textTheme.headlineMedium,
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
                            if (error != null) ...[
                              SizedBox(height: AppSpacing.md),
                              Text(
                                error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.error),
                              ),
                            ],
                            EmailPasswordSignInForm(
                              authService: authService,
                              onForgotPassword: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ForgotPasswordPage(
                                      authService: authService,
                                    ),
                                  ),
                                );
                              },
                              onCreateAccount: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CreateAccountPage(
                                      authService: authService,
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
