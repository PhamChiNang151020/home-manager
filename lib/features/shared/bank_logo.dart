import "package:flutter/material.dart";
import "package:home_manager/core/domain/bank_brand.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// Circular bank logo from VietQR CDN, with credit-card fallback.
class BankLogo extends StatelessWidget {
  const BankLogo({super.key, required this.bankName, this.size = 28});

  final String bankName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final url = BankBrand.logoUrlForName(bankName);
    final radius = BorderRadius.circular(size * 0.22);
    if (url == null) {
      return _Fallback(size: size, color: colors.accent);
    }
    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder:
            (_, __, ___) => _Fallback(size: size, color: colors.accent),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: SizedBox(
                width: size * 0.45,
                height: size * 0.45,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.accent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.credit_card, size: size, color: color);
  }
}
