import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colors.accent),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: TextStyle(color: colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
