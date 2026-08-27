import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/personal/leave_home_sheet.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/shared/status_badge.dart";
import "package:home_manager/features/shell/home_picker_sheet.dart";

class ManagedHomePage extends StatelessWidget {
  const ManagedHomePage({
    super.key,
    required this.home,
    required this.homes,
    required this.homesApi,
    required this.currentUserId,
    required this.onSelectHome,
    required this.onAddHome,
    required this.onLeft,
  });

  final Home home;
  final List<Home> homes;
  final HomeService homesApi;
  final String currentUserId;
  final ValueChanged<Home> onSelectHome;
  final VoidCallback onAddHome;
  final VoidCallback onLeft;

  String get _modeLabel =>
      home.trackingMode == TrackingMode.meter ? S.modeMeter : S.modeInvoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final others = homes.where((item) => item.id != home.id).toList();

    return FeaturePageScaffold(
      title: S.managedHome,
      body: ListView(
        padding: AppSpacing.shellListPadding,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.home_outlined, color: colors.accent),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        home.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    StatusBadge(
                      label: home.isOwner ? S.owner : S.member,
                      variant:
                          home.isOwner
                              ? StatusBadgeVariant.accent
                              : StatusBadgeVariant.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _modeLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (others.isNotEmpty)
            const SectionHeader(title: S.managedHomeOthers),
          AppCard(
            child: HomePickerList(
              homes: others,
              selected: home,
              onSelected: (selected) {
                onSelectHome(selected);
                Navigator.pop(context);
              },
              onAddHome: () {
                Navigator.pop(context);
                onAddHome();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LeaveHomeButton(
            home: home,
            homesApi: homesApi,
            currentUserId: currentUserId,
            onLeft: () {
              onLeft();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
