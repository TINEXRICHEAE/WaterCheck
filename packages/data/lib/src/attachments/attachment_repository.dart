import 'package:crypto/crypto.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../repositories/support.dart';
import 'photo_files.dart';

/// What a photo is attached to (F-TST-6, F-SRC-1).
enum PhotoOwner {
  source('water_source'),
  test('test_session'),

  /// A FieldQuire research record (ADR-030).
  research('research_record');

  const PhotoOwner(this.wire);

  final String wire;
}

/// A photo kept on this device.
class LocalPhoto {
  const LocalPhoto({
    required this.id,
    required this.path,
    required this.bytes,
    required this.status,
    this.collectorKey,
    this.taken,
  });

  final String id;
  final String path;
  final int bytes;

  /// Where and when it was taken (ADR-029), if the device had a fix.
  final GeoFix? taken;

  /// Who added it; only they may remove it (ADR-022).
  final String? collectorKey;

  /// `pending` (waiting to upload), `uploaded` or `rejected`.
  final String status;
}

abstract interface class AttachmentRepository {
  /// Stores an already compressed JPEG and queues its metadata (outbox)
  /// and its bytes (upload queue) together, with where it was [taken].
  Future<String> addPhoto({
    required PhotoOwner owner,
    required String ownerId,
    required Uint8List jpeg,
    required SubmissionOrigin origin,
    GeoFix? taken,
    String? id,
    String? fieldName,
  });

  Stream<List<LocalPhoto>> watchPhotos(PhotoOwner owner, String ownerId);

  /// Removes a photo its author no longer wants (ADR-022). Not yet sent:
  /// it simply goes. Sent: the server keeps it, marked removed, and other
  /// devices drop it. Throws [StateError] for someone else's photo.
  Future<void> removePhoto(String id, SubmissionOrigin origin);

  /// Photos still waiting to upload (sync screen).
  Stream<int> watchWaiting();

  Future<Uint8List?> read(String path);
}

class DriftAttachmentRepository implements AttachmentRepository {
  DriftAttachmentRepository(
    this._db,
    this._files, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final PhotoFiles _files;
  final Clock clock;
  final IdGenerator ids;

  @override
  Future<String> addPhoto({
    required PhotoOwner owner,
    required String ownerId,
    required Uint8List jpeg,
    required SubmissionOrigin origin,
    GeoFix? taken,
    String? id,
    String? fieldName,
  }) async {
    final aid = id ?? ids.next();
    final path = await _files.save(aid, jpeg);
    try {
      await _db.transaction(() async {
        final row = await _db
            .into(_db.attachments)
            .insertReturning(
              AttachmentsCompanion.insert(
                id: aid,
                ownerType: owner.wire,
                ownerId: ownerId,
                sha256: sha256.convert(jpeg).toString(),
                bytes: jpeg.length,
                mime: 'image/jpeg',
                collectorKey: Value(origin.collectorKey),
                fieldName: Value(fieldName),
                takenLat: Value(taken?.lat),
                takenLon: Value(taken?.lon),
                takenAccuracyM: Value(taken?.accuracyM),
                takenAltitudeM: Value(taken?.altitudeM),
                takenSpeedMps: Value(taken?.speedMps),
                takenHeadingDeg: Value(taken?.headingDeg),
                takenAt: Value(taken?.at),
              ),
            );
        await _db
            .into(_db.attachmentQueue)
            .insert(
              AttachmentQueueCompanion.insert(
                attachmentId: aid,
                localPath: path,
              ),
            );
        await enqueueOutbox(
          _db,
          entity: 'attachment',
          entityId: aid,
          op: OutboxOp.insert,
          payload: {
            ...row.toJson(serializer: syncSerializer),
            'installation_id': origin.installationId,
            'collector_key': origin.collectorKey,
            'collector_snapshot': origin.snapshotJson,
          },
          at: clock(),
        );
      });
    } catch (_) {
      await _files.delete(path);
      rethrow;
    }
    return aid;
  }

  @override
  Stream<List<LocalPhoto>> watchPhotos(PhotoOwner owner, String ownerId) {
    final q =
        _db.select(_db.attachments).join([
          innerJoin(
            _db.attachmentQueue,
            _db.attachmentQueue.attachmentId.equalsExp(_db.attachments.id),
          ),
        ])..where(
          _db.attachments.ownerType.equals(owner.wire) &
              _db.attachments.ownerId.equals(ownerId),
        );
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          LocalPhoto(
            id: r.readTable(_db.attachments).id,
            path: r.readTable(_db.attachmentQueue).localPath,
            bytes: r.readTable(_db.attachments).bytes,
            status: r.readTable(_db.attachmentQueue).status,
            collectorKey: r.readTable(_db.attachments).collectorKey,
            taken: takenOf(r.readTable(_db.attachments)),
          ),
      ],
    );
  }

  @override
  Future<void> removePhoto(String id, SubmissionOrigin origin) async {
    final row = await (_db.select(
      _db.attachments,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    if (row.collectorKey != null && row.collectorKey != origin.collectorKey) {
      throw StateError('not_creator');
    }
    final queued = await (_db.select(
      _db.attachmentQueue,
    )..where((q) => q.attachmentId.equals(id))).getSingleOrNull();
    await _db.transaction(() async {
      // Its insert still waiting: nothing to tell the server.
      final unsent =
          await (_db.delete(_db.outbox)..where(
                (o) =>
                    o.entity.equals('attachment') &
                    o.entityId.equals(id) &
                    o.op.equals('insert') &
                    o.status.equals('pending'),
              ))
              .go();
      if (unsent == 0) {
        await enqueueOutbox(
          _db,
          entity: 'attachment',
          entityId: id,
          op: OutboxOp.update,
          payload: {
            'removed': true,
            'installation_id': origin.installationId,
            'collector_key': origin.collectorKey,
            'collector_snapshot': origin.snapshotJson,
          },
          at: clock(),
        );
      }
      await (_db.delete(
        _db.attachmentQueue,
      )..where((q) => q.attachmentId.equals(id))).go();
      await (_db.delete(_db.attachments)..where((a) => a.id.equals(id))).go();
    });
    if (queued != null) await _files.delete(queued.localPath);
  }

  @override
  Stream<int> watchWaiting() {
    final n = _db.attachmentQueue.attachmentId.count();
    return (_db.selectOnly(_db.attachmentQueue)
          ..addColumns([n])
          ..where(_db.attachmentQueue.status.equals('pending')))
        .watchSingle()
        .map((r) => r.read(n) ?? 0);
  }

  @override
  Future<Uint8List?> read(String path) => _files.read(path);
}

/// Where and when a stored picture was taken (ADR-029), if known.
GeoFix? takenOf(AttachmentRow a) =>
    a.takenLat == null || a.takenLon == null || a.takenAt == null
    ? null
    : GeoFix(
        lat: a.takenLat!,
        lon: a.takenLon!,
        at: a.takenAt!,
        accuracyM: a.takenAccuracyM,
        altitudeM: a.takenAltitudeM,
        speedMps: a.takenSpeedMps,
        headingDeg: a.takenHeadingDeg,
      );
