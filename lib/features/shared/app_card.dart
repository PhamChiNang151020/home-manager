import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_motion.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      reverseDuration: AppMotion.fast,
    );
    _scale = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: AppCurves.press),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: widget.padding, child: widget.child),
    );

    Widget result = card;
    if (widget.onTap != null) {
      result = GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap!();
        },
        onTapCancel: () => _pressController.reverse(),
        child: ScaleTransition(scale: _scale, child: card),
      );
    }

    return result;
  }
}
