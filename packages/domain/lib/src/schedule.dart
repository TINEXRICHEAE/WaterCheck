import 'overall_status.dart';
import 'rules.dart';

/// Testing status shown as "Due" / "Overdue" on the home screen (F-SRC-4).
enum ScheduleStatus {
  notTested('not_tested'),
  ok('ok'),
  dueSoon('due_soon'),
  overdue('overdue');

  const ScheduleStatus(this.code);
  final String code;
}

/// Which interval applies (SPEC §7).
enum ScheduleMode {
  routine('routine'),
  rainySeason('rainy_season'),
  afterAbnormal('after_abnormal');

  const ScheduleMode(this.code);
  final String code;
}

typedef TestHistoryEntry = ({DateTime date, OverallStatus overall});

class ScheduleState {
  const ScheduleState({required this.status, this.mode, this.dueDate});

  final ScheduleStatus status;
  final ScheduleMode? mode;

  /// Date-only (UTC midnight); null when never tested.
  final DateTime? dueDate;
}

/// Computes when a source is next due for testing (SPEC §7):
/// monthly; every 2 weeks in the rainy season; weekly after an abnormal
/// result until [ScheduleConfig.normalResultsToClear] consecutive normal
/// results. The interval is chosen from the month of the last test.
/// Inconclusive results neither count as normal nor reset the streak.
ScheduleState computeSchedule({
  required List<TestHistoryEntry> history,
  required DateTime today,
  required ScheduleConfig config,
}) {
  if (history.isEmpty) {
    return const ScheduleState(status: ScheduleStatus.notTested);
  }
  final ordered = [...history]..sort((a, b) => b.date.compareTo(a.date));
  final last = _dateOnly(ordered.first.date);

  var normalStreak = 0;
  var abnormalPending = false;
  for (final entry in ordered) {
    if (entry.overall == OverallStatus.safe) {
      normalStreak++;
      if (normalStreak >= config.normalResultsToClear) break;
    } else if (entry.overall == OverallStatus.unsafe) {
      abnormalPending = true;
      break;
    }
  }

  final ScheduleMode mode;
  final int days;
  if (abnormalPending) {
    mode = ScheduleMode.afterAbnormal;
    days = config.afterAbnormalDays;
  } else if (config.rainySeasonMonths.contains(last.month)) {
    mode = ScheduleMode.rainySeason;
    days = config.rainySeasonDays;
  } else {
    mode = ScheduleMode.routine;
    days = config.routineDays;
  }

  final due = DateTime.utc(last.year, last.month, last.day + days);
  final now = _dateOnly(today);
  final status = now.isAfter(due)
      ? ScheduleStatus.overdue
      : !now.isBefore(
          DateTime.utc(due.year, due.month, due.day - config.dueSoonDays),
        )
      ? ScheduleStatus.dueSoon
      : ScheduleStatus.ok;
  return ScheduleState(status: status, mode: mode, dueDate: due);
}

DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);
