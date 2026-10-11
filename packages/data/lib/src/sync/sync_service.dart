import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../repositories/support.dart';
import 'pull_applier.dart';
import 'sync_transport.dart';

/// What one sync run did.
class SyncReport {
  SyncReport({this.skipped = false});

  /// Not run: another sync holds the lock, or the backoff wait is not over.
  final bool skipped;
  var sent = 0;
  var conflicts = 0;
  var rejected = 0;
  var pulled = 0;
  SyncFailure? failure;

  bool get ok => !skipped && failure == null;

  @override
  String toString() =>
      'SyncReport(skipped: $skipped, sent: $sent, conflicts: $conflicts, '
      'rejected: $rejected, pulled: $pulled, failure: $failure)';
}

/// Exponential backoff with jitter, 5 s doubling to 15 min (SPEC §8.1).
Duration backoffDelay(int failures, [Random? random]) {
  if (failures <= 0) return Duration.zero;
  const base = 5, cap = 15 * 60;
  final seconds = min(cap, base * pow(2, min(failures - 1, 20)).toInt());
  // "Equal jitter": between half and all of the step, so many phones coming
  // back online together do not retry in lockstep.
  final r = (random ?? Random()).nextDouble();
  return Duration(milliseconds: (seconds * 1000 * (0.5 + r / 2)).round());
}

/// Push-then-pull sync (SPEC §8). The UI never waits on it: screens read the
/// local database and the outbox; this runs in the background.
class SyncService {
  SyncService(
    this._db,
    this._transport, {
    required this.streams,
    this.clock = systemClock,
    this.ids = const IdGenerator(),
    this.maxRecords = 50,
    this.maxBytes = 256 * 1024,
    this.pageSize = 500,
    this.lockLease = const Duration(minutes: 10),
    Random? random,
  }) : _random = random ?? Random();

  static const pushStream = 'push';
  static const _lockName = 'sync';

  final AppDatabase _db;
  final SyncTransport _transport;

  /// Pull streams, e.g. `reference` and `area:<village id>` (Collect) or
  /// `reference` and `scope` (Console).
  final List<String> streams;
  final Clock clock;
  final IdGenerator ids;
  final int maxRecords;
  final int maxBytes;
  final int pageSize;
  final Duration lockLease;
  final Random _random;

  Future<SyncReport>? _running;

  /// Runs one sync unless one is running or the backoff wait is not over.
  /// [force] ("Sync now") ignores the backoff wait.
  Future<SyncReport> run({bool force = false}) =>
      _running ??= _run(force).whenComplete(() => _running = null);

  Future<SyncReport> _run(bool force) async {
    final state = await _state(pushStream);
    final now = clock();
    final wait = state?.nextAttemptAt;
    if (!force && wait != null && now.isBefore(wait)) {
      return SyncReport(skipped: true);
    }
    final owner = ids.next();
    if (!await _acquire(owner)) return SyncReport(skipped: true);
    final report = SyncReport();
    try {
      await _push(report);
      // Push before pull (SPEC §8.1): never overwrite local edits that the
      // server has not seen yet.
      if (report.failure == null) {
        for (final stream in streams) {
          await _pull(stream, report);
        }
      }
    } on SyncFailure catch (f) {
      report.failure = f;
    } finally {
      await _record(report);
      await _release(owner);
    }
    return report;
  }

  // ------------------------------------------------------------- push
  Future<void> _push(SyncReport report) async {
    while (true) {
      final batch = await _nextBatch();
      if (batch.isEmpty) return;
      final List<ChangeOutcome> outcomes;
      try {
        outcomes = await _transport.push(ids.next(), [
          for (final r in batch)
            OutgoingChange(
              entity: r.entity,
              op: r.op,
              id: r.entityId,
              baseVersion: r.baseVersion,
              data: (jsonDecode(r.payload) as Map).cast<String, Object?>(),
            ),
        ]);
      } on SyncFailure catch (f) {
        await _db.customUpdate(
          'UPDATE outbox SET attempts = attempts + 1 WHERE id IN '
          '(${batch.map((r) => r.id).join(',')})',
          updates: {_db.outbox},
        );
        report.failure = f;
        return;
      }
      if (outcomes.length != batch.length) {
        report.failure = const SyncFailure(
          SyncFailureKind.server,
          'result_count_mismatch',
        );
        return;
      }
      await _db.transaction(() async {
        for (var i = 0; i < batch.length; i++) {
          final o = outcomes[i];
          final (status, note) = switch (o.status) {
            'applied' || 'duplicate' => ('sent', o.reason),
            'conflict' => ('sent', 'conflict: ${o.reason}'),
            _ => ('rejected', o.reason ?? 'rejected'),
          };
          if (o.status == 'conflict') report.conflicts++;
          if (status == 'rejected') {
            report.rejected++;
          } else {
            report.sent++;
          }
          await (_db.update(
            _db.outbox,
          )..where((t) => t.id.equals(batch[i].id))).write(
            OutboxCompanion(
              status: Value(status),
              lastError: Value(note),
              attempts: Value(batch[i].attempts + 1),
            ),
          );
        }
      });
    }
  }

  /// Oldest pending records first, up to [maxRecords] or [maxBytes]
  /// (one record larger than that still goes, alone).
  Future<List<OutboxRow>> _nextBatch() async {
    final rows =
        await (_db.select(_db.outbox)
              ..where((t) => t.status.equals('pending'))
              ..orderBy([(t) => OrderingTerm(expression: t.id)])
              ..limit(maxRecords))
            .get();
    final batch = <OutboxRow>[];
    var bytes = 0;
    for (final r in rows) {
      final size = r.payload.length + 120;
      if (batch.isNotEmpty && bytes + size > maxBytes) break;
      batch.add(r);
      bytes += size;
    }
    return batch;
  }

  // ------------------------------------------------------------- pull
  /// Foreign keys are checked per stream, not per page: a parent edited
  /// after its children were written (an alert escalated after its events,
  /// a source updated after its tests) sits later in the feed than they do,
  /// so on a first sync a child can come pages before its parent. Every
  /// parent has arrived once the stream is complete.
  Future<void> _pull(String stream, SyncReport report) async {
    final applier = PullApplier(_db);
    var cursor = (await _state(stream))?.cursorToken;
    // Only takes effect outside a transaction, hence here.
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      while (true) {
        final page = await _transport.pull(stream, cursor, limit: pageSize);
        await _db.transaction(() async {
          for (final c in page.changes) {
            if (await applier.apply(c.entity, c.data)) report.pulled++;
          }
          await _db
              .into(_db.syncState)
              .insertOnConflictUpdate(
                SyncStateCompanion(
                  stream: Value(stream),
                  cursorToken: Value(page.nextCursor),
                  lastSuccessAt: Value(clock()),
                ),
              );
        });
        cursor = page.nextCursor;
        if (!page.hasMore) return;
      }
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
  }

  // ------------------------------------------------------- bookkeeping
  Future<SyncStateRow?> _state(String stream) => (_db.select(
    _db.syncState,
  )..where((t) => t.stream.equals(stream))).getSingleOrNull();

  Future<void> _record(SyncReport report) async {
    final now = clock();
    final previous = await _state(pushStream);
    final failure = report.failure;
    final failures = failure == null ? 0 : (previous?.failures ?? 0) + 1;
    await _db
        .into(_db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion(
            stream: const Value(pushStream),
            lastAttemptAt: Value(now),
            lastSuccessAt: Value(
              failure == null ? now : previous?.lastSuccessAt,
            ),
            failures: Value(failures),
            nextAttemptAt: Value(
              failure == null ? null : now.add(backoffDelay(failures, _random)),
            ),
            lastError: Value(failure?.code),
          ),
        );
  }

  /// Takes the lease unless another live run holds it (SPEC §8.6).
  Future<bool> _acquire(String owner) => _db.transaction(() async {
    final now = clock();
    final held = await (_db.select(
      _db.syncLocks,
    )..where((t) => t.name.equals(_lockName))).getSingleOrNull();
    if (held != null && held.expiresAt.isAfter(now)) return false;
    await _db
        .into(_db.syncLocks)
        .insertOnConflictUpdate(
          SyncLocksCompanion.insert(
            name: _lockName,
            owner: owner,
            expiresAt: now.add(lockLease),
          ),
        );
    return true;
  });

  Future<void> _release(String owner) async {
    await (_db.delete(
      _db.syncLocks,
    )..where((t) => t.name.equals(_lockName) & t.owner.equals(owner))).go();
  }

  /// Clears the backoff wait (connectivity came back, SPEC §8.1).
  Future<void> resetBackoff() =>
      (_db.update(
        _db.syncState,
      )..where((t) => t.stream.equals(pushStream))).write(
        const SyncStateCompanion(
          nextAttemptAt: Value(null),
          failures: Value(0),
        ),
      );
}
