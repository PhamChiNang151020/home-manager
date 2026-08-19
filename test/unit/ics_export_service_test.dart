import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/ics_export_service.dart";

void main() {
  test("ics includes photo payday and remind events", () {
    const home = Home(
      id: "h1",
      name: "Nhà tôi",
      trackingMode: TrackingMode.meter,
      kwhRate: 3500,
      createdBy: "u1",
      photoDueDay: 15,
      paydayDay: 25,
      remindDay: 10,
    );
    final ics = const IcsExportService().buildCalendar(home);
    expect(ics, contains("BEGIN:VCALENDAR"));
    expect(ics, contains("RRULE:FREQ=MONTHLY;BYMONTHDAY=15"));
    expect(ics, contains("RRULE:FREQ=MONTHLY;BYMONTHDAY=25"));
    expect(ics, contains("RRULE:FREQ=MONTHLY;BYMONTHDAY=10"));
    expect(ics, contains("Chụp hoá đơn điện — Nhà tôi"));
    expect(ics, contains("Ngày lãnh lương — Nhà tôi"));
    expect(ics, contains("Nhắc điện — Nhà tôi"));
  });

  test("ics omits events when days are null", () {
    const home = Home(
      id: "h2",
      name: "Empty",
      trackingMode: TrackingMode.invoice,
      kwhRate: 3500,
      createdBy: "u1",
    );
    final ics = const IcsExportService().buildCalendar(home);
    expect(ics, contains("BEGIN:VCALENDAR"));
    expect(ics, isNot(contains("BEGIN:VEVENT")));
  });
}
