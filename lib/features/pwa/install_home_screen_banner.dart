import "package:flutter/material.dart";
import "package:home_manager/core/domain/pwa_install.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/pwa_install_runtime.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/pwa/install_home_screen_page.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:shared_preferences/shared_preferences.dart";

class InstallHomeScreenBanner extends StatefulWidget {
  const InstallHomeScreenBanner({
    super.key,
    this.surface,
    this.dismissedInitially,
  });

  final PwaInstallSurface? surface;
  final bool? dismissedInitially;

  @override
  State<InstallHomeScreenBanner> createState() =>
      _InstallHomeScreenBannerState();
}

class _InstallHomeScreenBannerState extends State<InstallHomeScreenBanner> {
  bool? _dismissed;

  PwaInstallSurface get _surface =>
      widget.surface ?? currentPwaInstallSurface();

  @override
  void initState() {
    super.initState();
    final initial = widget.dismissedInitially;
    if (initial != null) {
      _dismissed = initial;
      return;
    }
    _loadDismissed();
  }

  Future<void> _loadDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dismissed = prefs.getBool(PwaInstall.bannerDismissedKey) ?? false;
    });
  }

  Future<void> _dismiss() async {
    setState(() => _dismissed = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PwaInstall.bannerDismissedKey, true);
  }

  @override
  Widget build(BuildContext context) {
    final surface = _surface;
    if (surface == PwaInstallSurface.hidden || _dismissed != false) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;
    final body = switch (surface) {
      PwaInstallSurface.iosSafari => S.installBannerIosSafari,
      PwaInstallSurface.iosInApp => S.installBannerIosInApp,
      PwaInstallSurface.androidChrome => S.installBannerAndroid,
      PwaInstallSurface.androidInApp => S.installBannerAndroidInApp,
      PwaInstallSurface.hidden => "",
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.add_to_home_screen, color: colors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.installBannerTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          body,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: _dismiss,
                    child: const Text(S.installDismiss),
                  ),
                  FilledButton(
                    onPressed:
                        () => Navigator.of(context).push(
                          AppPageRoute<void>(
                            page: InstallHomeScreenPage(surface: surface),
                          ),
                        ),
                    child: const Text(S.installGuide),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
