import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';

/// Time source; injected so tests can control it.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now().toUtc();

/// Client-generated, time-sortable IDs (SPEC §5.2: UUIDv7).
class IdGenerator {
  const IdGenerator();
  static const _uuid = Uuid();
  String next() => _uuid.v7();
}

/// Shared with the server (`app/services/alerts.py`).
const alertNamespace = '4a1d8c2e-7b3f-5e60-9d21-8c4b0f6e2a17';

/// The one ID an alert for this result and rule can have: the phone and
/// the server both raise it, and get the same alert (errata G7, ADR-013).
String alertIdFor(String resultId, String triggerRule) =>
    const Uuid().v5(alertNamespace, '$resultId/$triggerRule');

/// Who made a change: a Collect installation plus the collector snapshot,
/// or a Console user (SPEC §5.2).
class SubmissionOrigin {
  const SubmissionOrigin.collect({
    required String this.installationId,
    required CollectorSnapshot this.collector,
  }) : userId = null;

  const SubmissionOrigin.console({required String this.userId})
    : installationId = null,
      collector = null;

  final String? installationId;
  final CollectorSnapshot? collector;
  final String? userId;

  String? get collectorKey => collector?.collectorKey;
  String? get snapshotJson =>
      collector == null ? null : jsonEncode(collector!.toJson());
}

/// Drift JSON with ISO-8601 dates, used for outbox payloads.
const syncSerializer = ValueSerializer.defaults(
  serializeDateTimeValuesAsString: true,
);

/// Outbox operations (SPEC §8.2).
enum OutboxOp { insert, update }

/// Adds an outbox row. Call only inside the transaction that writes the
/// record itself, so the two can never get out of step (P2 gate).
Future<void> enqueueOutbox(
  AppDatabase db, {
  required String entity,
  required String entityId,
  required OutboxOp op,
  required Map<String, Object?> payload,
  required DateTime at,
  int? baseVersion,
}) async {
  await db
      .into(db.outbox)
      .insert(
        OutboxCompanion.insert(
          entity: entity,
          entityId: entityId,
          op: op.name,
          payload: jsonEncode(payload),
          baseVersion: Value(baseVersion),
          createdAt: at,
        ),
      );
}
