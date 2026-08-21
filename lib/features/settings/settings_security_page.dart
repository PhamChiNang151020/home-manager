import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/lock_settings.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/lock/setup_pin_page.dart";
import "package:home_manager/features/shared/app_card.dart";

class SettingsSecurityPage extends StatelessWidget {
  const SettingsSecurityPage({super.key, required this.lock});

  final LockController lock;

  Future<void> _openSetup(BuildContext context, {bool change = false}) async {
    await Navigator.push<bool>(
      context,
      AppPageRoute(page: SetupPinPage(lock: lock, changeExisting: change)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: lock,
      builder: (context, _) {
        final colors = context.appColors;
        final enabled = lock.enabled;
        return Scaffold(
          appBar: AppBar(title: const Text(S.settingsSecurity)),
          body: MobileViewport(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                if (!lock.hasPinSet)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      S.appLockNotEnabled,
                      style: TextStyle(color: colors.warning),
                    ),
                  ),
                AppCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(S.enableAppLock),
                    value: enabled,
                    onChanged: (value) async {
                      if (value) {
                        await _openSetup(context);
                      } else {
                        await lock.disable();
                      }
                    },
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    onTap: () => _openSetup(context, change: true),
                    child: const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(S.changePin),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    S.autoLockLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      children: [
                        for (final d in AutoLockDuration.values)
                          RadioListTile<AutoLockDuration>(
                            contentPadding: EdgeInsets.zero,
                            title: Text(switch (d) {
                              AutoLockDuration.immediate => S.autoLockImmediate,
                              AutoLockDuration.oneMinute => S.autoLockOneMinute,
                              AutoLockDuration.fiveMinutes =>
                                S.autoLockFiveMinutes,
                            }),
                            value: d,
                            groupValue: lock.settings.autoLockDuration,
                            onChanged: (value) {
                              if (value != null) {
                                lock.setAutoLockDuration(value);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
