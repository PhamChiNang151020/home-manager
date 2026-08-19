import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class FormTitle extends StatelessWidget {
  const FormTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
