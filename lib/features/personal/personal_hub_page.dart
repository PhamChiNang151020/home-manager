import "package:flutter/material.dart";
import "package:home_manager/core/app_version.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/services/notification_service.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/personal/leave_home_sheet.dart";
import "package:home_manager/features/pwa/install_home_screen_page.dart";
import "package:home_manager/features/settings/settings_account_page.dart";
import "package:home_manager/features/settings/settings_appearance_page.dart";
import "package:home_manager/features/settings/settings_home_page.dart";
import "package:home_manager/features/settings/settings_members_page.dart";
import "package:home_manager/features/settings/settings_schedule_page.dart";
import "package:home_manager/features/settings/settings_security_page.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shell/home_picker_sheet.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class PersonalHubPage extends StatelessWidget {
  const PersonalHubPage({
    super.key,
    required this.home,
    required this.homes,
    required this.homesApi,
    required this.invites,
    required this.notifications,
    required this.theme,
    required this.lock,
    required this.user,
    required this.onChanged,
    required this.onSelectHome,
    required this.onAddHome,
    required this.onSignOut,
  });

  final Home home;
  final List<Home> homes;
  final HomeService homesApi;
  final InviteService invites;
  final NotificationService notifications;
  final ThemeController theme;
  final LockController lock;
  final User? user;
  final VoidCallback onChanged;
  final ValueChanged<Home> onSelectHome;
  final VoidCallback onAddHome;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    return ListView(
      padding: AppSpacing.shellListPadding,
      children: [
        AnimatedEntrance(
          index: 0,
          child: _HubTile(
            leading: Icon(Icons.home_outlined, color: context.appColors.accent),
            title: S.managedHome,
            subtitle: home.name,
            onTap:
                () => showHomePickerSheet(
                  context: context,
                  homes: homes,
                  selected: home,
                  onSelected: onSelectHome,
                  onAddHome: onAddHome,
                ),
          ),
        ),
        AnimatedEntrance(
          index: 1,
          child: _HubTile(
            leading: Icon(
              Icons.person_outline,
              color: context.appColors.accent,
            ),
            title: S.personalInfo,
            subtitle: user?.email ?? S.settingsAccountDesc,
            onTap:
                () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                    page: SettingsAccountPage(user: user, onSignOut: onSignOut),
                  ),
                ),
          ),
        ),
        AnimatedEntrance(
          index: 2,
          child: _HubTile(
            leading: Icon(
              Icons.people_outline,
              color: context.appColors.accent,
            ),
            title: S.personalShare,
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
          child: _HubTile(
            leading: Icon(
              Icons.settings_outlined,
              color: context.appColors.accent,
            ),
            title: S.personalSettings,
            subtitle: S.personalSettingsDesc,
            onTap:
                () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                    page: PersonalSettingsPage(
                      home: home,
                      homesApi: homesApi,
                      notifications: notifications,
                      theme: theme,
                      lock: lock,
                      onChanged: onChanged,
                    ),
                  ),
                ),
          ),
        ),
        if (currentUser != null)
          AnimatedEntrance(
            index: 4,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: LeaveHomeButton(
                home: home,
                homesApi: homesApi,
                currentUserId: currentUser.id,
                onLeft: onChanged,
              ),
            ),
          ),
        AnimatedEntrance(
          index: 5,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: OutlinedButton(
              onPressed: onSignOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.error,
                side: BorderSide(color: context.appColors.error),
              ),
              child: const Text(S.signOut),
            ),
          ),
        ),
        AnimatedEntrance(
          index: 6,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Center(
              child: Column(
                children: [
                  Text(
                    S.appTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "${S.appVersion} ${AppVersion.label}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PersonalSettingsPage extends StatelessWidget {
  const PersonalSettingsPage({
    super.key,
    required this.home,
    required this.homesApi,
    required this.notifications,
    required this.theme,
    required this.lock,
    required this.onChanged,
  });

  final Home home;
  final HomeService homesApi;
  final NotificationService notifications;
  final ThemeController theme;
  final LockController lock;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(S.personalSettings)),
      body: MobileViewport(
        child: ListView(
          padding: AppSpacing.shellListPadding,
          children: [
            if (!home.isOwner)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  S.roleOwnerOnly,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            _HubTile(
              leading: Icon(
                Icons.home_outlined,
                color: context.appColors.accent,
              ),
              title: S.settingsHome,
              subtitle: S.settingsHomeDesc,
              onTap: () async {
                final deleted = await Navigator.push<bool>(
                  context,
                  AppPageRoute<bool>(
                    page: SettingsHomePage(
                      home: home,
                      homesApi: homesApi,
                      onChanged: onChanged,
                    ),
                  ),
                );
                if (deleted == true && context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            _HubTile(
              leading: const AppIcon(AppIcons.reminder, size: 28),
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
            _HubTile(
              leading: Icon(
                Icons.palette_outlined,
                color: context.appColors.accent,
              ),
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
            _HubTile(
              leading: Icon(
                Icons.lock_outline,
                color: context.appColors.accent,
              ),
              title: S.settingsSecurity,
              subtitle:
                  lock.hasPinSet ? S.settingsSecurityDesc : S.appLockNotEnabled,
              onTap:
                  () => Navigator.push(
                    context,
                    AppPageRoute<void>(page: SettingsSecurityPage(lock: lock)),
                  ),
            ),
            _HubTile(
              leading: Icon(
                Icons.add_to_home_screen,
                color: context.appColors.accent,
              ),
              title: S.settingsInstall,
              subtitle: S.settingsInstallDesc,
              onTap:
                  () => Navigator.push(
                    context,
                    AppPageRoute<void>(page: const InstallHomeScreenPage()),
                  ),
            ),
            _NotificationSettingsTile(notifications: notifications),
          ],
        ),
      ),
    );
  }
}

/// Toggle push notifications (permission + token upsert / delete). No token UI.
class _NotificationSettingsTile extends StatefulWidget {
  const _NotificationSettingsTile({required this.notifications});

  final NotificationService notifications;

  @override
  State<_NotificationSettingsTile> createState() =>
      _NotificationSettingsTileState();
}

class _NotificationSettingsTileState extends State<_NotificationSettingsTile> {
  bool _busy = false;
  bool _loaded = false;
  bool _enabled = false;
  String? _message;
  bool _messageOk = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final on = await widget.notifications.isEnabledLocally();
    if (!mounted) return;
    setState(() {
      _enabled = on;
      _loaded = true;
    });
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
      _messageOk = false;
    });
    try {
      if (!widget.notifications.isAvailable) {
        setState(() {
          _enabled = false;
          _message = S.settingsNotifyNotConfigured;
        });
        return;
      }
      if (value) {
        final result = await widget.notifications.enableAndRegister();
        if (!result.configured) {
          setState(() {
            _enabled = false;
            _message = S.settingsNotifyNotConfigured;
          });
          return;
        }
        if (result.status != NotificationPermissionStatus.granted) {
          setState(() {
            _enabled = false;
            _message = S.settingsNotifyDenied;
          });
          return;
        }
        if (result.tokenFailed || !result.saved) {
          setState(() {
            _enabled = false;
            _message =
                result.tokenFailed
                    ? S.settingsNotifyTokenFailed
                    : S.settingsNotifySaveFailed;
          });
          return;
        }
        setState(() {
          _enabled = true;
          _message = S.settingsNotifyOn;
          _messageOk = true;
        });
      } else {
        await widget.notifications.disableAndUnregister();
        setState(() {
          _enabled = false;
          _message = S.settingsNotifyOff;
          _messageOk = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              secondary: Icon(
                Icons.notifications_outlined,
                color: colors.accent,
              ),
              title: const Text(S.settingsNotifyTitle),
              subtitle: const Text(S.settingsNotifyDesc),
              value: _enabled,
              onChanged: (!_loaded || _busy) ? null : _onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              S.settingsNotifyIosHint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                _message!,
                style: TextStyle(
                  color: _messageOk ? colors.accent : colors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget leading;
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
          leading: leading,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.chevron_right, color: colors.textMuted),
        ),
      ),
    );
  }
}
