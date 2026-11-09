import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";

enum ListGroupRowHeight { h56, h64, h72, h84 }

/// Grouped rows inside a bordered card. Divider inset starts at x = 64.
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class ListGroupRow extends StatelessWidget {
  const ListGroupRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.height = ListGroupRowHeight.h56,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ListGroupRowHeight height;
  final bool showDivider;

  double get _h => switch (height) {
    ListGroupRowHeight.h56 => 56,
    ListGroupRowHeight.h64 => 64,
    ListGroupRowHeight.h72 => 72,
    ListGroupRowHeight.h84 => 84,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final row = SizedBox(
      height: _h,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        color: colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );

    return Column(
      children: [
        if (onTap == null)
          row
        else
          InkWell(onTap: onTap, child: row),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 64,
            color: colors.border,
          ),
      ],
    );
  }
}

/// 36 circle with 20 icon — standard list leading.
class ListGroupIcon extends StatelessWidget {
  const ListGroupIcon({super.key, required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final c = color ?? colors.accent;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: 0.12),
      ),
      child: Icon(icon, size: 20, color: c),
    );
  }
}
