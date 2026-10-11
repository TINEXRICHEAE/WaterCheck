import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';

/// One outbox record on its way to the server (SPEC §8.2).
class OutgoingChange {
  const OutgoingChange({
    required this.entity,
    required this.op,
    required this.id,
    required this.data,
    this.baseVersion,
  });

  final String entity;
  final String op;
  final String id;
  final Map<String, Object?> data;
  final int? baseVersion;
}

/// The server's answer for one record.
class ChangeOutcome {
  const ChangeOutcome(this.status, {this.serverVersion, this.reason});

  /// `applied`, `duplicate`, `conflict` or `rejected`.
  final String status;
  final int? serverVersion;
  final String? reason;
}

class IncomingChange {
  const IncomingChange({
    required this.entity,
    required this.op,
    required this.id,
    required this.data,
  });

  final String entity;

  /// `upsert` or `tombstone` (a deactivated record, kept with its data).
  final String op;
  final String id;
  final Map<String, Object?> data;
}

class PullPage {
  const PullPage({
    required this.changes,
    required this.nextCursor,
    required this.hasMore,
    this.serverTime,
  });

  final List<IncomingChange> changes;
  final String nextCursor;
  final bool hasMore;
  final DateTime? serverTime;
}

/// Why a sync attempt stopped. Only [SyncFailureKind.refused] is final; the
/// others are retried with backoff.
enum SyncFailureKind {
  /// No connection or a timeout.
  offline,

  /// The server failed (5xx) or answered something unexpected.
  server,

  /// The server refused who we are (revoked installation, ended session).
  refused,
}

class SyncFailure implements Exception {
  const SyncFailure(this.kind, this.code);

  final SyncFailureKind kind;

  /// The server's error code (e.g. `installation_revoked`) or `offline`.
  final String code;

  static SyncFailure from(Object error) {
    final f = ApiFailure.from(error);
    if (f.isOffline) return SyncFailure(SyncFailureKind.offline, f.code);
    final status = f.status ?? 0;
    if (status == 401 || status == 403) {
      return SyncFailure(SyncFailureKind.refused, f.code);
    }
    return SyncFailure(SyncFailureKind.server, f.code);
  }

  @override
  String toString() => 'SyncFailure(${kind.name}, $code)';
}

/// How the sync service reaches the server. Throws [SyncFailure].
abstract interface class SyncTransport {
  Future<List<ChangeOutcome>> push(
    String batchId,
    List<OutgoingChange> changes,
  );
  Future<PullPage> pull(String stream, String? cursor, {int limit = 500});
}

/// [SyncTransport] over the generated API client. The [Dio] carries the
/// app's authentication: the installation signer plus gzip (Collect) or a
/// bearer token (Console).
class ApiSyncTransport implements SyncTransport {
  ApiSyncTransport(Dio dio) : _api = WaterCheckApi(dio).sync;

  final SyncClient _api;

  @override
  Future<List<ChangeOutcome>> push(
    String batchId,
    List<OutgoingChange> changes,
  ) async {
    try {
      final r = await _api.push(
        body: PushRequest(
          batchId: batchId,
          changes: [
            for (final c in changes)
              ChangeIn(
                entity: c.entity,
                op: c.op == 'update' ? ChangeInOp.update : ChangeInOp.insert,
                id: c.id,
                baseVersion: c.baseVersion,
                data: c.data,
              ),
          ],
        ),
      );
      return [
        for (final x in r.results)
          ChangeOutcome(
            x.status.json ?? x.status.name,
            serverVersion: x.serverVersion,
            reason: x.reason,
          ),
      ];
    } catch (e) {
      throw SyncFailure.from(e);
    }
  }

  @override
  Future<PullPage> pull(
    String stream,
    String? cursor, {
    int limit = 500,
  }) async {
    try {
      final r = await _api.pullChanges(
        stream: stream,
        cursor: cursor,
        limit: limit,
      );
      return PullPage(
        changes: [
          for (final c in r.changes)
            IncomingChange(
              entity: c.entity,
              op: c.op.json ?? c.op.name,
              id: c.id,
              data: (c.data as Map).cast<String, Object?>(),
            ),
        ],
        nextCursor: r.nextCursor,
        hasMore: r.hasMore,
        serverTime: r.serverTime,
      );
    } catch (e) {
      throw SyncFailure.from(e);
    }
  }
}
