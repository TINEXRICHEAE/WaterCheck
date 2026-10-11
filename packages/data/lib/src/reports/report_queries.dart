import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../dashboard/dashboard_queries.dart';
import '../db/database.dart';
import '../repositories/reference_data_repository.dart';
import '../repositories/support.dart';

/// What a report covers: one area (or all the user's), one period.
class ReportFilter {
  const ReportFilter({this.areaId, required this.from, required this.to});

  final String? areaId;
  final DateTime from;
  final DateTime to;
}

/// One reading of a source's latest test, against its limit.
typedef ReportReading = ({
  String parameterCode,
  String parameterName,
  String? value,
  String unit,
  ReadingResult result,

  /// e.g. "6.5–8.5 pH", "≤ 10 NTU", "must be absent"; null: no limit.
  String? limit,
});

typedef ReportSource = ({
  String id,
  String code,
  String? name,
  String village,
  String functionalStatus,
  DateTime? testedAt,
  OverallStatus? overall,
  String? profileCode,
  ScheduleStatus schedule,
  List<ReportReading> readings,
});

typedef ReportAlert = ({
  String sourceCode,
  String? sourceName,
  String rule,
  String severity,
  String status,
  DateTime openedAt,
  DateTime? acknowledgedAt,
  DateTime? closedAt,

  /// What was done, oldest first: "acknowledged", "action_taken: …".
  List<String> actions,
});

/// A limit set used by results in the report; custom ones list the limits
/// that differ from the set they were based on (SPEC P10).
typedef ReportProfile = ({
  String code,
  String title,
  int version,
  bool isCustom,
  bool isProvisional,
  String? customReason,
  String? basedOnCode,
  List<String> changedLimits,
});

/// The proposal's impact indicators (F-RPT-6).
typedef ImpactIndicators = ({
  int sourcesTotal,
  int sourcesTested,
  int testsInPeriod,
  int abnormalTests,

  /// Abnormal tests whose alert records an action (collector actions,
  /// action in progress, closed).
  int abnormalWithAction,

  /// Sources tested at least once and not overdue now (reporting
  /// timeliness).
  int sourcesOnSchedule,
  int sourcesWithSchedule,
  int collectorsActive,
  Duration? medianTimeToAcknowledge,
});

class ReportData {
  const ReportData({
    required this.areaName,
    required this.filter,
    required this.generatedAt,
    required this.sources,
    required this.alerts,
    required this.profiles,
    required this.indicators,
  });

  final String areaName;
  final ReportFilter filter;
  final DateTime generatedAt;
  final List<ReportSource> sources;
  final List<ReportAlert> alerts;
  final List<ReportProfile> profiles;
  final ImpactIndicators indicators;
}

/// Builds reports and exports from the local database (generated on the
/// device, works offline; SPEC P10). Results are shown as collected, with
/// the same rules as the dashboard: a correction replaces what it
/// corrects, and the server's classification wins.
class ReportQueries {
  ReportQueries(this._db, {this.clock = systemClock})
    : _reference = DriftReferenceDataRepository(_db),
      _dashboard = DashboardQueries(_db, clock: clock);

  final AppDatabase _db;
  final Clock clock;
  final DriftReferenceDataRepository _reference;
  final DashboardQueries _dashboard;

  static const _actionEvents = {'action_taken', 'action_in_progress', 'closed'};

  Future<ReportData> report(ReportFilter f) async {
    final d = await _dashboard.load(
      DashboardFilter(areaId: f.areaId, from: f.from, to: f.to),
    );
    final units = {for (final u in await _reference.adminUnits()) u.id: u};
    final catalogue = await _reference.catalogue();
    final profiles = {
      for (final p in await _reference.referenceProfiles()) p.id: p,
    };
    bool inPeriod(DateTime t) => !t.isBefore(f.from) && !t.isAfter(f.to);

    // Latest test of each source, with its readings against its limits.
    final latestIds = {
      for (final s in d.sources)
        if (s.latest case final l?) l.resultId,
    };
    final readings = <String, List<ReadingRow>>{};
    for (final r in await (_db.select(
      _db.readings,
    )..where((t) => t.resultId.isIn(latestIds))).get()) {
      (readings[r.resultId] ??= []).add(r);
    }
    final sources = [
      for (final s in d.sources)
        () {
          final l = s.latest;
          final profile = l == null ? null : profiles[l.profileId];
          return (
            id: s.id,
            code: s.code,
            name: s.name,
            village: units[s.villageId]?.name ?? '',
            functionalStatus: s.functionalStatus,
            testedAt: l?.testedAt,
            overall: l?.overall,
            profileCode: l?.profileCode,
            schedule: s.schedule.status,
            readings: [
              for (final r in readings[l?.resultId] ?? const <ReadingRow>[])
                (
                  parameterCode: r.parameterCode,
                  parameterName:
                      catalogue[r.parameterCode]?.name ?? r.parameterCode,
                  value:
                      r.value ??
                      r.valueText ??
                      (r.detected == null
                          ? null
                          : (r.detected! ? 'detected' : 'not detected')),
                  unit: r.unit ?? '',
                  result: ReadingResult.fromCode(r.result),
                  limit: _limitText(profile?.limitFor(r.parameterCode)),
                ),
            ]..sort((a, b) => a.parameterName.compareTo(b.parameterName)),
          );
        }(),
    ]..sort((a, b) => a.code.compareTo(b.code));

    // Alerts opened in the period, with what was done.
    final ids = {for (final s in d.sources) s.id};
    final byId = {for (final s in d.sources) s.id: s};
    final alertRows =
        await (_db.select(_db.alerts)
              ..where((a) => a.sourceId.isIn(ids))
              ..orderBy([(a) => OrderingTerm(expression: a.openedAt)]))
            .get();
    final events = <String, List<AlertEventRow>>{};
    for (final e
        in await (_db.select(_db.alertEvents)
              ..where((e) => e.alertId.isIn([for (final a in alertRows) a.id]))
              ..orderBy([(e) => OrderingTerm(expression: e.occurredAtDevice)]))
            .get()) {
      (events[e.alertId] ??= []).add(e);
    }
    final alerts = [
      for (final a in alertRows)
        if (inPeriod(a.openedAt))
          (
            sourceCode: byId[a.sourceId]!.code,
            sourceName: byId[a.sourceId]!.name,
            rule: a.triggerRule,
            severity: a.severity,
            status: a.status,
            openedAt: a.openedAt,
            acknowledgedAt: a.acknowledgedAt,
            closedAt: a.closedAt,
            actions: [
              for (final e in events[a.id] ?? const <AlertEventRow>[])
                _eventText(e),
            ],
          ),
    ];

    // Indicators.
    final shownInPeriod = [
      for (final s in d.sources)
        for (final h in s.history)
          if (inPeriod(h.testedAt)) h,
    ];
    final abnormal = [
      for (final h in shownInPeriod)
        if (h.overall == OverallStatus.unsafe) h,
    ];
    final actedOn = {
      for (final a in alertRows)
        if (a.triggerResultId != null &&
            (events[a.id] ?? const []).any(
              (e) => _actionEvents.contains(e.eventType),
            ))
          a.triggerResultId!,
    };
    final withSchedule = [
      for (final s in d.sources)
        if (s.schedule.status != ScheduleStatus.notTested) s,
    ];

    // Limit sets used in the period.
    final usedIds = {for (final h in shownInPeriod) h.profileId};
    final used = [
      for (final id in usedIds)
        if (profiles[id] case final p?)
          (
            code: p.code,
            title: p.title,
            version: p.version,
            isCustom: p.isCustom,
            isProvisional: p.isProvisional,
            customReason: p.customReason,
            basedOnCode: p.basedOnId == null
                ? null
                : profiles[p.basedOnId]?.code,
            changedLimits: p.isCustom
                ? _changed(p, profiles[p.basedOnId], catalogue)
                : const <String>[],
          ),
    ]..sort((a, b) => a.code.compareTo(b.code));

    return ReportData(
      areaName: f.areaId == null
          ? 'All areas'
          : units[f.areaId]?.name ?? 'Unknown area',
      filter: f,
      generatedAt: clock(),
      sources: sources,
      alerts: alerts,
      profiles: used,
      indicators: (
        sourcesTotal: d.sources.length,
        sourcesTested: d.testedInPeriod,
        testsInPeriod: shownInPeriod.length,
        abnormalTests: abnormal.length,
        abnormalWithAction: abnormal
            .where((h) => actedOn.contains(h.resultId))
            .length,
        sourcesOnSchedule: withSchedule
            .where((s) => s.schedule.status != ScheduleStatus.overdue)
            .length,
        sourcesWithSchedule: withSchedule.length,
        collectorsActive: d.collectors.length,
        medianTimeToAcknowledge: d.medianTimeToAcknowledge,
      ),
    );
  }

  /// One source with its latest test and readings, for its community
  /// notice (F-ALR-5). Null if it is not in the local data.
  Future<ReportSource?> source(String id) async {
    final now = clock();
    final r = await report(
      ReportFilter(from: now.subtract(const Duration(days: 3650)), to: now),
    );
    return r.sources.where((s) => s.id == id).firstOrNull;
  }

  /// CSV of readings (F-RPT-4): UTF-8 with a byte-order mark (so
  /// spreadsheets detect it), ISO 8601 UTC dates, one row per reading of
  /// each test in the period (corrections replace what they correct), and
  /// the limit set's code and version on every row.
  Future<String> readingsCsv(ReportFilter f) async {
    final d = await _dashboard.load(
      DashboardFilter(areaId: f.areaId, from: f.from, to: f.to),
    );
    final units = {for (final u in await _reference.adminUnits()) u.id: u};
    final catalogue = await _reference.catalogue();
    final profiles = {
      for (final p in await _reference.referenceProfiles()) p.id: p,
    };
    final results = <String, (SourceView, ShownResult)>{
      for (final s in d.sources)
        for (final h in s.history)
          if (!h.testedAt.isBefore(f.from) && !h.testedAt.isAfter(f.to))
            h.resultId: (s, h),
    };
    final rows =
        await (_db.select(_db.readings)
              ..where((r) => r.resultId.isIn(results.keys))
              ..orderBy([(r) => OrderingTerm(expression: r.parameterCode)]))
            .get();
    final ordered = [...rows]
      ..sort((a, b) {
        final ta = results[a.resultId]!.$2.testedAt;
        final tb = results[b.resultId]!.$2.testedAt;
        final c = ta.compareTo(tb);
        return c != 0 ? c : a.parameterCode.compareTo(b.parameterCode);
      });
    final out = StringBuffer('﻿')..writeln(_csvLine(_csvHeader));
    for (final r in ordered) {
      final (s, h) = results[r.resultId]!;
      final profile = profiles[h.profileId];
      out.writeln(
        _csvLine([
          s.code,
          s.name ?? '',
          units[s.villageId]?.name ?? '',
          h.testedAt.toUtc().toIso8601String(),
          h.collectorName ?? '',
          h.resultId,
          h.overall.name,
          h.profileCode,
          '${profile?.version ?? ''}',
          (profile?.isCustom ?? false) ? 'yes' : 'no',
          r.parameterCode,
          catalogue[r.parameterCode]?.name ?? '',
          r.value ?? '',
          r.valueText ?? '',
          r.detected == null ? '' : (r.detected! ? 'yes' : 'no'),
          r.unit ?? '',
          r.result,
          r.isDerived ? 'yes' : 'no',
          h.flagged ? 'yes' : 'no',
        ]),
      );
    }
    return out.toString();
  }

  static const _csvHeader = [
    'source_code',
    'source_name',
    'village',
    'tested_at_utc',
    'collector',
    'result_id',
    'overall',
    'standard_code',
    'standard_version',
    'custom_limits',
    'parameter_code',
    'parameter_name',
    'value',
    'value_text',
    'detected',
    'unit',
    'reading_result',
    'derived',
    'flagged',
  ];

  static String _csvLine(List<String> cells) => [
    for (final c in cells)
      c.contains(RegExp('[",\r\n]')) ? '"${c.replaceAll('"', '""')}"' : c,
  ].join(',');

  static String? _limitText(ParameterLimit? l) {
    if (l == null) return null;
    if (l.mustBeAbsent) return 'must be absent';
    if (l.mustBeAcceptable) return 'must be acceptable';
    final unit = l.unit.isEmpty ? '' : ' ${l.unit}';
    if (l.min != null && l.max != null) return '${l.min}–${l.max}$unit';
    if (l.max != null) return '≤ ${l.max}$unit';
    if (l.min != null) return '≥ ${l.min}$unit';
    return null;
  }

  static List<String> _changed(
    ReferenceProfile custom,
    ReferenceProfile? base,
    ParameterCatalogue catalogue,
  ) => [
    for (final l in custom.limits)
      if (_limitText(l) != _limitText(base?.limitFor(l.parameterCode)))
        '${catalogue[l.parameterCode]?.name ?? l.parameterCode}: '
            '${_limitText(l) ?? 'no limit'}'
            ' (was ${_limitText(base?.limitFor(l.parameterCode)) ?? 'no limit'})',
  ];

  static String _eventText(AlertEventRow e) {
    final note = e.note;
    if (note == null || note.isEmpty) return e.eventType;
    try {
      final body = jsonDecode(note);
      if (body is Map) {
        final parts = [
          ...((body['actions'] as List?) ?? const []).map((a) => '$a'),
          if (body['note'] case final String n when n.isNotEmpty) n,
        ];
        return parts.isEmpty
            ? e.eventType
            : '${e.eventType}: ${parts.join('; ')}';
      }
    } on FormatException {
      // A plain-text note.
    }
    return '${e.eventType}: $note';
  }
}
