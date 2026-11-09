import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";

/// Load-error empty: `cloud_off` tint + secondary "Thử lại".
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.error.withValues(alpha: 0.10),
            ),
            child: Icon(Icons.cloud_off, size: 28, color: colors.error),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.accent,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                ),
                child: const Text(S.retry),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
