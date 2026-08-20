import "package:flutter/material.dart";

/// Neon PNG mark. Does not tint — glow is baked into the file.
class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon(this.assetPath, {super.key, this.size = 24});

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    );
  }
}
