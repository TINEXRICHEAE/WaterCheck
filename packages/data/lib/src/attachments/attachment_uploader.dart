import 'dart:math';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../sync/sync_transport.dart';
import 'photo_files.dart';

/// The server's view of one upload (ADR-012).
class UploadProgress {
  const UploadProgress(this.received, this.total, this.status, [this.reason]);

  final int received;
  final int total;

  /// `pending`, `uploaded` or `rejected`.
  final String status;
  final String? reason;
}

/// The server holds a different number of bytes than the phone assumed.
class OffsetMismatch implements Exception {
  const OffsetMismatch(this.received);

  final int received;
}

/// How photos reach `/v1/attachments`. Throws [SyncFailure] (and
/// [OffsetMismatch] from [put]).
abstract interface class AttachmentTransport {
  Future<UploadProgress> state(String id);
  Future<UploadProgress> put(String id, int offset, Uint8List chunk);
  Future<UploadProgress> complete(String id);
}

class ApiAttachmentTransport implements AttachmentTransport {
  ApiAttachmentTransport(this._dio);

  final Dio _dio;

  UploadProgress _parse(Object? data) {
    final m = (data! as Map).cast<String, Object?>();
    return UploadProgress(
      m['received_bytes']! as int,
      m['bytes']! as int,
      m['status']! as String,
      m['reason'] as String?,
    );
  }

  Future<UploadProgress> _call(Future<Response<Object?>> Function() f) async {
    try {
      return _parse((await f()).data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 409 &&
          data is Map &&
          data['detail'] == 'offset_mismatch') {
        throw OffsetMismatch(data['received_bytes'] as int);
      }
      throw SyncFailure.from(e);
    }
  }

  @override
  Future<UploadProgress> state(String id) =>
      _call(() => _dio.get<Object?>('/v1/attachments/$id/upload'));

  @override
  Future<UploadProgress> put(String id, int offset, Uint8List chunk) => _call(
    () => _dio.put<Object?>(
      '/v1/attachments/$id/upload',
      queryParameters: {'offset': offset},
      data: chunk,
      options: Options(
        contentType: 'application/octet-stream',
        headers: {Headers.contentLengthHeader: chunk.length},
      ),
    ),
  );

  @override
  Future<UploadProgress> complete(String id) =>
      _call(() => _dio.post<Object?>('/v1/attachments/$id/complete'));
}

/// What one upload run did.
class UploadReport {
  var uploaded = 0;
  var rejected = 0;

  /// Photos left for later: no metadata on the server yet, or the network
  /// was not allowed (Wi-Fi only).
  var waiting = 0;
  SyncFailure? failure;
}

/// Uploads queued photos after their metadata has synced (SPEC §8.3):
/// resumes from what the server already holds, in [chunkSize] pieces.
class AttachmentUploader {
  AttachmentUploader(
    this._db,
    this._files,
    this._transport, {
    required this.networkAllowed,
    this.chunkSize = 64 * 1024,
  });

  final AppDatabase _db;
  final PhotoFiles _files;
  final AttachmentTransport _transport;

  /// False on mobile data while "Wi-Fi only" is on (the default).
  final Future<bool> Function() networkAllowed;
  final int chunkSize;

  Future<UploadReport> run() async {
    final report = UploadReport();
    final queue = await (_db.select(
      _db.attachmentQueue,
    )..where((t) => t.status.equals('pending'))).get();
    if (queue.isEmpty) return report;
    if (!await networkAllowed()) {
      report.waiting = queue.length;
      return report;
    }
    for (final item in queue) {
      final meta =
          await (_db.select(_db.outbox)..where(
                (o) =>
                    o.entity.equals('attachment') &
                    o.entityId.equals(item.attachmentId),
              ))
              .getSingleOrNull();
      if (meta?.status == 'rejected') {
        await _finish(item, 'rejected', meta?.lastError);
        report.rejected++;
        continue;
      }
      // Metadata first, always (SPEC §8.3).
      if (meta?.status != 'sent') {
        report.waiting++;
        continue;
      }
      try {
        final status = await _upload(item);
        if (status == 'uploaded') report.uploaded++;
        if (status == 'rejected') report.rejected++;
      } on SyncFailure catch (f) {
        report.failure = f;
        report.waiting += 1;
        return report; // network trouble: try again with the next sync
      }
    }
    return report;
  }

  Future<String> _upload(AttachmentQueueRow item) async {
    final bytes = await _files.read(item.localPath);
    if (bytes == null) {
      await _finish(item, 'rejected', 'file_missing');
      return 'rejected';
    }
    var progress = await _transport.state(item.attachmentId);
    var offset = progress.received;
    while (progress.status == 'pending' && offset < bytes.length) {
      final end = min(offset + chunkSize, bytes.length);
      try {
        progress = await _transport.put(
          item.attachmentId,
          offset,
          Uint8List.sublistView(bytes, offset, end),
        );
        offset = progress.received;
      } on OffsetMismatch catch (m) {
        offset = m.received;
      }
      await (_db.update(_db.attachmentQueue)
            ..where((t) => t.attachmentId.equals(item.attachmentId)))
          .write(AttachmentQueueCompanion(bytesSent: Value(offset)));
    }
    if (progress.status == 'pending') {
      progress = await _transport.complete(item.attachmentId);
    }
    if (progress.status != 'pending') {
      await _finish(item, progress.status, progress.reason);
    }
    return progress.status;
  }

  Future<void> _finish(
    AttachmentQueueRow item,
    String status,
    String? reason,
  ) => _db.transaction(() async {
    await (_db.update(_db.attachmentQueue)
          ..where((t) => t.attachmentId.equals(item.attachmentId)))
        .write(AttachmentQueueCompanion(status: Value(status)));
    await (_db.update(_db.attachments)
          ..where((t) => t.id.equals(item.attachmentId)))
        .write(AttachmentsCompanion(uploadStatus: Value(status)));
    // The photo stays on the phone either way: the collector may still need
    // to show it, and a rejected one is evidence of what went wrong.
    if (reason != null) {
      await (_db.update(_db.outbox)..where(
            (o) =>
                o.entity.equals('attachment') &
                o.entityId.equals(item.attachmentId),
          ))
          .write(OutboxCompanion(lastError: Value('upload: $reason')));
    }
  });
}
