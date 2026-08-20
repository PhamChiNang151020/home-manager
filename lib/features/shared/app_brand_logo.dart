import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// Vector home logo — crisp at any size, no PNG scaling artifacts.
class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, this.size = 44, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? context.appColors.accent;
    return Semantics(
      label: S.appName,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _HomeLogoPainter(color: logoColor),
        ),
      ),
    );
  }
}

class _HomeLogoPainter extends CustomPainter {
  const _HomeLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final unit = w / 100;

    // Canvas padding keeps the mark visually balanced inside square frames.
    const inset = 16.0;
    final left = inset * unit;
    final right = w - inset * unit;
    final bodyTop = 44 * unit;
    final bottom = h - inset * unit;
    final centerX = w / 2;

    // Roof
    final roof = Path()
      ..moveTo(centerX, 14 * unit)
      ..lineTo(left - 1 * unit, bodyTop + 2 * unit)
      ..lineTo(right + 1 * unit, bodyTop + 2 * unit)
      ..close();
    canvas.drawPath(roof, paint);

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left, bodyTop, right, bottom),
        Radius.circular(5 * unit),
      ),
      paint,
    );

    // Door cutout
    final doorPaint =
        Paint()
          ..color = color.withValues(alpha: 0.28)
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
    final doorW = 14 * unit;
    final doorH = 18 * unit;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, bottom - doorH / 2 - 2 * unit),
          width: doorW,
          height: doorH,
        ),
        Radius.circular(3 * unit),
      ),
      doorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
