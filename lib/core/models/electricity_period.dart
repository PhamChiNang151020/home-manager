class ElectricityPeriod {
  const ElectricityPeriod({
    required this.id,
    required this.homeId,
    required this.periodMonth,
    required this.amountVnd,
    this.previousKwh,
    this.newKwh,
    this.consumptionKwh,
    this.photoPath,
    this.note,
  });

  final String id;
  final String homeId;
  final DateTime periodMonth;
  final double amountVnd;
  final double? previousKwh;
  final double? newKwh;
  final double? consumptionKwh;
  final String? photoPath;
  final String? note;

  factory ElectricityPeriod.fromJson(Map<String, dynamic> json) {
    return ElectricityPeriod(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      periodMonth: DateTime.parse(json["period_month"] as String),
      amountVnd: (json["amount_vnd"] as num).toDouble(),
      previousKwh: (json["previous_kwh"] as num?)?.toDouble(),
      newKwh: (json["new_kwh"] as num?)?.toDouble(),
      consumptionKwh: (json["consumption_kwh"] as num?)?.toDouble(),
      photoPath: json["photo_path"] as String?,
      note: json["note"] as String?,
    );
  }
}
