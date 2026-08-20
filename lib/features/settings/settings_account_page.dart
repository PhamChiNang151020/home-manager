import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";

class SettingsAccountPage extends StatelessWidget {
  const SettingsAccountPage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsAccount)),
      body: MobileViewport(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              OutlinedButton(
                onPressed: onSignOut,
                child: const Text(S.signOut),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
