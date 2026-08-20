import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_motion.dart";

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required this.page, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: AppCurves.enter,
            reverseCurve: AppCurves.exit,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.fast,
      );

  final Widget page;
}
