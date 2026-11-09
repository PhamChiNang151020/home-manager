import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

/// Section title row.
///
/// Default: 16/24 w700 (proposal component table).
/// [dense]: 12/16 w700 muted (members / home-empty 08).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.linkLabel,
    this.onLink,
    this.dense = false,
  });

  final String title;
  final Widget? trailing;
  final String? linkLabel;
  final VoidCallback? onLink;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: dense ? 16 : 24,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: dense ? 12 : 16,
                height: dense ? 16 / 12 : 24 / 16,
                fontWeight: FontWeight.w700,
                color: dense ? colors.textMuted : colors.textPrimary,
                letterSpacing: dense ? 0.5 : 0,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          if (linkLabel != null && onLink != null)
            SizedBox(
              height: AppSpacing.touchMin,
              child: TextButton(
                onPressed: onLink,
                style: TextButton.styleFrom(
                  foregroundColor: colors.accent,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  linkLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
