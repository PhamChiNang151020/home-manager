import "package:flutter/material.dart";
import "package:home_manager/core/app_version.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/settings/settings_account_page.dart";
import "package:home_manager/features/settings/settings_appearance_page.dart";
import "package:home_manager/features/settings/settings_home_page.dart";
import "package:home_manager/features/settings/settings_members_page.dart";
import "package:home_manager/features/settings/settings_schedule_page.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_card.dart";

class SettingsHubPage extends StatelessWidget {
  const SettingsHubPage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.invites,
    required this.theme,
    required this.onChanged,
    required this.onSignOut,
  });

  final Home home;
  final HomeService homesApi;
  final InviteService invites;
  final ThemeController theme;
  final VoidCallback onChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        if (!home.isOwner)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              S.roleOwnerOnly,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        AnimatedEntrance(
          index: 0,
          child: _SettingsTile(
            icon: Icons.home_outlined,
            title: S.settingsHome,
            subtitle: S.settingsHomeDesc,
            onTap:
                () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                    page: SettingsHomePage(
                      home: home,
                      homesApi: homesApi,
                      onChanged: onChanged,
                    ),
                  ),
                ),
          ),
        ),
        AnimatedEntrance(
          index: 1,
          child: _SettingsTile(
            icon: Icons.calendar_month_outlined,
            title: S.settingsSchedule,
            subtitle: S.settingsScheduleDesc,
            onTap:
                () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                    page: SettingsSchedulePage(
                      home: home,
                      homesApi: homesApi,
                      onChanged: onChanged,
                    ),
                  ),
                ),
          ),
        ),
        AnimatedEntrance(
          index: 2,
          child: _SettingsTile(
            icon: Icons.people_outline,
            title: S.settingsMembers,
            subtitle: S.settingsMembersDesc,
            onTap:
                () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                    page: SettingsMembersPage(
                      home: home,
                      homesApi: homesApi,
                      invites: invites,
                    ),
                  ),
                ),
          ),
        ),
        AnimatedEntrance(
          index: 3,
          child: _SettingsTile(
            icon: Icons.palette_outlined,
            title: S.settingsAppearance,
            subtitle: S.settingsAppearanceDesc,
            onTap:
                () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                    page: SettingsAppearancePage(theme: theme),
                  ),
                ),
          ),
        ),
        AnimatedEntrance(
          index: 4,
          child: _SettingsTile(
            icon: Icons.person_outline,
            title: S.settingsAccount,
            subtitle: S.settingsAccountDesc,
            onTap:
                () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                    page: SettingsAccountPage(onSignOut: onSignOut),
                  ),
                ),
          ),
        ),
        AnimatedEntrance(
          index: 5,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Center(
              child: Text(
                "${S.appVersion} ${AppVersion.label}",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appColors.textMuted,
                ),
              ),
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
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon, color: colors.accent),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.chevron_right, color: colors.textMuted),
        ),
      ),
    );
  }
}
