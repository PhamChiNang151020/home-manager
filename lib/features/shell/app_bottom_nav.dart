import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/safe_bottom_padding.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/app_glass_surface.dart";

/// Custom 5-slot bottom bar: Overview | Transactions | (+) | Notifications | Personal.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.tabIndex,
    required this.onTabSelected,
    required this.onQuickAdd,
    this.notificationBadge = 0,
  });

  /// Index into the 4 content tabs (0..3). The center + is not a tab.
  final int tabIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickAdd;
  final int notificationBadge;

  static const _barHeight = AppSpacing.touchMin + AppSpacing.md; // 64

  void _selectTab(int index) {
    if (index != tabIndex) HapticFeedback.selectionClick();
    onTabSelected(index);
  }

  void _quickAdd() {
    HapticFeedback.selectionClick();
    onQuickAdd();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = safeBottomPaddingOf(context);
    final row = Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: _barHeight + AppSpacing.sm,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: AppIcons.dashboard,
                label: S.overview,
                selected: tabIndex == 0,
                onTap: () => _selectTab(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: AppIcons.expenses,
                label: S.transactions,
                selected: tabIndex == 1,
                onTap: () => _selectTab(1),
              ),
            ),
            Expanded(child: _QuickAddButton(onTap: _quickAdd)),
            Expanded(
              child: _NavItem(
                icon: AppIcons.reminder,
                label: S.notifications,
                selected: tabIndex == 2,
                onTap: () => _selectTab(2),
                badgeCount: notificationBadge,
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: AppIcons.settings,
                label: S.personal,
                selected: tabIndex == 3,
                onTap: () => _selectTab(3),
              ),
            ),
          ],
        ),
      ),
    );

    if (colors.glass) {
      return AppGlassSurface.blurred(
        borderRadius: BorderRadius.zero,
        child: row,
      );
    }

    return Material(color: colors.bgSurface, elevation: 0, child: row);
  }
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    return Transform.translate(
      offset: const Offset(0, -AppSpacing.sm),
      child: Center(
        child: Material(
          color: colors.accent,
          shape: const CircleBorder(),
          elevation: 4,
          shadowColor: colors.textPrimary.withValues(alpha: 0.28),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: AppSpacing.touchMin,
              height: AppSpacing.touchMin,
              child: Icon(Icons.add, color: onAccent),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final labelColor = selected ? colors.accent : colors.textMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppIcon(
                icon,
                size: selected ? 26 : 24,
                color: selected ? colors.accent : colors.textMuted,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -AppSpacing.sm,
                  top: -AppSpacing.xs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    constraints: const BoxConstraints(minWidth: 16),
                    child: Text(
                      badgeCount > 99 ? "99+" : "$badgeCount",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
