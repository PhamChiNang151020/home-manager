class MeterMath {
  const MeterMath._();

  static double consumption({
    required double previousKwh,
    required double newKwh,
  }) {
    return newKwh - previousKwh;
  }

  static double amountVnd({
    required double consumptionKwh,
    required double kwhRate,
  }) {
    return consumptionKwh * kwhRate;
  }
}

class DayOfMonth {
  const DayOfMonth._();

  static int clampToMonth(int day, DateTime month) {
    final last = DateTime(month.year, month.month + 1, 0).day;
    return day > last ? last : day;
  }

  static bool isToday(int? day, [DateTime? now]) {
    if (day == null) {
      return false;
    }
    final today = now ?? DateTime.now();
    return today.day == clampToMonth(day, today);
  }
}
