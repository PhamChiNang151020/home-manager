import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";

class SignInPage extends StatelessWidget {
  const SignInPage({super.key, required this.onGoogle, this.error});

  final VoidCallback onGoogle;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(S.appName, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              const Text(S.signInHint),
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: onGoogle,
                icon: const Icon(Icons.login),
                label: const Text(S.signInGoogle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MissingConfigPage extends StatelessWidget {
  const MissingConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text(S.missingConfig)),
      ),
    );
  }
}
