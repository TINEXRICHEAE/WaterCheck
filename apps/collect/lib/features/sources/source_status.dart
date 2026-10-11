import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import 'source_providers.dart';

String formatDate(DateTime d) => DateFormat.yMMMd('en').format(d.toLocal());

/// The badge for a source: its latest result, or NOT TESTED.
SourceStatus statusOf(SourceSummary s) =>
    s.latest?.overall.display ?? SourceStatus.notTested;

/// "Last tested …" and "Next test by …" / "Overdue since …" lines.
class SourceScheduleText extends StatelessWidget {
  const SourceScheduleText(this.summary, {super.key});

  final SourceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final latest = summary.latest;
    final schedule = summary.schedule;
    final due = schedule.dueDate;
    final dueLine = switch (schedule.status) {
      ScheduleStatus.notTested => null,
      ScheduleStatus.overdue => l10n.sourceOverdueSince(formatDate(due!)),
      _ => l10n.sourceNextTest(formatDate(due!)),
    };
    final dueColor = switch (schedule.status) {
      ScheduleStatus.overdue => colors.unsafe,
      ScheduleStatus.dueSoon => colors.due,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          latest == null
              ? l10n.sourceNeverTested
              : l10n.sourceLastTested(formatDate(latest.testedAt)),
        ),
        if (dueLine != null)
          Row(
            children: [
              if (dueColor != null) ...[
                Icon(
                  schedule.status == ScheduleStatus.overdue
                      ? Icons.event_busy
                      : Icons.schedule,
                  size: 16,
                  color: dueColor,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  dueLine,
                  style: TextStyle(
                    color: dueColor,
                    fontWeight: dueColor == null ? null : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
