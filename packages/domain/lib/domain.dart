/// WaterCheck domain core: entities, parameter catalogue, reference
/// profiles and the classification rules (SPEC §6, ADR-005). Pure Dart.
library;

export 'package:decimal/decimal.dart' show Decimal;
export 'package:rational/rational.dart' show Rational;

export 'src/alert_status.dart';
export 'src/alert_triggers.dart';
export 'src/catalogue.dart';
export 'src/classification.dart';
export 'src/entities.dart';
export 'src/geo.dart';
export 'src/json_utils.dart' show JsonMap, decimal, decimalOrNull;
export 'src/overall_status.dart';
export 'src/phone.dart';
export 'src/reading.dart';
export 'src/reference_profile.dart';
export 'src/rules.dart';
export 'src/schedule.dart';
export 'src/tester_profile.dart';
export 'src/units.dart';
