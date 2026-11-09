import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/features/shared/app_card.dart";

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

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
              color: colors.bgElevated,
            ),
            child: Icon(icon, size: 28, color: colors.textMuted),
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
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: colors.textSecondary,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
