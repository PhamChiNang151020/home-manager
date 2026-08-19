import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/theme/app_colors.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/settings/settings_account_page.dart";
import "package:home_manager/features/settings/settings_home_page.dart";
import "package:home_manager/features/settings/settings_members_page.dart";
import "package:home_manager/features/settings/settings_schedule_page.dart";

class SettingsHubPage extends StatelessWidget {
  const SettingsHubPage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.invites,
    required this.onChanged,
    required this.onSignOut,
  });

  final Home home;
  final HomeService homesApi;
  final InviteService invites;
  final VoidCallback onChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (!home.isOwner)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              S.roleOwnerOnly,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        _SettingsTile(
          icon: Icons.home_outlined,
          title: S.settingsHome,
          subtitle: S.settingsHomeDesc,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SettingsHomePage(
                home: home,
                homesApi: homesApi,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        _SettingsTile(
          icon: Icons.calendar_month_outlined,
          title: S.settingsSchedule,
          subtitle: S.settingsScheduleDesc,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SettingsSchedulePage(
                home: home,
                homesApi: homesApi,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        _SettingsTile(
          icon: Icons.people_outline,
          title: S.settingsMembers,
          subtitle: S.settingsMembersDesc,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SettingsMembersPage(
                home: home,
                homesApi: homesApi,
                invites: invites,
              ),
            ),
          ),
        ),
        _SettingsTile(
          icon: Icons.person_outline,
          title: S.settingsAccount,
          subtitle: S.settingsAccountDesc,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SettingsAccountPage(onSignOut: onSignOut),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
