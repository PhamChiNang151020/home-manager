import "package:home_manager/core/models/tracking_mode.dart";

class Home {
  const Home({
    required this.id,
    required this.name,
    required this.trackingMode,
    required this.kwhRate,
    required this.createdBy,
    this.photoDueDay,
    this.paydayDay,
    this.remindDay,
    this.myRole,
  });

  final String id;
  final String name;
  final TrackingMode trackingMode;
  final double kwhRate;
  final String createdBy;
  final int? photoDueDay;
  final int? paydayDay;
  final int? remindDay;
  final String? myRole;

  bool get isOwner => myRole == "owner";

  factory Home.fromJson(Map<String, dynamic> json, {String? myRole}) {
    return Home(
      id: json["id"] as String,
      name: json["name"] as String,
      trackingMode: TrackingMode.fromString(json["tracking_mode"] as String),
      kwhRate: (json["kwh_rate"] as num).toDouble(),
      createdBy: json["created_by"] as String,
      photoDueDay: json["photo_due_day"] as int?,
      paydayDay: json["payday_day"] as int?,
      remindDay: json["remind_day"] as int?,
      myRole: myRole,
    );
  }
}

class HomeMember {
  const HomeMember({
    required this.userId,
    required this.role,
    this.email,
    this.displayName,
  });

  final String userId;
  final String role;
  final String? email;
  final String? displayName;
}

class HomeInvite {
  const HomeInvite({
    required this.id,
    required this.email,
    required this.status,
  });

  final String id;
  final String email;
  final String status;

  factory HomeInvite.fromJson(Map<String, dynamic> json) {
    return HomeInvite(
      id: json["id"] as String,
      email: json["email"] as String,
      status: json["status"] as String,
    );
  }
}
