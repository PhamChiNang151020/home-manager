import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_icons.dart";

/// Raster brand mark (neon house). Same artwork as the PWA icon set.
class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: S.appName,
      child: Image.asset(
        AppIcons.brand,
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
