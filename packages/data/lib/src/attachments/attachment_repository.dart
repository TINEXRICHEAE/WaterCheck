import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../repositories/support.dart';
import 'photo_files.dart';

/// What a photo is attached to (F-TST-6, F-SRC-1).
enum PhotoOwner {
  source('water_source'),
  test('test_session');

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
  });

  final String id;
  final String path;
  final int bytes;

  /// `pending` (waiting to upload), `uploaded` or `rejected`.
  final String status;
}

abstract interface class AttachmentRepository {
  /// Stores an already compressed JPEG and queues its metadata (outbox)
  /// and its bytes (upload queue) together.
  Future<String> addPhoto({
    required PhotoOwner owner,
    required String ownerId,
    required Uint8List jpeg,
    required SubmissionOrigin origin,
  });

  Stream<List<LocalPhoto>> watchPhotos(PhotoOwner owner, String ownerId);

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
  }) async {
    final id = ids.next();
    final path = await _files.save(id, jpeg);
    try {
      await _db.transaction(() async {
        final row = await _db
            .into(_db.attachments)
            .insertReturning(
              AttachmentsCompanion.insert(
                id: id,
                ownerType: owner.wire,
                ownerId: ownerId,
                sha256: sha256.convert(jpeg).toString(),
                bytes: jpeg.length,
                mime: 'image/jpeg',
              ),
            );
        await _db
            .into(_db.attachmentQueue)
            .insert(
              AttachmentQueueCompanion.insert(
                attachmentId: id,
                localPath: path,
              ),
            );
        await enqueueOutbox(
          _db,
          entity: 'attachment',
          entityId: id,
          op: OutboxOp.insert,
          payload: row.toJson(serializer: syncSerializer),
          at: clock(),
        );
      });
    } catch (_) {
      await _files.delete(path);
      rethrow;
    }
    return id;
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
          ),
      ],
    );
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
