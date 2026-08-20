import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/models/water_period.dart";

void main() {
  test("Home.fromJson parses m3_rate and defaults when missing", () {
    final withRate = Home.fromJson({
      "id": "h1",
      "name": "Nhà tôi",
      "tracking_mode": "meter",
      "kwh_rate": 3500,
      "m3_rate": 12000,
      "created_by": "u1",
    });
    expect(withRate.m3Rate, 12000);
    expect(withRate.trackingMode, TrackingMode.meter);

    final withoutRate = Home.fromJson({
      "id": "h1",
      "name": "Nhà tôi",
      "tracking_mode": "invoice",
      "kwh_rate": 3500,
      "created_by": "u1",
    });
    expect(withoutRate.m3Rate, 10000);
  });

  test("WaterPeriod.fromJson parses m3 fields", () {
    final period = WaterPeriod.fromJson({
      "id": "w1",
      "home_id": "h1",
      "period_month": "2026-03-01",
      "amount_vnd": 80000,
      "previous_m3": 10,
      "new_m3": 18,
      "consumption_m3": 8,
      "photo_path": null,
      "note": null,
      "recorded_at": "2026-03-15T10:30:00.000Z",
      "is_paid": true,
    });
    expect(period.consumptionM3, 8);
    expect(period.isPaid, isTrue);
  });
}
