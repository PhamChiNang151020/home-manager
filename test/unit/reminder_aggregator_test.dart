import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/reminder_aggregator.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/personal_debt.dart";
import "package:home_manager/core/models/reminder_item.dart";
import "package:home_manager/core/models/savings.dart";
import "package:home_manager/core/models/tracking_mode.dart";

void main() {
  final home = Home(
    id: "h1",
    name: "Nhà",
    trackingMode: TrackingMode.meter,
    kwhRate: 3500,
    createdBy: "u1",
    photoDueDay: 15,
    paydayDay: 20,
    remindDay: 10,
  );

  test("aggregates home day reminders near today", () {
    final now = DateTime(2026, 8, 15);
    final items = aggregateReminders(
      home: home,
      bankAccounts: const [],
      latestBankPeriods: const {},
      debts: const [],
      savings: const [],
      now: now,
    );
    expect(items.any((i) => i.id == "elec-photo"), isTrue);
    expect(reminderBadgeCount(items), greaterThan(0));
  });

  test("marks unpaid bank due as overdue when past", () {
    final now = DateTime(2026, 8, 21);
    final account = BankAccount(
      id: "b1",
      homeId: "h1",
      bankName: "VCB",
      creditLimit: 10000000,
      statementDay: 1,
      dueDay: 10,
      createdAt: now,
    );
    final items = aggregateReminders(
      home: home.copyWithClearDays(),
      bankAccounts: [account],
      latestBankPeriods: {
        "b1": BankAccountPeriod(
          id: "p1",
          bankAccountId: "b1",
          periodMonth: DateTime(2026, 8),
          balanceUsed: 1000,
          paymentDue: 1000,
          paymentMade: 0,
          isPaid: false,
          recordedAt: now,
        ),
      },
      debts: const [],
      savings: const [],
      now: now,
    );
    final bank = items.firstWhere((i) => i.id == "bank-b1");
    expect(bank.status, ReminderStatus.overdue);
  });

  test("term deposit within 30 days is upcoming", () {
    final now = DateTime(2026, 8, 21);
    final items = aggregateReminders(
      home: home.copyWithClearDays(),
      bankAccounts: const [],
      latestBankPeriods: const {},
      debts: const [],
      savings: [
        Savings(
          id: "s1",
          homeId: "h1",
          type: "term_deposit",
          name: "Kỳ hạn",
          currentAmount: 1000,
          maturityDate: DateTime(2026, 9, 1),
          createdAt: now,
        ),
      ],
      now: now,
    );
    expect(items.single.status, ReminderStatus.upcoming);
  });

  test("settled debt is done", () {
    final now = DateTime(2026, 8, 21);
    final items = aggregateReminders(
      home: home.copyWithClearDays(),
      bankAccounts: const [],
      latestBankPeriods: const {},
      debts: [
        PersonalDebt(
          id: "d1",
          homeId: "h1",
          direction: "i_owe",
          counterpartyName: "An",
          principalAmount: 100,
          remainingAmount: 0,
          dueDate: DateTime(2026, 8, 1),
          isSettled: true,
          createdBy: "u1",
          createdAt: now,
        ),
      ],
      savings: const [],
      now: now,
    );
    expect(items.single.status, ReminderStatus.done);
    expect(reminderBadgeCount(items), 0);
  });
}

extension on Home {
  Home copyWithClearDays() {
    return Home(
      id: id,
      name: name,
      trackingMode: trackingMode,
      kwhRate: kwhRate,
      createdBy: createdBy,
      photoDueDay: null,
      paydayDay: null,
      remindDay: null,
    );
  }
}
