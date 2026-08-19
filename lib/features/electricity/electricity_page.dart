import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/electricity_form.dart";
import "package:home_manager/features/electricity/electricity_summary_card.dart";
import "package:home_manager/features/electricity/electricity_trend_chart.dart";
import "package:home_manager/features/electricity/period_list_tile.dart";
import "package:home_manager/features/electricity/reminder_banner.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shared/section_header.dart";

class ElectricityPage extends StatefulWidget {
  const ElectricityPage({
    super.key,
    required this.home,
    required this.electricity,
    required this.photos,
  });

  final Home home;
  final ElectricityService electricity;
  final BillPhotoService photos;

  @override
  ElectricityPageState createState() => ElectricityPageState();
}

class ElectricityPageState extends State<ElectricityPage> {
  List<ElectricityPeriod> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ElectricityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) {
      _load();
    }
  }

  Future<void> _load() async {
    AppLog.d("Loading electricity periods for ${widget.home.id}");
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.electricity.list(widget.home.id);
      if (mounted) {
        items.sort((a, b) => b.periodMonth.compareTo(a.periodMonth));
        setState(() {
          _items = items;
          _loading = false;
        });
        AppLog.i("Loaded ${items.length} periods");
      }
    } catch (e, st) {
      AppLog.e("Failed to load periods", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  void openAddForm() => _openAddForm();

  Future<void> _openAddForm() async {
    final previous = _items.isEmpty ? null : _items.first;
    await showElectricityAddForm(
      context: context,
      home: widget.home,
      electricity: widget.electricity,
      photos: widget.photos,
      previousPeriod: previous,
      onSaved: _load,
    );
  }

  Future<void> _openPeriodDialog(ElectricityPeriod existing) async {
    final previous =
        _items
            .where((item) => item.periodMonth.isBefore(existing.periodMonth))
            .toList()
          ..sort((a, b) => b.periodMonth.compareTo(a.periodMonth));
    await showElectricityPeriodDialog(
      context: context,
      home: widget.home,
      electricity: widget.electricity,
      photos: widget.photos,
      existing: existing,
      previousPeriod: previous.isEmpty ? null : previous.first,
      onSaved: _load,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingView();
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: Theme.of(context).colorScheme.primary,
      child: ListView(
        padding: const EdgeInsets.only(
          top: AppSpacing.sm,
          bottom: AppSpacing.md,
        ),
        children: [
          ReminderBanner(home: widget.home),
          if (_items.isEmpty) ...[
            const EmptyStateView(message: S.noPeriods),
          ] else ...[
            ElectricitySummaryCard(home: widget.home, periods: _items),
            const SizedBox(height: AppSpacing.sm),
            ElectricityTrendChart(periods: _items),
            const SectionHeader(title: S.history),
            for (final item in _items)
              PeriodListTile(
                period: item,
                home: widget.home,
                onTap: () => _openPeriodDialog(item),
              ),
          ],
        ],
      ),
    );
  }
}
