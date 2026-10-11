/// Overall classification of a test session (spec §6.2).
enum OverallStatus {
  safe,
  unsafe,
  inconclusive;

  /// Parses the wire/database value, e.g. `'unsafe'`.
  static OverallStatus fromCode(String code) => values.firstWhere(
    (s) => s.name == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unknown status'),
  );
}
