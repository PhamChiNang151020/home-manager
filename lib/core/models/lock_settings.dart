enum AutoLockDuration {
  immediate,
  oneMinute,
  fiveMinutes;

  Duration get duration => switch (this) {
    AutoLockDuration.immediate => Duration.zero,
    AutoLockDuration.oneMinute => const Duration(minutes: 1),
    AutoLockDuration.fiveMinutes => const Duration(minutes: 5),
  };

  String get storageKey => name;

  static AutoLockDuration fromStorage(String? value) {
    return AutoLockDuration.values.firstWhere(
      (d) => d.name == value,
      orElse: () => AutoLockDuration.immediate,
    );
  }
}

class LockSettings {
  const LockSettings({required this.enabled, required this.autoLockDuration});

  final bool enabled;
  final AutoLockDuration autoLockDuration;

  LockSettings copyWith({bool? enabled, AutoLockDuration? autoLockDuration}) {
    return LockSettings(
      enabled: enabled ?? this.enabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
    );
  }
}
