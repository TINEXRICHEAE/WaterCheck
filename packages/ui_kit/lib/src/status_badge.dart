import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';
import 'theme.dart';

/// What a source or result shows on lists and cards.
enum SourceStatus { safe, unsafe, inconclusive, notTested, dueSoon, overdue }

extension OverallStatusDisplay on OverallStatus {
  SourceStatus get display => switch (this) {
    OverallStatus.safe => SourceStatus.safe,
    OverallStatus.unsafe => SourceStatus.unsafe,
    OverallStatus.inconclusive => SourceStatus.inconclusive,
  };
}

/// Status as text + icon + colour, never colour alone (SPEC §11).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.large = false});

  final SourceStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final (label, icon, color) = switch (status) {
      SourceStatus.safe => (l10n.statusSafe, Icons.check_circle, colors.safe),
      SourceStatus.unsafe => (
        l10n.statusUnsafe,
        Icons.warning_rounded,
        colors.unsafe,
      ),
      SourceStatus.inconclusive => (
        l10n.statusInconclusive,
        Icons.help_rounded,
        colors.inconclusive,
      ),
      SourceStatus.notTested => (
        l10n.statusNotTested,
        Icons.radio_button_unchecked,
        colors.neutral,
      ),
      SourceStatus.dueSoon => (l10n.statusDueSoon, Icons.schedule, colors.due),
      SourceStatus.overdue => (
        l10n.statusOverdue,
        Icons.event_busy,
        colors.unsafe,
      ),
    };
    final text = large
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.labelLarge;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 14 : 10,
          vertical: large ? 8 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: large ? 24 : 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: text?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
