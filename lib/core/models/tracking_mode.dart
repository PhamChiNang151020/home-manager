enum TrackingMode {
  meter,
  invoice;

  static TrackingMode fromString(String value) {
    return value == "invoice" ? TrackingMode.invoice : TrackingMode.meter;
  }

  String get dbValue => name;
}
