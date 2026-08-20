import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/domain/pwa_install.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/pwa_install_runtime.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_brand_logo.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:qr_flutter/qr_flutter.dart";

class InstallHomeScreenPage extends StatelessWidget {
  const InstallHomeScreenPage({super.key, this.surface, this.shareUrl});

  final PwaInstallSurface? surface;
  final String? shareUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final url = shareUrl ?? currentPwaShareUrl();
    final steps = _stepsFor(surface ?? currentPwaInstallSurface());
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsInstall)),
      body: MobileViewport(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            const Center(child: AppBrandLogo(size: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              S.installQrHint,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: QrImageView(
                    data: url,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Text(steps, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(S.installLinkCopied)),
                );
              },
              child: const Text(S.installCopyLink),
            ),
          ],
        ),
      ),
    );
  }

  static String _stepsFor(PwaInstallSurface surface) {
    return switch (surface) {
      PwaInstallSurface.iosInApp => S.installBannerIosInApp,
      PwaInstallSurface.androidChrome => S.installBannerAndroid,
      PwaInstallSurface.androidInApp => S.installBannerAndroidInApp,
      PwaInstallSurface.iosSafari ||
      PwaInstallSurface.hidden => S.installBannerIosSafari,
    };
  }
}
