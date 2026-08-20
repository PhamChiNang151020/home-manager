import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_motion.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/homes/create_home_dialog.dart";
import "package:home_manager/features/overview/overview_page.dart";
import "package:home_manager/features/settings/settings_hub_page.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/sticky_primary_bar.dart";
import "package:home_manager/features/shell/home_picker_sheet.dart";

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.session,
    required this.theme,
    required this.services,
  });

  final SessionController session;
  final ThemeController theme;
  final AppServices services;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  final _expensesKey = GlobalKey<ExpensesPageState>();

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final home = session.selected;
    final services = widget.services;
    final colors = context.appColors;

    return ColoredBox(
      color: colors.bgBase,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: colors.bgBase,
          surfaceTintColor: Colors.transparent,
          title:
              home == null
                  ? const Text(S.appName)
                  : InkWell(
                    onTap:
                        () => showHomePickerSheet(
                          context: context,
                          homes: session.homes,
                          selected: home,
                          onSelected: session.selectHome,
                          onAddHome:
                              () => showCreateHomeDialog(
                                context: context,
                                homesApi: services.homes,
                                onCreated: session.refreshHomes,
                              ),
                        ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            home.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const Icon(Icons.expand_more, size: 20),
                      ],
                    ),
                  ),
          actions: [
            if (home != null)
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.screenHorizontal,
                ),
                child: Center(child: trackingModeChip(home.trackingMode)),
              ),
          ],
        ),
        body: MobileViewport(
          child: LoadingOverlay(
            loading: session.loading,
            child:
                home == null
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(S.noHomes),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton(
                            onPressed:
                                () => showCreateHomeDialog(
                                  context: context,
                                  homesApi: services.homes,
                                  onCreated: session.refreshHomes,
                                ),
                            child: const Text(S.addHome),
                          ),
                        ],
                      ),
                    )
                    : AnimatedSwitcher(
                      duration: AppMotion.normal,
                      switchInCurve: AppCurves.enter,
                      switchOutCurve: AppCurves.exit,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.02),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: switch (_tab) {
                        0 => OverviewPage(
                          key: ValueKey("overview-${home.id}"),
                          home: home,
                          services: services,
                        ),
                        1 => ExpensesPage(
                          key: _expensesKey,
                          home: home,
                          expenses: services.expenses,
                          homesApi: services.homes,
                          photos: services.photos,
                          currentUserId: session.user?.id ?? "",
                        ),
                        _ => SettingsHubPage(
                          key: ValueKey("settings-${home.id}"),
                          home: home,
                          homesApi: services.homes,
                          invites: services.invites,
                          theme: widget.theme,
                          onChanged: session.refreshHomes,
                          onSignOut: session.signOut,
                        ),
                      },
                    ),
          ),
        ),
        bottomNavigationBar:
            home == null
                ? null
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_tab == 1)
                      StickyPrimaryBar(
                        label: S.addExpense,
                        onPressed:
                            () => _expensesKey.currentState?.openAddForm(),
                      ),
                    NavigationBar(
                      selectedIndex: _tab,
                      onDestinationSelected:
                          (index) => setState(() => _tab = index),
                      destinations: const [
                        NavigationDestination(
                          icon: AppAssetIcon(AppIcons.dashboard, size: 24),
                          selectedIcon: AppAssetIcon(
                            AppIcons.dashboard,
                            size: 26,
                          ),
                          label: S.overview,
                        ),
                        NavigationDestination(
                          icon: AppAssetIcon(AppIcons.expenses, size: 24),
                          selectedIcon: AppAssetIcon(
                            AppIcons.expenses,
                            size: 26,
                          ),
                          label: S.expenses,
                        ),
                        NavigationDestination(
                          icon: AppAssetIcon(AppIcons.settings, size: 24),
                          selectedIcon: AppAssetIcon(
                            AppIcons.settings,
                            size: 26,
                          ),
                          label: S.settings,
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
