import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';

/// Short per-parameter result word (text + colour; SPEC §11).
String resultLabel(AppLocalizations l10n, ReadingResult r) => switch (r) {
  ReadingResult.ok => l10n.resultOk,
  ReadingResult.low => l10n.resultLow,
  ReadingResult.high => l10n.resultHigh,
  ReadingResult.detected => l10n.resultDetected,
  ReadingResult.unacceptable => l10n.resultUnacceptable,
  ReadingResult.invalid => l10n.resultInvalid,
  ReadingResult.notAssessed => l10n.resultNotAssessed,
};

Color resultColor(BuildContext context, ReadingResult r) {
  final c = Theme.of(context).extension<StatusColors>()!;
  return r.isAbnormal
      ? c.unsafe
      : r == ReadingResult.invalid
      ? c.inconclusive
      : r == ReadingResult.ok
      ? c.safe
      : c.neutral;
}

/// The message for a limitation code (codes are stored, text is not).
String? limitationText(AppLocalizations l10n, String? code) => switch (code) {
  'no_germ_test' => l10n.limitationNoGermTest,
  'ecoli_negative_reminder' => l10n.limitationEcoliNegative,
  _ => null,
};

/// "6.5–8.5 pH", "≤ 1500 mg/L", "must be absent" … for a limit.
String limitText(AppLocalizations l10n, ParameterLimit? l) {
  if (l == null || !l.isAssessable) return l10n.entryNoLimit;
  if (l.mustBeAbsent) return l10n.entryNotDetected;
  if (l.mustBeAcceptable) return l10n.entryAcceptable;
  final unit = l.unit.isEmpty ? '' : ' ${l.unit}';
  if (l.min != null && l.max != null) return '${l.min}–${l.max}$unit';
  if (l.max != null) return '≤ ${l.max}$unit';
  return '≥ ${l.min}$unit';
}
