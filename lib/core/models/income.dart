class Income {
  const Income({
    required this.id,
    required this.homeId,
    required this.userId,
    required this.amountVnd,
    required this.incomeMonth,
    required this.createdAt,
    this.source,
    this.note,
    this.displayName,
  });

  final String id;
  final String homeId;
  final String userId;
  final double amountVnd;
  final DateTime incomeMonth;
  final DateTime createdAt;
  final String? source;
  final String? note;
  final String? displayName;

  factory Income.fromJson(Map<String, dynamic> json) {
    final profile = json["profiles"];
    return Income(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      userId: json["user_id"] as String,
      amountVnd: (json["amount_vnd"] as num).toDouble(),
      incomeMonth: DateTime.parse(json["income_month"] as String),
      createdAt: DateTime.parse(
        json["created_at"] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      source: json["source"] as String?,
      note: json["note"] as String?,
      displayName:
          profile is Map
              ? (profile["display_name"] as String? ??
                  profile["email"] as String?)
              : null,
    );
  }
}
