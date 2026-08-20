import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/domain/pwa_install.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/pwa_install_runtime.dart";
import "package:home_manager/core/services/pwa_open_url.dart";
import "package:home_manager/core/services/pwa_runtime.dart";
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
    final resolvedSurface = surface ?? currentPwaInstallSurface();
    final steps = _stepsFor(resolvedSurface);
    final ua = pwaUserAgent();
    final showIosWebClip = PwaInstall.showsIosInstallUi(
      surface: resolvedSurface,
      userAgent: ua,
    );
    final showIosProfileGuide = PwaInstall.showsIosProfileGuide(
      surface: resolvedSurface,
      userAgent: ua,
    );
    final appUrl = shareUrl ?? currentPwaShareUrl();
    final qrUrl = resolveQrUrl(
      surface: resolvedSurface,
      userAgent: ua,
      appUrl: appUrl,
      iosInstallLandingUrl: currentIosInstallLandingUrl(),
    );
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsInstall)),
      body: MobileViewport(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            const Center(child: AppBrandLogo(size: 56)),
            if (showIosWebClip) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      S.installIosWebClip,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      S.installIosWebClipSteps,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed:
                          () => _installIosWebClip(context, resolvedSurface),
                      icon: const Icon(Icons.phone_iphone),
                      label: const Text(S.installIosWebClip),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (showIosProfileGuide) ...[
              _IosProfileRemovalCallout(colors: colors),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              S.installQrSectionTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              S.installQrHint,
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
                    data: qrUrl,
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
                await Clipboard.setData(ClipboardData(text: qrUrl));
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

  static void _installIosWebClip(
    BuildContext context,
    PwaInstallSurface surface,
  ) {
    if (surface == PwaInstallSurface.iosInApp) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(S.installIosWebClipInApp)));
      return;
    }
    openExternalUrl(currentIosInstallLandingUrl());
  }

  static String resolveQrUrl({
    required PwaInstallSurface surface,
    required String userAgent,
    required String appUrl,
    required String iosInstallLandingUrl,
  }) {
    return PwaInstall.showsIosInstallUi(surface: surface, userAgent: userAgent)
        ? iosInstallLandingUrl
        : appUrl;
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

class _IosProfileRemovalCallout extends StatelessWidget {
  const _IosProfileRemovalCallout({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.warningMuted(0.22),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colors.warning, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: colors.warning, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    S.installIosProfileRemoveTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              S.installIosProfileRemoveSteps,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              S.installIosProfileRemoveNote,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
