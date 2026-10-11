import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../repositories/reference_data_repository.dart';
import '../repositories/support.dart';

/// What the dashboard shows (SPEC P9, F-RPT-2/5/7).
class DashboardFilter {
  const DashboardFilter({
    required this.from,
    required this.to,
    this.areaId,
    this.profileId,
  });

  /// Admin unit to show (null: everything on this device, i.e. the user's
  /// whole scope).
  final String? areaId;
  final DateTime from;
  final DateTime to;

  /// Re-evaluate every result under this profile (F-RPT-7). Null shows each
  /// result under the profile used at collection.
  final String? profileId;
}

/// A result as shown: its stored classification, or a re-evaluation.
class ShownResult {
  const ShownResult({
    required this.resultId,
    required this.sessionId,
    required this.testedAt,
    required this.overall,
    required this.profileId,
    required this.profileCode,
    required this.customLimits,
    required this.reEvaluated,
    this.collectorKey,
    this.collectorName,
    this.flagged = false,
  });

  final String resultId;
  final String sessionId;
  final DateTime testedAt;
  final OverallStatus overall;

  /// The profile the [overall] was computed under.
  final String profileId;
  final String profileCode;

  /// Collected under limits edited at calibration (badge, D-MN).
  final bool customLimits;

  /// Computed here under another profile; the stored result is unchanged.
  final bool reEvaluated;
  final String? collectorKey;
  final String? collectorName;

  /// A stakeholder flagged this submission.
  final bool flagged;
}

class SourceView {
  const SourceView({
    required this.id,
    required this.code,
    required this.villageId,
    required this.sourceType,
    required this.functionalStatus,
    required this.schedule,
    required this.history,
    this.name,
    this.lat,
    this.lon,
  });

  final String id;
  final String code;
  final String? name;
  final String villageId;
  final String sourceType;
  final String functionalStatus;
  final double? lat;
  final double? lon;
  final ScheduleState schedule;

  /// Effective results (corrections applied), newest first.
  final List<ShownResult> history;

  ShownResult? get latest => history.isEmpty ? null : history.first;
}

class CollectorActivity {
  const CollectorActivity({
    required this.collectorKey,
    required this.name,
    required this.submissions,
    required this.lastSubmission,
    this.phone,
    this.collectorType,
    this.village,
    this.mark,
  });

  final String collectorKey;
  final String name;
  final String? phone;
  final String? collectorType;
  final String? village;

  /// Tests in the period.
  final int submissions;
  final DateTime lastSubmission;

  /// `known`, `flagged` or null (P9).
  final String? mark;
}

class DashboardData {
  const DashboardData({
    required this.sources,
    required this.testedInPeriod,
    required this.unsafeInPeriod,
    required this.openAlerts,
    required this.collectors,
    required this.profileCode,
    this.medianTimeToAcknowledge,
  });

  final List<SourceView> sources;

  /// Sources with a test in the period, and how many of those were unsafe
  /// (latest test in the period).
  final int testedInPeriod;
  final int unsafeInPeriod;
  final int openAlerts;
  final Duration? medianTimeToAcknowledge;
  final List<CollectorActivity> collectors;

  /// Shown profile, or null for "as collected".
  final String? profileCode;

  double? get unsafeShare =>
      testedInPeriod == 0 ? null : unsafeInPeriod / testedInPeriod;

  List<SourceView> get overdue => [
    for (final s in sources)
      if (s.schedule.status == ScheduleStatus.overdue) s,
  ];
}

/// Computes the dashboard from the local database (works offline on
/// Windows/Android; on the web from the in-memory copy).
class DashboardQueries {
  DashboardQueries(this._db, {this.clock = systemClock})
    : _reference = DriftReferenceDataRepository(_db);

  final AppDatabase _db;
  final Clock clock;
  final DriftReferenceDataRepository _reference;

  /// [areaId] and every admin unit below it.
  Future<Set<String>> unitsUnder(String areaId) async {
    final units = await _db.select(_db.adminUnits).get();
    final children = <String, List<String>>{};
    for (final u in units) {
      final parent = u.parentId;
      if (parent != null) (children[parent] ??= []).add(u.id);
    }
    final out = <String>{areaId};
    final queue = [areaId];
    while (queue.isNotEmpty) {
      for (final c in children[queue.removeLast()] ?? const <String>[]) {
        if (out.add(c)) queue.add(c);
      }
    }
    return out;
  }

  Future<DashboardData> load(DashboardFilter f) async {
    final units = f.areaId == null ? null : await unitsUnder(f.areaId!);
    final sources = [
      for (final s in await (_db.select(
        _db.waterSources,
      )..where((t) => t.isActive.equals(true))).get())
        if (units == null || units.contains(s.villageId)) s,
    ];
    final ids = {for (final s in sources) s.id};

    // All results of these sources, with their sessions.
    final rows = await (_db.select(_db.testResults).join([
      innerJoin(
        _db.testSessions,
        _db.testSessions.id.equalsExp(_db.testResults.sessionId),
      ),
    ])..where(_db.testSessions.sourceId.isIn(ids))).get();
    final corrected = {
      for (final r in rows) ?r.readTable(_db.testResults).amendmentOf,
    };
    final serverOverall = <String, String>{
      for (final c in await (_db.select(
        _db.classifications,
      )..where((c) => c.computedBy.equals('server'))).get())
        '${c.resultId}/${c.standardId}': c.overall,
    };
    final flagged = {
      for (final f in await _db.select(_db.submissionFlags).get()) f.resultId,
    };
    final profiles = {
      for (final p in await _reference.referenceProfiles()) p.id: p,
    };
    final chosen = f.profileId == null ? null : profiles[f.profileId];
    final classifier = chosen == null
        ? null
        : Classifier(
            catalogue: await _reference.catalogue(),
            rules: await _reference.rules(),
          );
    final rules = await _reference.rules();
    // One query for all readings when re-evaluating (2,000 readings, P9).
    final readingsByResult = chosen == null
        ? const <String, List<ReadingInput>>{}
        : await _readingsFor({
            for (final r in rows) r.readTable(_db.testResults).id,
          });

    final bySource = <String, List<ShownResult>>{};
    final seenSessions = <String>{};
    final sorted = [...rows]
      ..sort(
        (a, b) => b
            .readTable(_db.testSessions)
            .testedAtDevice
            .compareTo(a.readTable(_db.testSessions).testedAtDevice),
      );
    for (final row in sorted) {
      final r = row.readTable(_db.testResults);
      final s = row.readTable(_db.testSessions);
      if (corrected.contains(r.id) || !seenSessions.add(s.id)) continue;
      final collected = profiles[r.standardId];
      var overall = OverallStatus.fromCode(
        serverOverall['${r.id}/${r.standardId}'] ?? r.overall,
      );
      var shownProfile = collected;
      if (chosen != null && classifier != null && chosen.id != r.standardId) {
        overall = classifier
            .classify(
              readings: readingsByResult[r.id] ?? const [],
              profile: chosen,
              calibrated: s.calibrated,
            )
            .overall;
        shownProfile = chosen;
      }
      final snapshot = s.collectorSnapshot == null
          ? null
          : (jsonDecode(s.collectorSnapshot!) as Map).cast<String, Object?>();
      (bySource[s.sourceId] ??= []).add(
        ShownResult(
          resultId: r.id,
          sessionId: s.id,
          testedAt: s.testedAtDevice,
          overall: overall,
          profileId: shownProfile?.id ?? r.standardId,
          profileCode: shownProfile?.code ?? '?',
          customLimits: collected?.isCustom ?? false,
          reEvaluated: shownProfile != collected,
          collectorKey: s.collectorKey,
          collectorName: snapshot?['full_name'] as String?,
          flagged: flagged.contains(r.id),
        ),
      );
    }

    final today = clock();
    final views = [
      for (final s in sources)
        SourceView(
          id: s.id,
          code: s.code,
          name: s.name,
          villageId: s.villageId,
          sourceType: s.sourceType,
          functionalStatus: s.functionalStatus,
          lat: s.lat,
          lon: s.lon,
          history: bySource[s.id] ?? const [],
          // The testing schedule follows results as collected.
          schedule: computeSchedule(
            history: [
              for (final h in rows)
                if (h.readTable(_db.testSessions).sourceId == s.id &&
                    !corrected.contains(h.readTable(_db.testResults).id))
                  (
                    date: h.readTable(_db.testSessions).testedAtDevice,
                    overall: OverallStatus.fromCode(
                      h.readTable(_db.testResults).overall,
                    ),
                  ),
            ],
            today: today,
            config: rules.schedule,
          ),
        ),
    ];

    bool inPeriod(DateTime t) => !t.isBefore(f.from) && !t.isAfter(f.to);
    var tested = 0, unsafe = 0;
    for (final v in views) {
      final latestInPeriod = v.history
          .where((h) => inPeriod(h.testedAt))
          .firstOrNull;
      if (latestInPeriod == null) continue;
      tested++;
      if (latestInPeriod.overall == OverallStatus.unsafe) unsafe++;
    }

    final alerts = await (_db.select(
      _db.alerts,
    )..where((a) => a.sourceId.isIn(ids))).get();
    final open = alerts
        .where((a) => !const {'closed', 'false_alarm'}.contains(a.status))
        .length;
    final ackTimes = [
      for (final a in alerts)
        if (a.acknowledgedAt case final ack? when inPeriod(ack))
          ack.difference(a.openedAt),
    ]..sort();
    final median = ackTimes.isEmpty
        ? null
        : ackTimes.length.isOdd
        ? ackTimes[ackTimes.length ~/ 2]
        : (ackTimes[ackTimes.length ~/ 2 - 1] +
                  ackTimes[ackTimes.length ~/ 2]) ~/
              2;

    return DashboardData(
      sources: views,
      testedInPeriod: tested,
      unsafeInPeriod: unsafe,
      openAlerts: open,
      medianTimeToAcknowledge: median,
      collectors: await _collectors(rows, f, inPeriod),
      profileCode: chosen?.code,
    );
  }

  Future<Map<String, List<ReadingInput>>> _readingsFor(Set<String> ids) async {
    final out = <String, List<ReadingInput>>{};
    for (final r in await (_db.select(
      _db.readings,
    )..where((t) => t.resultId.isIn(ids))).get()) {
      (out[r.resultId] ??= []).add(
        ReadingInput(
          parameterCode: r.parameterCode,
          unit: r.unit,
          value: r.value == null ? null : Decimal.parse(r.value!),
          detected: r.detected,
          acceptable: r.acceptable,
          text: r.valueText,
          isDerived: r.isDerived,
        ),
      );
    }
    return out;
  }

  Future<List<CollectorActivity>> _collectors(
    List<TypedResult> rows,
    DashboardFilter f,
    bool Function(DateTime) inPeriod,
  ) async {
    final marks = {
      for (final m in await _db.select(_db.collectorMarks).get())
        m.collectorKey: m.status,
    };
    final latest = <String, TestSessionRow>{};
    final counts = <String, int>{};
    final sessions = {
      for (final r in rows)
        r.readTable(_db.testSessions).id: r.readTable(_db.testSessions),
    };
    for (final s in sessions.values) {
      final key = s.collectorKey;
      if (key == null || !inPeriod(s.testedAtDevice)) continue;
      counts[key] = (counts[key] ?? 0) + 1;
      final prev = latest[key];
      if (prev == null || s.testedAtDevice.isAfter(prev.testedAtDevice)) {
        latest[key] = s;
      }
    }
    final out = [
      for (final e in latest.entries)
        () {
          final snap = e.value.collectorSnapshot == null
              ? const <String, Object?>{}
              : (jsonDecode(e.value.collectorSnapshot!) as Map)
                    .cast<String, Object?>();
          return CollectorActivity(
            collectorKey: e.key,
            name: (snap['full_name'] as String?) ?? '?',
            phone: snap['phone'] as String?,
            collectorType: snap['collector_type'] as String?,
            village: snap['village'] as String?,
            submissions: counts[e.key]!,
            lastSubmission: e.value.testedAtDevice,
            mark: marks[e.key],
          );
        }(),
    ]..sort((a, b) => b.lastSubmission.compareTo(a.lastSubmission));
    return out;
  }
}
