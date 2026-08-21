import "package:flutter/foundation.dart";
import "package:home_manager/core/domain/reminder_aggregator.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/reminder_item.dart";
import "package:home_manager/core/services/app_services.dart";

class ReminderController extends ChangeNotifier {
  ReminderController(this._services);

  final AppServices _services;

  List<ReminderItem> items = [];
  int badgeCount = 0;
  bool loading = false;
  String? homeId;

  Future<void> refresh(Home? home) async {
    if (home == null) {
      items = [];
      badgeCount = 0;
      homeId = null;
      notifyListeners();
      return;
    }
    homeId = home.id;
    loading = true;
    notifyListeners();
    try {
      final accounts = await _services.bankAccounts.listAccounts(home.id);
      final latest = <String, BankAccountPeriod?>{};
      for (final a in accounts) {
        latest[a.id] = await _services.bankAccounts.latestPeriod(a.id);
      }
      final debts = await _services.personalDebts.list(home.id);
      final savings = await _services.savings.list(home.id);
      items = aggregateReminders(
        home: home,
        bankAccounts: accounts,
        latestBankPeriods: latest,
        debts: debts,
        savings: savings,
      );
      badgeCount = reminderBadgeCount(items);
    } catch (e, st) {
      AppLog.e("Reminder refresh failed", error: e, stackTrace: st);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
