import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// One change: a field, its old and new values, who and when (ADR-018).
class TrailEntry {
  const TrailEntry({
    required this.field,
    required this.oldValue,
    required this.newValue,
    required this.who,
    required this.at,
    this.reason,
  });

  /// A column name (`name`, `households_served`) or, for a test, a
  /// parameter code (`ph`) or `overall`.
  final String field;
  final String? oldValue;
  final String? newValue;
  final String? who;
  final DateTime at;
  final String? reason;
}

/// Edit trails for display: the server's field-level trail for sources,
/// collectors and phones, and corrections of a test worked out from its
/// results (each correction is a new result; nothing is overwritten).
class TrailQueries {
  TrailQueries(this._db);

  final AppDatabase _db;

  /// Newest first.
  Future<List<TrailEntry>> forRecord(String entity, String recordId) async {
    final rows =
        await (_db.select(_db.changeTrails)
              ..where(
                (t) => t.entity.equals(entity) & t.recordId.equals(recordId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.changedAt)]))
            .get();
    return [
      for (final r in rows)
        TrailEntry(
          field: r.field,
          oldValue: _plain(r.oldValue),
          newValue: _plain(r.newValue),
          who: r.actorName,
          at: r.changedAt,
          reason: r.reason,
        ),
    ];
  }

  /// Corrections of one test, newest first: every reading (and the overall
  /// result) whose value changed, with who corrected it and why.
  Future<List<TrailEntry>> forTest(String sessionId) async {
    final session = await (_db.select(
      _db.testSessions,
    )..where((s) => s.id.equals(sessionId))).getSingleOrNull();
    final results =
        await (_db.select(_db.testResults)
              ..where((r) => r.sessionId.equals(sessionId))
              ..orderBy([(r) => OrderingTerm.asc(r.createdAtDevice)]))
            .get();
    final byId = {for (final r in results) r.id: r};
    final out = <TrailEntry>[];
    for (final r in results) {
      final before = r.amendmentOf == null ? null : byId[r.amendmentOf];
      if (before == null) continue;
      final who =
          _name(r.collectorSnapshot) ?? _name(session?.collectorSnapshot);
      final old = await _readings(before.id);
      final now = await _readings(r.id);
      if (before.overall != r.overall) {
        out.add(
          TrailEntry(
            field: 'overall',
            oldValue: before.overall,
            newValue: r.overall,
            who: who,
            at: r.createdAtDevice,
            reason: r.amendmentReason,
          ),
        );
      }
      for (final code in {...old.keys, ...now.keys}) {
        if (old[code] == now[code]) continue;
        out.add(
          TrailEntry(
            field: code,
            oldValue: old[code],
            newValue: now[code],
            who: who,
            at: r.createdAtDevice,
            reason: r.amendmentReason,
          ),
        );
      }
    }
    return out.reversed.toList();
  }

  Future<Map<String, String>> _readings(String resultId) async {
    final rows = await (_db.select(
      _db.readings,
    )..where((g) => g.resultId.equals(resultId))).get();
    return {
      for (final g in rows)
        g.parameterCode:
            g.value ??
            g.valueText ??
            (g.detected == null
                ? (g.acceptable == null
                      ? ''
                      : (g.acceptable! ? 'acceptable' : 'not acceptable'))
                : (g.detected! ? 'detected' : 'not detected')),
    };
  }

  static String? _name(String? snapshot) {
    if (snapshot == null) return null;
    try {
      final j = jsonDecode(snapshot);
      return j is Map ? j['full_name'] as String? : null;
    } on FormatException {
      return null;
    }
  }

  /// Server values are JSON text: `"Upper borehole"` → Upper borehole.
  static String? _plain(String? json) {
    if (json == null || json == 'null') return null;
    try {
      final v = jsonDecode(json);
      return v is String ? v : '$v';
    } on FormatException {
      return json;
    }
  }
}
