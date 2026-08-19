import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/ics_export_service.dart";

void main() {
  test("ics includes monthly photo event", () {
    const home = Home(
      id: "h1",
      name: "Nhà tôi",
      trackingMode: TrackingMode.meter,
      kwhRate: 3500,
      createdBy: "u1",
      photoDueDay: 15,
    );
    final ics = const IcsExportService().buildCalendar(home);
    expect(ics, contains("BEGIN:VCALENDAR"));
    expect(ics, contains("RRULE:FREQ=MONTHLY;BYMONTHDAY=15"));
    expect(ics, contains("Chụp hoá đơn điện — Nhà tôi"));
  });
}
