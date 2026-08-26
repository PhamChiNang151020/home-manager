import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// Fixed radial blobs behind the shell so frosted chrome has something to blur.
/// Does not scroll with content.
class AppAmbientBackground extends StatelessWidget {
  const AppAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (!colors.glass) {
      return ColoredBox(color: colors.bgBase);
    }

    final accent = colors.accent;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.bgBase),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft vertical wash (kept subtle under the radials).
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(colors.bgBase, accent, 0.08)!,
                  colors.bgBase,
                ],
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -60,
            width: 280,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.28),
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            right: -100,
            width: 320,
            height: 320,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            width: 240,
            height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.12),
                    accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
