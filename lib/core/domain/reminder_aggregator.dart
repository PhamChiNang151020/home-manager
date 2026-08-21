import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/personal_debt.dart";
import "package:home_manager/core/models/reminder_item.dart";
import "package:home_manager/core/models/savings.dart";

/// Builds unified reminder list from home settings + finance domain data.
List<ReminderItem> aggregateReminders({
  required Home home,
  required List<BankAccount> bankAccounts,
  required Map<String, BankAccountPeriod?> latestBankPeriods,
  required List<PersonalDebt> debts,
  required List<Savings> savings,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final items = <ReminderItem>[];

  void addHomeDay({
    required String id,
    required String title,
    required int? day,
    required ReminderDomain domain,
  }) {
    if (day == null) return;
    final dueDay = DayOfMonth.clampToMonth(day, today);
    final due = DateTime(today.year, today.month, dueDay);
    final status =
        due.isBefore(todayDate)
            ? ReminderStatus.overdue
            : due.isAtSameMomentAs(todayDate) ||
                due.difference(todayDate).inDays <= 7
            ? ReminderStatus.upcoming
            : ReminderStatus.upcoming;
    // Only surface days that are today or already passed this month, or within 7 days.
    if (due.difference(todayDate).inDays > 7 && due.isAfter(todayDate)) {
      return;
    }
    items.add(
      ReminderItem(
        id: id,
        title: title,
        domain: domain,
        dueDate: due,
        status: status,
      ),
    );
  }

  addHomeDay(
    id: "elec-photo",
    title: S.bannerPhoto,
    day: home.photoDueDay,
    domain: ReminderDomain.electricity,
  );
  addHomeDay(
    id: "elec-pay",
    title: S.bannerPayday,
    day: home.paydayDay,
    domain: ReminderDomain.electricity,
  );
  addHomeDay(
    id: "elec-remind",
    title: S.bannerRemind,
    day: home.remindDay,
    domain: ReminderDomain.water,
  );

  for (final account in bankAccounts) {
    final period = latestBankPeriods[account.id];
    final dueDay = DayOfMonth.clampToMonth(account.dueDay, today);
    final due = DateTime(today.year, today.month, dueDay);
    if (period?.isPaid == true) {
      items.add(
        ReminderItem(
          id: "bank-${account.id}-done",
          title: "${S.bankCredit}: ${account.bankName}",
          domain: ReminderDomain.bankCredit,
          dueDate: due,
          status: ReminderStatus.done,
        ),
      );
      continue;
    }
    final status =
        due.isBefore(todayDate)
            ? ReminderStatus.overdue
            : ReminderStatus.upcoming;
    if (due.difference(todayDate).inDays > 14 && due.isAfter(todayDate)) {
      continue;
    }
    items.add(
      ReminderItem(
        id: "bank-${account.id}",
        title: "${S.bankCredit}: ${account.bankName}",
        domain: ReminderDomain.bankCredit,
        dueDate: due,
        status: status,
      ),
    );
  }

  for (final debt in debts) {
    if (debt.dueDate == null) continue;
    final due = DateTime(
      debt.dueDate!.year,
      debt.dueDate!.month,
      debt.dueDate!.day,
    );
    if (debt.isSettled) {
      items.add(
        ReminderItem(
          id: "debt-${debt.id}-done",
          title: "${S.personalDebts}: ${debt.counterpartyName}",
          domain: ReminderDomain.personalDebt,
          dueDate: due,
          status: ReminderStatus.done,
        ),
      );
      continue;
    }
    final status =
        due.isBefore(todayDate)
            ? ReminderStatus.overdue
            : ReminderStatus.upcoming;
    items.add(
      ReminderItem(
        id: "debt-${debt.id}",
        title: "${S.personalDebts}: ${debt.counterpartyName}",
        domain: ReminderDomain.personalDebt,
        dueDate: due,
        status: status,
      ),
    );
  }

  for (final item in savings) {
    if (!item.isTermDeposit || item.maturityDate == null) continue;
    final due = DateTime(
      item.maturityDate!.year,
      item.maturityDate!.month,
      item.maturityDate!.day,
    );
    final days = due.difference(todayDate).inDays;
    if (days < 0) {
      items.add(
        ReminderItem(
          id: "sav-${item.id}",
          title: "${S.savings}: ${item.name}",
          domain: ReminderDomain.savings,
          dueDate: due,
          status: ReminderStatus.overdue,
        ),
      );
    } else if (days <= 30) {
      items.add(
        ReminderItem(
          id: "sav-${item.id}",
          title: "${S.savings}: ${item.name}",
          domain: ReminderDomain.savings,
          dueDate: due,
          status: ReminderStatus.upcoming,
        ),
      );
    }
  }

  items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return items;
}

int reminderBadgeCount(List<ReminderItem> items) {
  return items
      .where(
        (i) =>
            i.status == ReminderStatus.overdue ||
            i.status == ReminderStatus.upcoming,
      )
      .length;
}
