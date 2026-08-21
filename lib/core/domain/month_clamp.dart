DateTime currentMonth([DateTime? now]) {
  final n = now ?? DateTime.now();
  return DateTime(n.year, n.month);
}

DateTime monthStart(DateTime date) => DateTime(date.year, date.month);

bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

DateTime lastDayOfMonth(DateTime month) =>
    DateTime(month.year, month.month + 1, 0);

DateTime today([DateTime? now]) {
  final n = now ?? DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime clampToCurrentMonth(DateTime month, {DateTime? now}) {
  final current = currentMonth(now);
  final start = monthStart(month);
  if (start.isAfter(current)) return current;
  return start;
}

DateTime clampDate(
  DateTime date, {
  required DateTime first,
  required DateTime last,
}) {
  if (date.isBefore(first)) return first;
  if (date.isAfter(last)) return last;
  return date;
}

bool canGoNextMonth(DateTime month, {DateTime? now}) {
  final next = DateTime(month.year, month.month + 1);
  return !next.isAfter(currentMonth(now));
}

DateTime? shiftMonth(DateTime month, int delta, {DateTime? now}) {
  final shifted = DateTime(month.year, month.month + delta);
  if (shifted.isAfter(currentMonth(now))) return null;
  return shifted;
}

DateTime lastSelectableMonthEnd({DateTime? now}) =>
    lastDayOfMonth(currentMonth(now));

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool canGoNextDay(DateTime day, {DateTime? now}) {
  final next = DateTime(day.year, day.month, day.day + 1);
  return !next.isAfter(today(now));
}

DateTime? shiftDay(DateTime day, int delta, {DateTime? now}) {
  final shifted = DateTime(day.year, day.month, day.day + delta);
  if (shifted.isAfter(today(now))) return null;
  return shifted;
}
