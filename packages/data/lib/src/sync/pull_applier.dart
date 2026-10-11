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
    'attachment': (db, j) =>
        _upsert(db, db.attachments, AttachmentRow.fromJson(j, serializer: _s)),
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
  };

  /// Entities this client stores; others are skipped (a newer server may
  /// send more than this app version knows).
  static Set<String> get entities => _appliers.keys.toSet();

  /// Applies one row. Returns false for an entity this version ignores.
  Future<bool> apply(String entity, Map<String, Object?> data) async {
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
