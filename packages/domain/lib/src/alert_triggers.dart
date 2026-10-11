import 'classification.dart';
import 'overall_status.dart';
import 'reading.dart';

/// Why an alert was raised (SPEC §4.4 F-ALR-1, §6.3 response cards).
enum AlertTrigger {
  /// E. coli detected: the most urgent (report immediately).
  ecoli('ecoli', 'critical'),

  /// Confirmed overall result is unsafe.
  unsafe('unsafe', 'high'),

  /// Sudden change from the source's baseline.
  baselineJump('baseline_jump', 'medium');

  const AlertTrigger(this.code, this.severity);

  /// Matches `alert.trigger_rule` and `response_cards.trigger_rule`.
  final String code;
  final String severity;
}

/// The alerts a result raises, most urgent first. Inconclusive results raise
/// none; the collector is asked to retest instead.
List<AlertTrigger> alertTriggers(
  ClassificationResult result, {
  String germParameter = 'ecoli',
}) => [
  if (result[germParameter]?.result == ReadingResult.detected)
    AlertTrigger.ecoli,
  if (result.overall == OverallStatus.unsafe) AlertTrigger.unsafe,
  if (result.flags.any((f) => f.startsWith(flagBaselineJumpPrefix)))
    AlertTrigger.baselineJump,
];
