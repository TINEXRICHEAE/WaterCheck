import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// What the sync indicator shows (F-SYN-2). Sending arrives in P6.
typedef SyncSummary = ({int pending, int rejected, DateTime? lastSuccessAt});

abstract interface class OutboxRepository {
  Stream<SyncSummary> watchSummary();
  Future<List<OutboxRow>> pending({int limit = 50});

  /// Everything not yet accepted by the server (pending and rejected), oldest
  /// first: what the export before a wipe must save (F-AUTH-4, F-SYN-5).
  Future<List<OutboxRow>> unsynced();

  /// Records the server refused, newest first, with its reason
  /// (`last_error`); they are never deleted (SPEC §8.1, F-SYN-2).
  Stream<List<OutboxRow>> watchRejected();

  /// Sending health: last attempt and success, backoff, last error.
  Stream<SyncStateRow?> watchPushState();

  /// Whether a record is still waiting to be sent (SMS fallback, §8.5).
  Future<bool> isUnsent(String entity, String entityId);
}

/// The plain content of an export file (encrypted by `ExportFile`).
Map<String, Object?> unsyncedExportContent({
  required String installationId,
  required int schemaVersion,
  required DateTime exportedAt,
  required List<OutboxRow> rows,
}) => {
  'installation_id': installationId,
  'schema_version': schemaVersion,
  'exported_at': exportedAt.toUtc().toIso8601String(),
  'items': [
    for (final r in rows)
      {
        'outbox_id': r.id,
        'entity': r.entity,
        'entity_id': r.entityId,
        'op': r.op,
        'base_version': r.baseVersion,
        'created_at': r.createdAt.toUtc().toIso8601String(),
        'status': r.status,
        'last_error': r.lastError,
        'payload': jsonDecode(r.payload),
      },
  ],
};

class DriftOutboxRepository implements OutboxRepository {
  DriftOutboxRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<SyncSummary> watchSummary() {
    final count = _db.outbox.id.count();
    final query = _db.selectOnly(_db.outbox)
      ..addColumns([_db.outbox.status, count])
      ..groupBy([_db.outbox.status]);
    final last = _db.syncState.lastSuccessAt.max();
    final lastQuery = _db.selectOnly(_db.syncState)..addColumns([last]);
    return query.watch().asyncMap((rows) async {
      final byStatus = {
        for (final r in rows) r.read(_db.outbox.status)!: r.read(count) ?? 0,
      };
      final lastSuccess = await lastQuery.map((r) => r.read(last)).getSingle();
      return (
        pending: byStatus['pending'] ?? 0,
        rejected: byStatus['rejected'] ?? 0,
        lastSuccessAt: lastSuccess,
      );
    });
  }

  @override
  Future<List<OutboxRow>> pending({int limit = 50}) =>
      (_db.select(_db.outbox)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm(expression: t.id)])
            ..limit(limit))
          .get();

  @override
  Stream<List<OutboxRow>> watchRejected() =>
      (_db.select(_db.outbox)
            ..where((t) => t.status.equals('rejected'))
            ..orderBy([(t) => OrderingTerm.desc(t.id)]))
          .watch();

  @override
  Stream<SyncStateRow?> watchPushState() => (_db.select(
    _db.syncState,
  )..where((t) => t.stream.equals('push'))).watchSingleOrNull();

  @override
  Future<bool> isUnsent(String entity, String entityId) async =>
      (await (_db.select(_db.outbox)..where(
                (t) =>
                    t.entity.equals(entity) &
                    t.entityId.equals(entityId) &
                    t.status.equals('pending'),
              ))
              .get())
          .isNotEmpty;

  @override
  Future<List<OutboxRow>> unsynced() =>
      (_db.select(_db.outbox)
            ..where((t) => t.status.isNotIn(const ['sent']))
            ..orderBy([(t) => OrderingTerm(expression: t.id)]))
          .get();
}
