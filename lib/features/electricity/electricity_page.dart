import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/features/electricity/electricity_form.dart";
import "package:home_manager/features/electricity/reminder_banner.dart";
import "package:intl/intl.dart";

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
  State<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends State<ElectricityPage> {
  List<ElectricityPeriod> _items = [];
  bool _loading = true;
  String? _error;
  final _vnd = NumberFormat.decimalPattern("vi_VN");

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.electricity.list(widget.home.id);
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "$e";
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm([ElectricityPeriod? existing]) async {
    final previous = _items.where((item) {
      if (existing == null) {
        return true;
      }
      return item.periodMonth.isBefore(existing.periodMonth);
    }).toList();
    await showElectricityForm(
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
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        ReminderBanner(home: widget.home),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        Expanded(
          child: _items.isEmpty
              ? const Center(child: Text(S.noPeriods))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final title = DateFormat("MM/yyyy").format(item.periodMonth);
                    final subtitle = widget.home.trackingMode == TrackingMode.meter
                        ? "${item.previousKwh ?? '-'} → ${item.newKwh ?? '-'} kWh · ${_vnd.format(item.amountVnd)} đ"
                        : "${_vnd.format(item.amountVnd)} đ";
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(subtitle),
                      trailing: item.photoPath == null ? null : const Icon(Icons.image),
                      onTap: () => _openForm(item),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text(S.addPeriod),
          ),
        ),
      ],
    );
  }
}
