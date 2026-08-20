import "package:flutter/material.dart";
import "package:home_manager/core/domain/period_history_filter.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/electricity_form.dart";
import "package:home_manager/features/electricity/electricity_summary_card.dart";
import "package:home_manager/features/electricity/electricity_trend_chart.dart";
import "package:home_manager/features/electricity/period_history_filter_bar.dart";
import "package:home_manager/features/electricity/period_list_tile.dart";
import "package:home_manager/features/electricity/reminder_banner.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/electricity/electricity_page_skeleton.dart";
import "package:home_manager/features/shared/app_loading.dart";
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
  int? _filterYear;
  int? _filterMonth;
  PeriodSortOrder _sortOrder = PeriodSortOrder.newestFirst;

  List<ElectricityPeriod> get _filteredItems => filterPeriodHistory(
    _items,
    year: _filterYear,
    month: _filterMonth,
    sortOrder: _sortOrder,
  );

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

  Future<void> _deletePeriod(ElectricityPeriod period) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(S.deletePeriod),
            content: const Text(S.deletePeriodConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(S.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text(S.delete),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final path = period.photoPath;
      if (path != null && path.isNotEmpty) {
        await widget.photos.remove(path);
      }
      await widget.electricity.delete(period.id);
      _load();
    } catch (e) {
      AppLog.e("Delete period failed", error: e);
    }
  }

  Future<void> _togglePaid(ElectricityPeriod period) async {
    try {
      await widget.electricity.setPaid(period.id, isPaid: !period.isPaid);
      _load();
    } catch (e) {
      AppLog.e("Toggle paid failed", error: e);
    }
  }

  Future<void> _openAddForm() async {
    final previous = _items.isEmpty ? null : _items.first;
    await showElectricityAddForm(
      context: context,
      home: widget.home,
      electricity: widget.electricity,
      photos: widget.photos,
      previousPeriod: previous,
      existingPeriods: _items,
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
      existingPeriods: _items,
      onSaved: _load,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    if (_loading && _items.isEmpty) {
      return const ElectricityPageSkeleton();
    }

    return LoadingOverlay(
      loading: _loading,
      child: RefreshIndicator(
        onRefresh: _load,
        color: Theme.of(context).colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            AnimatedEntrance(
              index: 0,
              child: ReminderBanner(home: widget.home),
            ),
            if (_items.isEmpty) ...[
              const AnimatedEntrance(
                index: 1,
                child: EmptyStateView(message: S.noPeriods),
              ),
            ] else ...[
              AnimatedEntrance(
                index: 1,
                child: ElectricitySummaryCard(
                  home: widget.home,
                  periods: _items,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AnimatedEntrance(
                index: 2,
                child: ElectricityTrendChart(periods: _items),
              ),
              const AnimatedEntrance(
                index: 3,
                child: SectionHeader(title: S.history),
              ),
              AnimatedEntrance(
                index: 4,
                child: PeriodHistoryFilterBar(
                  years: distinctPeriodYears(_items),
                  filterYear: _filterYear,
                  filterMonth: _filterMonth,
                  sortOrder: _sortOrder,
                  onYearChanged: (value) => setState(() => _filterYear = value),
                  onMonthChanged:
                      (value) => setState(() => _filterMonth = value),
                  onSortChanged: (value) => setState(() => _sortOrder = value),
                ),
              ),
              if (_filteredItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: EmptyStateView(message: S.noHistoryMatch),
                )
              else
                for (var i = 0; i < _filteredItems.length; i++)
                  AnimatedEntrance(
                    index: 5 + i,
                    child: PeriodListTile(
                      period: _filteredItems[i],
                      previousPeriod:
                          i + 1 < _filteredItems.length
                              ? _filteredItems[i + 1]
                              : null,
                      home: widget.home,
                      photos: widget.photos,
                      onTap: () => _openPeriodDialog(_filteredItems[i]),
                      onEdit: () => _openPeriodDialog(_filteredItems[i]),
                      onDelete: () => _deletePeriod(_filteredItems[i]),
                      onTogglePaid: () => _togglePaid(_filteredItems[i]),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
