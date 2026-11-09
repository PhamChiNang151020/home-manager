import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

/// Section title row.
///
/// Default: 16/24 w700 (proposal component table).
/// [dense]: 12/16 w700 muted (members / home-empty 08).
///
/// Link touch target is 48px tall centered on the 24px title band
/// (spec 02: title 646–670, link touch 634–682).
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
    final bandH = dense ? 16.0 : 24.0;
    final hasLink = linkLabel != null && onLink != null;

    final titleText = Text(
      title,
      style: TextStyle(
        fontSize: dense ? 12 : 16,
        height: dense ? 16 / 12 : 24 / 16,
        fontWeight: FontWeight.w700,
        color: dense ? colors.textMuted : colors.textPrimary,
        letterSpacing: dense ? 0.5 : 0,
      ),
    );

    if (!hasLink) {
      return SizedBox(
        height: bandH,
        child: Row(
          children: [
            Expanded(child: titleText),
            if (trailing != null) trailing!,
          ],
        ),
      );
    }

    final link = TextButton(
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
    );

    return SizedBox(
      height: bandH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(child: titleText),
              if (trailing != null) trailing!,
              // Horizontal reserve; real control is Positioned (48 tall).
              const SizedBox(width: 99),
            ],
          ),
          Positioned(
            right: 0,
            top: (bandH - AppSpacing.touchMin) / 2,
            height: AppSpacing.touchMin,
            child: link,
          ),
        ],
      ),
    );
  }
}
