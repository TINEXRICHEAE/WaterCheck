import 'json_utils.dart';

/// Normalises unit spellings through the alias table in `rules.json`.
///
/// The PoC has no unit *conversion* (SPEC §6.0). Only spellings of the same
/// unit are merged, e.g. `uS/cm` = `µS/cm` and `ppm` = `mg/L` (ADR-005 §4).
class UnitNormalizer {
  UnitNormalizer(Map<String, List<String>> aliasesByCanonical)
    : _lookup = {
        for (final entry in aliasesByCanonical.entries) ...{
          _key(entry.key): entry.key,
          for (final alias in entry.value) _key(alias): entry.key,
        },
      };

  factory UnitNormalizer.fromJson(List<Object?> json) => UnitNormalizer({
    for (final item in json.map(asMap))
      item['canonical']! as String: asList(item['aliases']).cast<String>(),
  });

  final Map<String, String> _lookup;

  static String _key(String unit) => unit.trim().toLowerCase();

  /// Canonical spelling of [unit]. Unknown units come back trimmed; `null`
  /// is the empty unit.
  String normalize(String? unit) {
    final trimmed = (unit ?? '').trim();
    return _lookup[_key(trimmed)] ?? trimmed;
  }

  bool same(String? a, String? b) => normalize(a) == normalize(b);
}
