import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../repositories/support.dart';

typedef _Apply = Future<void> Function(AppDatabase db, Map<String, Object?> j);

Future<void> _upsert<T extends Table, R>(
  AppDatabase db,
  TableInfo<T, R> table,
  Insertable<R> row,
) => db.into(table).insertOnConflictUpdate(row);

/// Insert-only records (SPEC §5.4) never change once written, and local
/// triggers forbid updating them: a copy we already hold is kept as is.
Future<void> _keep<T extends Table, R>(
  AppDatabase db,
  TableInfo<T, R> table,
  Insertable<R> row,
) => db.into(table).insert(row, mode: InsertMode.insertOrIgnore);

/// Writes rows from the server into the local tables (SPEC §8.2). Server
/// JSON uses the SQL column names, like the local tables' JSON keys; JSON
/// values (objects, lists) are stored as text locally.
class PullApplier {
  PullApplier(this._db);

  final AppDatabase _db;

  static const _s = syncSerializer;

  static final Map<String, _Apply> _appliers = {
    'admin_unit': (db, j) =>
        _upsert(db, db.adminUnits, AdminUnitRow.fromJson(j, serializer: _s)),
    'parameter_category': (db, j) => _upsert(
      db,
      db.parameterCategories,
      ParameterCategoryRow.fromJson(j, serializer: _s),
    ),
    'parameter_definition': (db, j) => _upsert(
      db,
      db.parameterDefinitions,
      ParameterDefinitionRow.fromJson(j, serializer: _s),
    ),
    'tester_profile': (db, j) => _upsert(
      db,
      db.testerProfiles,
      TesterProfileRow.fromJson(j, serializer: _s),
    ),
    'reference_standard': (db, j) => _upsert(
      db,
      db.referenceProfiles,
      ReferenceProfileRow.fromJson(j, serializer: _s),
    ),
    'response_card': (db, j) => _upsert(
      db,
      db.responseCards,
      ResponseCardRow.fromJson(j, serializer: _s),
    ),
    'config_document': (db, j) => _upsert(
      db,
      db.configDocuments,
      ConfigDocumentRow.fromJson(j, serializer: _s),
    ),
    'water_source': (db, j) => _upsert(
      db,
      db.waterSources,
      WaterSourceRow.fromJson(j, serializer: _s),
    ),
    'calibration': (db, j) =>
        _keep(db, db.calibrations, CalibrationRow.fromJson(j, serializer: _s)),
    'test_session': (db, j) =>
        _keep(db, db.testSessions, TestSessionRow.fromJson(j, serializer: _s)),
    'test_result': (db, j) =>
        _keep(db, db.testResults, TestResultRow.fromJson(j, serializer: _s)),
    'reading': (db, j) =>
        _keep(db, db.readings, ReadingRow.fromJson(j, serializer: _s)),
    'classification': (db, j) => _upsert(
      db,
      db.classifications,
      ClassificationRow.fromJson(j, serializer: _s),
    ),
    'alert': (db, j) =>
        _upsert(db, db.alerts, AlertRow.fromJson(j, serializer: _s)),
    'alert_event': (db, j) =>
        _keep(db, db.alertEvents, AlertEventRow.fromJson(j, serializer: _s)),
    // A picture its author removed (ADR-022) leaves this device.
    'attachment': (db, j) async {
      if (j['removed_at'] != null) {
        final id = j['id']! as String;
        await (db.delete(
          db.attachmentQueue,
        )..where((q) => q.attachmentId.equals(id))).go();
        await (db.delete(db.attachments)..where((a) => a.id.equals(id))).go();
        return;
      }
      await _upsert(
        db,
        db.attachments,
        AttachmentRow.fromJson(j, serializer: _s),
      );
    },
    'collector_mark': (db, j) => _upsert(
      db,
      db.collectorMarks,
      CollectorMarkRow.fromJson(j, serializer: _s),
    ),
    'submission_flag': (db, j) => _keep(
      db,
      db.submissionFlags,
      SubmissionFlagRow.fromJson(j, serializer: _s),
    ),
    'sanitary_inspection': (db, j) => _keep(
      db,
      db.sanitaryInspections,
      SanitaryInspectionRow.fromJson(j, serializer: _s),
    ),
    'place_name': (db, j) =>
        _upsert(db, db.placeNames, PlaceNameRow.fromJson(j, serializer: _s)),
    'change_trail': (db, j) =>
        _keep(db, db.changeTrails, ChangeTrailRow.fromJson(j, serializer: _s)),
    // A message (ADR-022): the server's copy fills in the author and time,
    // and never clears this device's "read".
    'message': (db, j) {
      final row = MessageRow.fromJson(j, serializer: _s);
      return db
          .into(db.messages)
          .insert(
            row,
            onConflict: DoUpdate(
              (_) => MessagesCompanion(
                authorName: Value(row.authorName),
                createdAtServer: Value(row.createdAtServer),
                serverSeq: Value(row.serverSeq),
              ),
            ),
          );
    },
  };

  /// True once a restored archive was seen: the records it brings back sit
  /// earlier in the feed, so the stream is pulled again from the start.
  bool restored = false;

  /// An archive mark (ADR-018): archived records and what hangs off them
  /// leave the device; unsent changes to them are marked refused.
  Future<void> _archiveMark(Map<String, Object?> j) async {
    final entity = j['entity']! as String;
    final id = j['record_id']! as String;
    final archived = j['archived'] == true || j['archived'] == 1;
    final before =
        await (_db.select(_db.archiveMarks)
              ..where((m) => m.entity.equals(entity) & m.recordId.equals(id)))
            .getSingleOrNull();
    await _db
        .into(_db.archiveMarks)
        .insertOnConflictUpdate(ArchiveMarkRow.fromJson(j, serializer: _s));
    if (!archived) {
      if (before?.archived ?? false) restored = true;
      return;
    }
    final gone = <String>[id];
    switch (entity) {
      case 'test_session':
        final results = await (_db.select(
          _db.testResults,
        )..where((r) => r.sessionId.equals(id))).map((r) => r.id).get();
        gone.addAll(results);
        await (_db.delete(
          _db.readings,
        )..where((r) => r.sessionId.equals(id))).go();
        await (_db.delete(
          _db.classifications,
        )..where((c) => c.resultId.isIn(results))).go();
        await (_db.delete(
          _db.submissionFlags,
        )..where((f) => f.resultId.isIn(results))).go();
        await (_db.delete(
          _db.testResults,
        )..where((r) => r.sessionId.equals(id))).go();
        await (_db.delete(
          _db.attachments,
        )..where((a) => a.ownerId.equals(id))).go();
        await (_db.delete(
          _db.testSessions,
        )..where((t) => t.id.equals(id))).go();
      case 'alert':
        await (_db.delete(
          _db.alertEvents,
        )..where((e) => e.alertId.equals(id))).go();
        await (_db.delete(_db.alerts)..where((a) => a.id.equals(id))).go();
      case 'water_source':
        await (_db.delete(
          _db.sanitaryInspections,
        )..where((i) => i.sourceId.equals(id))).go();
        await (_db.delete(
          _db.attachments,
        )..where((a) => a.ownerId.equals(id))).go();
        await (_db.delete(
          _db.waterSources,
        )..where((w) => w.id.equals(id))).go();
    }
    await (_db.update(
      _db.outbox,
    )..where((o) => o.entityId.isIn(gone) & o.status.equals('pending'))).write(
      const OutboxCompanion(
        status: Value('rejected'),
        lastError: Value('archived'),
      ),
    );
  }

  /// Entities this client stores; others are skipped (a newer server may
  /// send more than this app version knows).
  static Set<String> get entities => {..._appliers.keys, 'archive_mark'};

  /// Applies one row. Returns false for an entity this version ignores.
  Future<bool> apply(String entity, Map<String, Object?> data) async {
    if (entity == 'archive_mark') {
      await _archiveMark(data);
      return true;
    }
    final apply = _appliers[entity];
    if (apply == null) return false;
    await apply(_db, {
      for (final e in data.entries)
        e.key: switch (e.value) {
          final Map<Object?, Object?> m => jsonEncode(m),
          final List<Object?> l => jsonEncode(l),
          final v => v,
        },
    });
    return true;
  }
}
