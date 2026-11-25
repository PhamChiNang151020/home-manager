import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/water/water_page.dart";

class TransactionsHubPage extends StatefulWidget {
  const TransactionsHubPage({
    super.key,
    required this.home,
    required this.services,
    required this.currentUserId,
    this.initialSegment = 0,
  });

  final Home home;
  final AppServices services;
  final String currentUserId;
  final int initialSegment;

  @override
  State<TransactionsHubPage> createState() => _TransactionsHubPageState();
}

class _TransactionsHubPageState extends State<TransactionsHubPage> {
  late int _segment;

  @override
  void initState() {
    super.initState();
    _segment = widget.initialSegment.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          // Horizontal inset comes from MobileViewport; only vertical here.
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: SegmentedTrack(
            key: const ValueKey("tx-segmented"),
            labels: const [S.expenses, S.electricity, S.water],
            index: _segment,
            onChanged: (i) => setState(() => _segment = i),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _segment,
            children: [
              ExpensesPage(
                home: widget.home,
                expenses: widget.services.expenses,
                homesApi: widget.services.homes,
                photos: widget.services.photos,
                currentUserId: widget.currentUserId,
                incomes: widget.services.incomes,
                services: widget.services,
                wallets: widget.services.wallets,
              ),
              ElectricityPage(
                home: widget.home,
                electricity: widget.services.electricity,
                photos: widget.services.photos,
              ),
              WaterPage(
                home: widget.home,
                water: widget.services.water,
                photos: widget.services.photos,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
