class WaterPeriod {
  const WaterPeriod({
    required this.id,
    required this.homeId,
    required this.periodMonth,
    required this.amountVnd,
    required this.recordedAt,
    this.isPaid = false,
    this.previousM3,
    this.newM3,
    this.consumptionM3,
    this.photoPath,
    this.note,
  });

  final String id;
  final String homeId;
  final DateTime periodMonth;
  final double amountVnd;
  final DateTime recordedAt;
  final bool isPaid;
  final double? previousM3;
  final double? newM3;
  final double? consumptionM3;
  final String? photoPath;
  final String? note;

  WaterPeriod copyWith({bool? isPaid}) {
    return WaterPeriod(
      id: id,
      homeId: homeId,
      periodMonth: periodMonth,
      amountVnd: amountVnd,
      recordedAt: recordedAt,
      isPaid: isPaid ?? this.isPaid,
      previousM3: previousM3,
      newM3: newM3,
      consumptionM3: consumptionM3,
      photoPath: photoPath,
      note: note,
    );
  }

  factory WaterPeriod.fromJson(Map<String, dynamic> json) {
    return WaterPeriod(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      periodMonth: DateTime.parse(json["period_month"] as String),
      amountVnd: (json["amount_vnd"] as num).toDouble(),
      recordedAt: DateTime.parse(
        json["recorded_at"] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      isPaid: json["is_paid"] as bool? ?? false,
      previousM3: (json["previous_m3"] as num?)?.toDouble(),
      newM3: (json["new_m3"] as num?)?.toDouble(),
      consumptionM3: (json["consumption_m3"] as num?)?.toDouble(),
      photoPath: json["photo_path"] as String?,
      note: json["note"] as String?,
    );
  }
}
