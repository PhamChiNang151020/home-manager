import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/theme/app_colors.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/homes/create_home_dialog.dart";
import "package:home_manager/features/settings/settings_hub_page.dart";
import "package:home_manager/features/shared/sticky_primary_bar.dart";
import "package:home_manager/features/shell/home_picker_sheet.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.session});

  final SessionController session;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  final _electricityKey = GlobalKey<ElectricityPageState>();

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final home = session.selected;
    final client = Supabase.instance.client;
    final homesApi = HomeService(client);
    final electricity = ElectricityService(client);
    final photos = BillPhotoService(client);
    final invites = InviteService(client);

    return Scaffold(
      appBar: AppBar(
        title: home == null
            ? const Text(S.appName)
            : InkWell(
                onTap: () => showHomePickerSheet(
                  context: context,
                  homes: session.homes,
                  selected: home,
                  onSelected: session.selectHome,
                  onAddHome: () => showCreateHomeDialog(
                    context: context,
                    homesApi: homesApi,
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
          if (home != null) Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(child: trackingModeChip(home.trackingMode)),
          ),
        ],
      ),
      body: MobileViewport(
        child: session.loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : home == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(S.noHomes),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: () => showCreateHomeDialog(
                            context: context,
                            homesApi: homesApi,
                            onCreated: session.refreshHomes,
                          ),
                          child: const Text(S.addHome),
                        ),
                      ],
                    ),
                  )
                : _tab == 0
                    ? ElectricityPage(
                        key: _electricityKey,
                        home: home,
                        electricity: electricity,
                        photos: photos,
                      )
                    : SettingsHubPage(
                        key: ValueKey("settings-${home.id}"),
                        home: home,
                        homesApi: homesApi,
                        invites: invites,
                        onChanged: session.refreshHomes,
                        onSignOut: session.signOut,
                      ),
      ),
      bottomNavigationBar: home == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_tab == 0)
                  StickyPrimaryBar(
                    label: S.addPeriod,
                    onPressed: () =>
                        _electricityKey.currentState?.openAddForm(),
                  ),
                NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: (index) =>
                      setState(() => _tab = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.bolt),
                      label: S.electricity,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings),
                      label: S.settings,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
