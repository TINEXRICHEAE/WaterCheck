import 'dart:convert';

import 'package:domain/domain.dart' show GeoFix;
import 'package:drift/drift.dart';

import '../attachments/attachment_repository.dart';
import '../attachments/photo_files.dart';
import '../db/database.dart';
import 'research_repository.dart' show DraftPicture, parseDraftMedia;
import 'support.dart';

/// A water test in progress, for the list of unfinished ones.
typedef WaterDraftItem = ({
  String id,
  String sourceId,
  String sourceCode,
  String? sourceName,
  DateTime updatedAt,
});

/// Water tests in progress (ADR-034): saved as they are filled, and sent to
/// the server, so a closed page or a cleared browser does not lose them.
class WaterDraftRepository {
  WaterDraftRepository(this._db, {this.clock = systemClock});

  final AppDatabase _db;
  final Clock clock;

  static const _entity = 'water_draft';

  Future<WaterDraftRow?> draft(String id) => (_db.select(
    _db.waterDrafts,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Saves the test's state and queues the newest copy.
  Future<void> save({
    required String id,
    required String sourceId,
    required String? collectorKey,
    required Map<String, Object?> state,
  }) => _db.transaction(() async {
    final now = clock();
    final was = await draft(id);
    await _db
        .into(_db.waterDrafts)
        .insertOnConflictUpdate(
          WaterDraftsCompanion.insert(
            id: id,
            sourceId: sourceId,
            collectorKey: Value(collectorKey),
            state: jsonEncode(state),
            media: Value(was?.media ?? '{}'),
            startedAt: was?.startedAt ?? now,
            updatedAt: now,
          ),
        );
    await _queue(id);
  });

  /// Keeps a picture with the draft and queues it; returns its id.
  Future<void> addPicture({
    required String draftId,
    required String pictureId,
    required Uint8List jpeg,
    required PhotoFiles files,
    required AttachmentRepository attachments,
    required SubmissionOrigin origin,
    GeoFix? taken,
  }) async {
    final path = await files.save(pictureId, jpeg);
    await _db.transaction(() async {
      final d = await draft(draftId);
      if (d == null) return;
      final media = (jsonDecode(d.media) as Map).cast<String, Object?>();
      media[pictureId] = {
        'path': path,
        'field': 'test',
        if (taken != null) ...{
          'lat': taken.lat,
          'lon': taken.lon,
          'at': taken.at.toIso8601String(),
          'accuracy_m': taken.accuracyM,
          'altitude_m': taken.altitudeM,
        },
      };
      await (_db.update(_db.waterDrafts)..where((r) => r.id.equals(draftId)))
          .write(WaterDraftsCompanion(media: Value(jsonEncode(media))));
      await _queue(draftId);
    });
    await attachments.addPhoto(
      owner: PhotoOwner.waterDraft,
      ownerId: draftId,
      jpeg: jpeg,
      origin: origin,
      taken: taken,
      id: pictureId,
    );
  }

  /// Takes a picture the tester removed off the draft.
  Future<void> removePicture({
    required String draftId,
    required String pictureId,
    required AttachmentRepository attachments,
    required SubmissionOrigin origin,
  }) async {
    await _db.transaction(() async {
      final d = await draft(draftId);
      if (d == null) return;
      final media = (jsonDecode(d.media) as Map).cast<String, Object?>()
        ..remove(pictureId);
      await (_db.update(_db.waterDrafts)..where((r) => r.id.equals(draftId)))
          .write(WaterDraftsCompanion(media: Value(jsonEncode(media))));
      await _queue(draftId);
    });
    await attachments.removePhoto(pictureId, origin);
  }

  Map<String, DraftPicture> pictures(WaterDraftRow d) =>
      parseDraftMedia(d.media);

  /// The test was submitted as session [draftId]: its pictures now belong
  /// to the session, and the draft ends.
  Future<void> finish(String draftId) async {
    final d = await draft(draftId);
    if (d == null) return;
    final now = clock();
    for (final picture in pictures(d).keys) {
      await movePictureTo(_db, picture, PhotoOwner.test.wire, at: now);
    }
    await _db.transaction(() async {
      await _dropQueued(draftId);
      await (_db.delete(
        _db.waterDrafts,
      )..where((r) => r.id.equals(draftId))).go();
    });
  }

  /// Throws a draft away, here and on the server.
  Future<void> discard(String id, PhotoFiles files) async {
    final d = await draft(id);
    if (d == null) return;
    final kept = pictures(d);
    await _db.transaction(() async {
      await _dropQueued(id);
      if (d.collectorKey != null) {
        await enqueueOutbox(
          _db,
          entity: _entity,
          entityId: id,
          op: OutboxOp.update,
          payload: {'discarded': true, 'collector_key': d.collectorKey},
          at: clock(),
        );
      }
      for (final picture in kept.keys) {
        await forgetPicture(_db, picture);
      }
      await (_db.delete(_db.waterDrafts)..where((r) => r.id.equals(id))).go();
    });
    for (final p in kept.values) {
      await files.delete(p.path);
    }
  }

  /// This collector's unfinished tests of sources on this device.
  Stream<List<WaterDraftItem>> watch(String? collectorKey) {
    final q = _db.select(_db.waterDrafts).join([
      innerJoin(
        _db.waterSources,
        _db.waterSources.id.equalsExp(_db.waterDrafts.sourceId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.waterDrafts.updatedAt)]);
    if (collectorKey != null) {
      q.where(_db.waterDrafts.collectorKey.equals(collectorKey));
    }
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (
            id: r.readTable(_db.waterDrafts).id,
            sourceId: r.readTable(_db.waterDrafts).sourceId,
            sourceCode: r.readTable(_db.waterSources).code,
            sourceName: r.readTable(_db.waterSources).name,
            updatedAt: r.readTable(_db.waterDrafts).updatedAt,
          ),
      ],
    );
  }

  /// One copy waits, always the newest (see `ResearchRepository`).
  Future<void> _queue(String id) async {
    final d = await draft(id);
    if (d == null) return;
    await _dropQueued(id);
    if (d.collectorKey == null) return;
    await enqueueOutbox(
      _db,
      entity: _entity,
      entityId: id,
      op: OutboxOp.insert,
      payload: {
        ...d.toJson(serializer: syncSerializer),
        'state': jsonDecode(d.state),
        'media': jsonDecode(d.media),
      },
      at: clock(),
    );
  }

  Future<void> _dropQueued(String id) => (_db.delete(
    _db.outbox,
  )..where((o) => o.entity.equals(_entity) & o.entityId.equals(id))).go();
}
