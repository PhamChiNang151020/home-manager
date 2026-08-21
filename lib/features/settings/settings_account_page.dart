import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SettingsAccountPage extends StatelessWidget {
  const SettingsAccountPage({
    super.key,
    required this.onSignOut,
    this.user,
  });

  final VoidCallback onSignOut;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final email = user?.email ?? "";
    final name =
        user?.userMetadata?["full_name"] as String? ??
        user?.userMetadata?["name"] as String? ??
        email;
    final avatarUrl =
        user?.userMetadata?["avatar_url"] as String? ??
        user?.userMetadata?["picture"] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsAccount)),
      body: MobileViewport(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: colors.bgElevated,
                  backgroundImage:
                      avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                  child:
                      avatarUrl == null || avatarUrl.isEmpty
                          ? Icon(
                            Icons.person,
                            size: 40,
                            color: colors.textMuted,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                name.isEmpty ? S.settingsAccount : name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              OutlinedButton(
                onPressed: onSignOut,
                child: const Text(S.signOut),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
