import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class MobileViewport extends StatelessWidget {
  const MobileViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: SafeArea(top: false, bottom: false, child: child),
        ),
      ),
    );
  }
}
