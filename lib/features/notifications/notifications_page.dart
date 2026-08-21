import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/reminder_item.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/state/reminder_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_page.dart";
import "package:home_manager/features/overview/overview_page.dart";
import "package:home_manager/features/personal_debts/personal_debts_page.dart";
import "package:home_manager/features/savings/savings_page.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shared/status_badge.dart";
import "package:intl/intl.dart";

enum _NotifFilter { all, overdue, upcoming, done }

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    required this.home,
    required this.services,
    required this.reminders,
    required this.currentUserId,
  });

  final Home home;
  final AppServices services;
  final ReminderController reminders;
  final String currentUserId;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  _NotifFilter _filter = _NotifFilter.all;

  @override
  void initState() {
    super.initState();
    widget.reminders.refresh(widget.home);
  }

  @override
  void didUpdateWidget(covariant NotificationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) {
      widget.reminders.refresh(widget.home);
    }
  }

  List<ReminderItem> get _filtered {
    final items = widget.reminders.items;
    return switch (_filter) {
      _NotifFilter.all => items,
      _NotifFilter.overdue =>
        items.where((i) => i.status == ReminderStatus.overdue).toList(),
      _NotifFilter.upcoming =>
        items.where((i) => i.status == ReminderStatus.upcoming).toList(),
      _NotifFilter.done =>
        items.where((i) => i.status == ReminderStatus.done).toList(),
    };
  }

  void _openItem(ReminderItem item) {
    final home = widget.home;
    final services = widget.services;
    switch (item.domain) {
      case ReminderDomain.electricity:
      case ReminderDomain.water:
        Navigator.push<void>(
          context,
          AppPageRoute<void>(
            page:
                item.domain == ReminderDomain.electricity
                    ? ElectricityRoutePage(
                      home: home,
                      electricity: services.electricity,
                      photos: services.photos,
                    )
                    : WaterRoutePage(
                      home: home,
                      water: services.water,
                      photos: services.photos,
                    ),
          ),
        );
      case ReminderDomain.bankCredit:
        Navigator.push<void>(
          context,
          AppPageRoute<void>(
            page: BankCreditRoutePage(
              home: home,
              bank: services.bankAccounts,
            ),
          ),
        );
      case ReminderDomain.personalDebt:
        Navigator.push<void>(
          context,
          AppPageRoute<void>(
            page: PersonalDebtsRoutePage(
              home: home,
              debts: services.personalDebts,
              currentUserId: widget.currentUserId,
            ),
          ),
        );
      case ReminderDomain.savings:
        Navigator.push<void>(
          context,
          AppPageRoute<void>(
            page: SavingsRoutePage(home: home, savings: services.savings),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.reminders,
      builder: (context, _) {
        if (widget.reminders.loading && widget.reminders.items.isEmpty) {
          return const LoadingView();
        }
        final items = _filtered;
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  for (final f in _NotifFilter.values) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(switch (f) {
                          _NotifFilter.all => S.filterAll,
                          _NotifFilter.overdue => S.filterOverdue,
                          _NotifFilter.upcoming => S.filterUpcoming,
                          _NotifFilter.done => S.filterDone,
                        }),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => widget.reminders.refresh(widget.home),
                child:
                    items.isEmpty
                        ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            EmptyStateView(message: S.noNotifications),
                          ],
                        )
                        : ListView.builder(
                          padding: AppSpacing.shellListPadding,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final (badgeLabel, variant) = switch (item.status) {
                              ReminderStatus.overdue => (
                                S.reminderOverdue,
                                StatusBadgeVariant.error,
                              ),
                              ReminderStatus.upcoming => (
                                S.reminderUpcoming,
                                StatusBadgeVariant.warning,
                              ),
                              ReminderStatus.done => (
                                S.reminderDone,
                                StatusBadgeVariant.success,
                              ),
                            };
                            return AnimatedEntrance(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: AppCard(
                                  onTap: () => _openItem(item),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat(
                                                "dd/MM/yyyy",
                                              ).format(item.dueDate),
                                              style: TextStyle(
                                                color:
                                                    context
                                                        .appColors
                                                        .textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(
                                        label: badgeLabel,
                                        variant: variant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        );
      },
    );
  }
}
