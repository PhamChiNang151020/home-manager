import 'package:flutter/material.dart';
import 'package:home_manager/core/theme/app_spacing.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFB)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      );
  }
}
