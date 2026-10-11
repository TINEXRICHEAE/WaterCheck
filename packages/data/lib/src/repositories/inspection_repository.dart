import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

typedef InspectionSummary = ({
  String id,
  DateTime inspectedAt,
  Map<String, String> answers,
});

/// Sanitary inspections of a source (F-SRC-3). Answers are keyed by the
/// checklist item code from `lists.json`; inspections are insert-only.
abstract interface class InspectionRepository {
  Future<String> save(
    String sourceId,
    Map<String, String> answers,
    SubmissionOrigin origin,
  );
  Stream<InspectionSummary?> watchLatest(String sourceId);
}

class DriftInspectionRepository implements InspectionRepository {
  DriftInspectionRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  @override
  Future<String> save(
    String sourceId,
    Map<String, String> answers,
    SubmissionOrigin origin,
  ) => _db.transaction(() async {
    final now = clock();
    final row = await _db
        .into(_db.sanitaryInspections)
        .insertReturning(
          SanitaryInspectionsCompanion.insert(
            id: ids.next(),
            sourceId: sourceId,
            answers: jsonEncode(answers),
            inspectedAtDevice: now,
            installationId: Value(origin.installationId),
            collectorKey: Value(origin.collectorKey),
            collectorSnapshot: Value(origin.snapshotJson),
          ),
        );
    await enqueueOutbox(
      _db,
      entity: 'sanitary_inspection',
      entityId: row.id,
      op: OutboxOp.insert,
      payload: row.toJson(serializer: syncSerializer),
      at: now,
    );
    return row.id;
  });

  @override
  Stream<InspectionSummary?> watchLatest(String sourceId) =>
      (_db.select(_db.sanitaryInspections)
            ..where((i) => i.sourceId.equals(sourceId))
            ..orderBy([(i) => OrderingTerm.desc(i.inspectedAtDevice)])
            ..limit(1))
          .watchSingleOrNull()
          .map(
            (r) => r == null
                ? null
                : (
                    id: r.id,
                    inspectedAt: r.inspectedAtDevice,
                    answers: (jsonDecode(r.answers) as Map)
                        .cast<String, String>(),
                  ),
          );
}
