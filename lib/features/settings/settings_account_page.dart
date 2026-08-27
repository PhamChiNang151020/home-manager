import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SettingsAccountPage extends StatelessWidget {
  const SettingsAccountPage({
    super.key,
    required this.onSignOut,
    this.user,
    this.home,
  });

  final VoidCallback onSignOut;
  final User? user;
  final Home? home;

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
    final displayName = name.isEmpty ? S.settingsAccount : name;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    return Scaffold(
      appBar: AppBar(title: const Text(S.settingsAccount)),
      body: MobileViewport(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            AppCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colors.accentMuted(),
                    backgroundImage:
                        avatarUrl != null && avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                    child:
                        avatarUrl == null || avatarUrl.isEmpty
                            ? Text(
                              initial,
                              style: TextStyle(
                                color: colors.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 28,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    S.linkedGoogleAccount,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (email.isNotEmpty)
                    _AccountFact(
                      icon: Icons.mail_outline,
                      label: S.accountEmail,
                      value: email,
                    ),
                  _AccountFact(
                    icon: Icons.login,
                    label: S.accountSignIn,
                    value: S.accountGoogle,
                    showDivider: home != null,
                  ),
                  if (home != null)
                    _AccountFact(
                      icon: Icons.home_outlined,
                      label: S.managedHome,
                      value: home!.name,
                    ),
                  if (home != null)
                    _AccountFact(
                      icon: Icons.shield_outlined,
                      label: S.accountRole,
                      value: home!.isOwner ? S.owner : S.member,
                      showDivider: false,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Text(
                S.accountEmailManagedHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ),
            OutlinedButton(
              onPressed: onSignOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
                minimumSize: const Size.fromHeight(AppSpacing.touchMin),
              ),
              child: const Text(S.signOut),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountFact extends StatelessWidget {
  const _AccountFact({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: colors.accent),
          title: Text(value),
          subtitle: Text(label),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
