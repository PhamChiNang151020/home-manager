enum ReminderDomain {
  electricity,
  water,
  bankCredit,
  personalDebt,
  savings,
}

enum ReminderStatus { overdue, upcoming, done }

class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.title,
    required this.domain,
    required this.dueDate,
    required this.status,
  });

  final String id;
  final String title;
  final ReminderDomain domain;
  final DateTime dueDate;
  final ReminderStatus status;
}
