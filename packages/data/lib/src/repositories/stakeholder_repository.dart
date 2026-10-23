import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

/// A picture and what it shows: the source itself, or one of its tests
/// ([ownerId] is then the test session, ADR-022).
typedef PhotoSummary = ({
  String id,
  bool uploaded,
  String ownerId,
  bool ofSource,
});

typedef InspectionListItem = ({
  String id,
  DateTime inspectedAt,
  int risks,
  int answered,
});

/// What Console stakeholders read and decide about sources and collectors
/// (P9): photos, inspections, flagged submissions and collector marks.
/// Flags and marks go to the server through the outbox like any change.
class StakeholderRepository {
  StakeholderRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  /// Photos of the source and of its test sessions.
  Future<List<PhotoSummary>> photos(String sourceId) async {
    final sessions =
        await (_db.selectOnly(_db.testSessions)
              ..addColumns([_db.testSessions.id])
              ..where(_db.testSessions.sourceId.equals(sourceId)))
            .map((r) => r.read(_db.testSessions.id)!)
            .get();
    final rows = await (_db.select(
      _db.attachments,
    )..where((a) => a.ownerId.isIn({sourceId, ...sessions}))).get();
    return [
      for (final a in rows)
        (
          id: a.id,
          uploaded: a.uploadStatus == 'uploaded',
          ownerId: a.ownerId,
          ofSource: a.ownerId == sourceId,
        ),
    ];
  }

  /// Inspections, newest first; a "yes" answer marks a risk.
  Future<List<InspectionListItem>> inspections(String sourceId) async {
    final rows =
        await (_db.select(_db.sanitaryInspections)
              ..where((i) => i.sourceId.equals(sourceId))
              ..orderBy([(i) => OrderingTerm.desc(i.inspectedAtDevice)]))
            .get();
    return [
      for (final r in rows)
        () {
          final answers = (jsonDecode(r.answers) as Map).values;
          return (
            id: r.id,
            inspectedAt: r.inspectedAtDevice,
            risks: answers.where((v) => v == 'yes').length,
            answered: answers.length,
          );
        }(),
    ];
  }

  /// Flags one submission as suspicious; the result stays in the record.
  Future<String> flagSubmission({
    required String resultId,
    required String reason,
    required String userId,
  }) => _db.transaction(() async {
    final now = clock();
    final row = await _db
        .into(_db.submissionFlags)
        .insertReturning(
          SubmissionFlagsCompanion.insert(
            id: ids.next(),
            resultId: resultId,
            reason: reason,
            flaggedBy: Value(userId),
            createdAtDevice: now,
          ),
        );
    await enqueueOutbox(
      _db,
      entity: 'submission_flag',
      entityId: row.id,
      op: OutboxOp.insert,
      payload: row.toJson(serializer: syncSerializer),
      at: now,
    );
    return row.id;
  });

  /// Marks a collector `known` or `flagged`; the latest decision wins.
  Future<void> markCollector({
    required String collectorKey,
    required String status,
    required String userId,
    String? note,
  }) => _db.transaction(() async {
    assert(status == 'known' || status == 'flagged');
    final now = clock();
    final row = await _db
        .into(_db.collectorMarks)
        .insertReturning(
          CollectorMarksCompanion.insert(
            collectorKey: collectorKey,
            status: status,
            note: Value(note),
            markedBy: Value(userId),
            markedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
    await enqueueOutbox(
      _db,
      entity: 'collector_mark',
      entityId: collectorKey,
      op: OutboxOp.update,
      payload: row.toJson(serializer: syncSerializer),
      at: now,
    );
  });
}
