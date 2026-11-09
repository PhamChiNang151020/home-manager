import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/safe_bottom_padding.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/app_glass_surface.dart";

/// Custom 5-slot bottom bar: Overview | Transactions | (+) | Due | Assets.
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

  /// Visible bar block above the home-indicator inset (64).
  static const barBodyHeight = AppSpacing.touchMin + AppSpacing.md; // 64

  /// Full bottom-nav height including safe-area padding under the bar.
  static double heightOf(BuildContext context) =>
      barBodyHeight + safeBottomPaddingOf(context);

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
    final row = DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: barBodyHeight,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  key: const ValueKey("nav-item-0"),
                  icon: AppIcons.dashboard,
                  label: S.overview,
                  selected: tabIndex == 0,
                  onTap: () => _selectTab(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  key: const ValueKey("nav-item-1"),
                  icon: AppIcons.expenses,
                  label: S.transactions,
                  selected: tabIndex == 1,
                  onTap: () => _selectTab(1),
                ),
              ),
              Expanded(
                child: _QuickAddButton(
                  key: const ValueKey("nav-plus"),
                  onTap: _quickAdd,
                ),
              ),
              Expanded(
                child: _NavItem(
                  key: const ValueKey("nav-item-2"),
                  icon: Icons.event_available_rounded,
                  label: S.dues,
                  selected: tabIndex == 2,
                  onTap: () => _selectTab(2),
                  badgeCount: notificationBadge,
                ),
              ),
              Expanded(
                child: _NavItem(
                  key: const ValueKey("nav-item-3"),
                  icon: Icons.account_balance_wallet_outlined,
                  label: S.assets,
                  selected: tabIndex == 3,
                  onTap: () => _selectTab(3),
                ),
              ),
            ],
          ),
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
  const _QuickAddButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    return Center(
      child: Material(
        color: colors.accent,
        shape: const CircleBorder(),
        elevation: 0,
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
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
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
            alignment: Alignment.center,
            children: [
              Container(
                key: selected ? const ValueKey("nav-pill") : null,
                width: 48,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selected
                          ? colors.accent.withValues(alpha: 0.12)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppIcon(
                  icon,
                  size: 24,
                  color: selected ? colors.accent : colors.textMuted,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -2,
                  top: -4,
                  child: Container(
                    key: const ValueKey("nav-badge"),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 1.5,
                      ),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 18),
                    child: Text(
                      badgeCount > 99 ? "99+" : "$badgeCount",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
              height: 16 / 11,
              fontFamily: "Nunito",
            ),
          ),
        ],
      ),
    );
  }
}
