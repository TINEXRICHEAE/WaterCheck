import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

typedef AlertSummary = ({
  String id,
  String sourceId,
  String? triggerResultId,
  String triggerRule,
  String severity,
  AlertStatus status,
  DateTime openedAt,
});

typedef AlertEventSummary = ({
  String id,
  String eventType,
  List<String> actions,
  String? note,
  DateTime occurredAt,
  String? byName,
  String? actorId,
});

/// An alert as the Console lists it.
typedef AlertListItem = ({
  String id,
  String sourceId,
  String sourceCode,
  String? sourceName,
  String? triggerResultId,
  String triggerRule,
  String severity,
  AlertStatus status,
  DateTime openedAt,
});

/// Alerts raised on this device and the actions recorded against them.
/// Status changes (acknowledge, close) belong to stakeholders (P8); Collect
/// only appends events, which never conflict (SPEC §8.4).
abstract interface class AlertRepository {
  Stream<List<AlertSummary>> watchOpen({String? sourceId});
  Future<List<AlertSummary>> forResult(String resultId);
  Future<AlertSummary?> alert(String id);

  /// Records the actions a collector took (response-card checklist).
  Future<String> recordActions(
    String alertId, {
    required List<String> actions,
    required SubmissionOrigin origin,
    String? note,
  });

  Future<List<AlertEventSummary>> events(String alertId);

  /// Alerts with their source, most severe first, then the longest
  /// waiting (SPEC P9 inbox); open ones only by default.
  Stream<List<AlertListItem>> watchList({bool openOnly = true});

  /// A stakeholder moves the alert on (F-ALR-3). The transition is checked
  /// here and again by the server, which is authoritative (§8.4); the local
  /// status changes at once so the screen follows.
  Future<String> changeStatus(
    String alertId,
    AlertStatus next, {
    required SubmissionOrigin origin,
    String? note,
  });

  /// A note, or `lab_requested` (lab confirmation asked for), with no
  /// status change.
  Future<String> addNote(
    String alertId, {
    required String eventType,
    required String note,
    required SubmissionOrigin origin,
  });
}

class DriftAlertRepository implements AlertRepository {
  DriftAlertRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  static AlertSummary _summary(AlertRow a) => (
    id: a.id,
    sourceId: a.sourceId,
    triggerResultId: a.triggerResultId,
    triggerRule: a.triggerRule,
    severity: a.severity,
    status: AlertStatus.fromCode(a.status),
    openedAt: a.openedAt,
  );

  @override
  Stream<List<AlertSummary>> watchOpen({String? sourceId}) {
    final query = _db.select(_db.alerts)
      ..where((a) => a.status.isNotIn(['closed', 'false_alarm']))
      ..orderBy([(a) => OrderingTerm.desc(a.openedAt)]);
    if (sourceId != null) query.where((a) => a.sourceId.equals(sourceId));
    return query.watch().map((rows) => rows.map(_summary).toList());
  }

  @override
  Future<AlertSummary?> alert(String id) async {
    final row = await (_db.select(
      _db.alerts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    return row == null ? null : _summary(row);
  }

  @override
  Future<List<AlertSummary>> forResult(String resultId) async {
    final rows = await (_db.select(
      _db.alerts,
    )..where((a) => a.triggerResultId.equals(resultId))).get();
    return rows.map(_summary).toList();
  }

  @override
  Future<String> recordActions(
    String alertId, {
    required List<String> actions,
    required SubmissionOrigin origin,
    String? note,
  }) => _db.transaction(() async {
    final now = clock();
    final event = await _db
        .into(_db.alertEvents)
        .insertReturning(
          AlertEventsCompanion.insert(
            id: ids.next(),
            alertId: alertId,
            actorId: Value(origin.userId),
            eventType: 'action_taken',
            note: Value(jsonEncode({'actions': actions, 'note': ?note})),
            occurredAtDevice: now,
            installationId: Value(origin.installationId),
            collectorKey: Value(origin.collectorKey),
            collectorSnapshot: Value(origin.snapshotJson),
          ),
        );
    await enqueueOutbox(
      _db,
      entity: 'alert_event',
      entityId: event.id,
      op: OutboxOp.insert,
      payload: event.toJson(serializer: syncSerializer),
      at: now,
    );
    return event.id;
  });

  @override
  Future<List<AlertEventSummary>> events(String alertId) async {
    final rows =
        await (_db.select(_db.alertEvents)
              ..where((e) => e.alertId.equals(alertId))
              ..orderBy([(e) => OrderingTerm(expression: e.occurredAtDevice)]))
            .get();
    return [
      for (final e in rows)
        () {
          final body = e.note == null
              ? const <String, Object?>{}
              : (jsonDecode(e.note!) as Map).cast<String, Object?>();
          final who = e.collectorSnapshot == null
              ? null
              : (jsonDecode(e.collectorSnapshot!) as Map)['full_name']
                    as String?;
          return (
            id: e.id,
            eventType: e.eventType,
            actions: ((body['actions'] as List?) ?? const []).cast<String>(),
            note: body['note'] as String?,
            occurredAt: e.occurredAtDevice,
            byName: who,
            actorId: e.actorId,
          );
        }(),
    ];
  }

  @override
  Stream<List<AlertListItem>> watchList({bool openOnly = true}) {
    final q = _db.select(_db.alerts).join([
      innerJoin(
        _db.waterSources,
        _db.waterSources.id.equalsExp(_db.alerts.sourceId),
      ),
    ]);
    if (openOnly) {
      q.where(_db.alerts.status.isNotIn(['closed', 'false_alarm']));
    }
    const rank = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
    return q.watch().map(
      (rows) =>
          [
            for (final r in rows)
              () {
                final a = r.readTable(_db.alerts);
                final w = r.readTable(_db.waterSources);
                return (
                  id: a.id,
                  sourceId: a.sourceId,
                  sourceCode: w.code,
                  sourceName: w.name,
                  triggerResultId: a.triggerResultId,
                  triggerRule: a.triggerRule,
                  severity: a.severity,
                  status: AlertStatus.fromCode(a.status),
                  openedAt: a.openedAt,
                );
              }(),
          ]..sort(
            (a, b) =>
                (rank[a.severity] ?? 9).compareTo(rank[b.severity] ?? 9) != 0
                ? (rank[a.severity] ?? 9).compareTo(rank[b.severity] ?? 9)
                : a.openedAt.compareTo(b.openedAt),
          ),
    );
  }

  Future<String> _event(
    String alertId,
    String eventType,
    String note,
    SubmissionOrigin origin,
    DateTime now,
  ) async {
    final event = await _db
        .into(_db.alertEvents)
        .insertReturning(
          AlertEventsCompanion.insert(
            id: ids.next(),
            alertId: alertId,
            actorId: Value(origin.userId),
            eventType: eventType,
            note: Value(note),
            occurredAtDevice: now,
            installationId: Value(origin.installationId),
            collectorKey: Value(origin.collectorKey),
            collectorSnapshot: Value(origin.snapshotJson),
          ),
        );
    await enqueueOutbox(
      _db,
      entity: 'alert_event',
      entityId: event.id,
      op: OutboxOp.insert,
      payload: event.toJson(serializer: syncSerializer),
      at: now,
    );
    return event.id;
  }

  @override
  Future<String> changeStatus(
    String alertId,
    AlertStatus next, {
    required SubmissionOrigin origin,
    String? note,
  }) => _db.transaction(() async {
    final row = await (_db.select(
      _db.alerts,
    )..where((a) => a.id.equals(alertId))).getSingle();
    final current = AlertStatus.fromCode(row.status);
    if (!current.canTransitionTo(next)) {
      throw StateError('Cannot go from ${current.code} to ${next.code}');
    }
    final now = clock();
    await (_db.update(_db.alerts)..where((a) => a.id.equals(alertId))).write(
      AlertsCompanion(
        status: Value(next.code),
        acknowledgedAt: next == AlertStatus.acknowledged
            ? Value(now)
            : const Value.absent(),
        closedAt: next.isTerminal ? Value(now) : const Value.absent(),
      ),
    );
    return _event(alertId, next.code, jsonEncode({'note': ?note}), origin, now);
  });

  @override
  Future<String> addNote(
    String alertId, {
    required String eventType,
    required String note,
    required SubmissionOrigin origin,
  }) => _db.transaction(
    () =>
        _event(alertId, eventType, jsonEncode({'note': note}), origin, clock()),
  );
}
