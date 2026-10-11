import 'package:decimal/decimal.dart';

typedef JsonMap = Map<String, Object?>;

/// Reads a JSON number (or numeric string) as an exact [Decimal].
///
/// Doubles go through their shortest string form, so `0.001` in a JSON file
/// becomes exactly `0.001`. No floating-point comparison anywhere (ADR-005 §4).
Decimal? decimalOrNull(Object? value) => switch (value) {
  null => null,
  final int v => Decimal.fromInt(v),
  final double v => Decimal.parse(v.toString()),
  final String v => Decimal.parse(v),
  _ => throw FormatException('Expected a number, got $value'),
};

Decimal decimal(Object? value) =>
    decimalOrNull(value) ?? (throw const FormatException('Missing number'));

JsonMap asMap(Object? value) => value is Map
    ? value.cast<String, Object?>()
    : throw FormatException('Expected a JSON object, got $value');

List<Object?> asList(Object? value) => value is List
    ? value.cast<Object?>()
    : throw FormatException('Expected a JSON array, got $value');
