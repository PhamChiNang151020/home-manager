import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/models/home.dart";
import "package:intl/intl.dart";

class IcsExportService {
  const IcsExportService();

  String buildCalendar(Home home) {
    final now = DateTime.now();
    final buffer =
        StringBuffer()
          ..writeln("BEGIN:VCALENDAR")
          ..writeln("VERSION:2.0")
          ..writeln("PRODID:-//home-manager//VN")
          ..writeln("CALSCALE:GREGORIAN");

    void event({
      required String uid,
      required int day,
      required String summary,
    }) {
      final clamped = DayOfMonth.clampToMonth(day, now);
      final start = DateTime(now.year, now.month, clamped);
      final stamp = DateFormat("yyyyMMdd").format(start);
      buffer
        ..writeln("BEGIN:VEVENT")
        ..writeln("UID:$uid@home-manager")
        ..writeln("DTSTART;VALUE=DATE:$stamp")
        ..writeln("RRULE:FREQ=MONTHLY;BYMONTHDAY=$day")
        ..writeln("SUMMARY:$summary")
        ..writeln("END:VEVENT");
    }

    if (home.photoDueDay != null) {
      event(
        uid: "photo-${home.id}",
        day: home.photoDueDay!,
        summary: "Chụp hoá đơn điện — ${home.name}",
      );
    }
    if (home.paydayDay != null) {
      event(
        uid: "pay-${home.id}",
        day: home.paydayDay!,
        summary: "Ngày lãnh lương — ${home.name}",
      );
    }
    if (home.remindDay != null) {
      event(
        uid: "remind-${home.id}",
        day: home.remindDay!,
        summary: "Nhắc điện — ${home.name}",
      );
    }

    buffer.writeln("END:VCALENDAR");
    return buffer.toString().replaceAll("\n", "\r\n");
  }
}
