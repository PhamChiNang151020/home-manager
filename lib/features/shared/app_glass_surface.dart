import "dart:ui";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

enum _GlassKind { light, blurred }

/// Glassmorphism panel. Prefer [AppGlassSurface.light] inside scrolling lists
/// (no [BackdropFilter]) and [AppGlassSurface.blurred] for stationary chrome.
class AppGlassSurface extends StatelessWidget {
  const AppGlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.blurSigma,
  }) : _kind = _GlassKind.light;

  const AppGlassSurface.light({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.onTap,
  }) : blurSigma = null,
       _kind = _GlassKind.light;

  const AppGlassSurface.blurred({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.blurSigma,
  }) : _kind = _GlassKind.blurred;

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? blurSigma;
  final _GlassKind _kind;

  static double get defaultBlurSigma => kIsWeb ? 14 : 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.cardRadius);
    final content =
        padding == null ? child : Padding(padding: padding!, child: child);

    if (!colors.glass) {
      return Material(
        color: colors.bgSurface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child:
            onTap == null
                ? content
                : InkWell(onTap: onTap, borderRadius: radius, child: content),
      );
    }

    final panel =
        _kind == _GlassKind.blurred
            ? _BlurredPanel(
              colors: colors,
              radius: radius,
              sigma: blurSigma ?? defaultBlurSigma,
              child: content,
            )
            : _LightPanel(colors: colors, radius: radius, child: content);

    if (onTap == null) return panel;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: radius, child: panel),
    );
  }
}

class _BlurredPanel extends StatelessWidget {
  const _BlurredPanel({
    required this.colors,
    required this.radius,
    required this.sigma,
    required this.child,
  });

  final AppColorScheme colors;
  final BorderRadius radius;
  final double sigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.glassFill,
              borderRadius: radius,
              border: Border.all(color: colors.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LightPanel extends StatelessWidget {
  const _LightPanel({
    required this.colors,
    required this.radius,
    required this.child,
  });

  final AppColorScheme colors;
  final BorderRadius radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = Color.lerp(colors.glassFill, Colors.white, 0.08)!;
    final bottom = Color.lerp(colors.glassFill, colors.bgBase, 0.35)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [top, bottom],
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha:
                Theme.of(context).brightness == Brightness.dark ? 0.14 : 0.35,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}
