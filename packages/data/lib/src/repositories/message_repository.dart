import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

/// What a thread is about (ADR-022): a test (session id), a source, a
/// collector (collector key), an area, or a research record (ADR-030).
enum ThreadKind {
  test,
  source,
  collector,
  area,
  research('research_record');

  const ThreadKind([this._wire]);

  final String? _wire;

  /// The subject type the server keeps (`research_record` for research).
  String get wire => _wire ?? name;

  /// By its name (in app addresses) or its subject type.
  static ThreadKind? parse(String v) =>
      values.where((k) => k.name == v || k.wire == v).firstOrNull;
}

typedef ThreadMessage = ({
  String id,
  String body,
  String? authorName,
  bool mine,
  bool fromStaff,
  DateTime at,
  bool sent,
});

typedef ThreadSummary = ({
  ThreadKind kind,
  String subjectId,
  String title,
  String lastBody,
  String? lastAuthor,
  DateTime lastAt,
  int unread,
});

/// Conversations in the app (ADR-022): threads on a test, a source, a
/// collector or an area, synced both ways like any record. Messages are
/// insert-only; "read" is kept on this device only.
class MessageRepository {
  MessageRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  bool _mine(MessageRow m, SubmissionOrigin me) => me.userId != null
      ? m.authorUserId == me.userId
      : m.collectorKey != null && m.collectorKey == me.collectorKey;

  DateTime _at(MessageRow m) =>
      m.writtenAtDevice ?? m.createdAtServer ?? DateTime(2000);

  Stream<List<ThreadMessage>> watchThread(
    ThreadKind kind,
    String subjectId,
    SubmissionOrigin me,
  ) =>
      (_db.select(_db.messages)..where(
            (m) =>
                m.subjectType.equals(kind.wire) & m.subjectId.equals(subjectId),
          ))
          .watch()
          .map(
            (rows) =>
                [
                  for (final m in rows)
                    (
                      id: m.id,
                      body: m.body,
                      authorName: m.authorName,
                      mine: _mine(m, me),
                      fromStaff: m.authorUserId != null,
                      at: _at(m),
                      sent: m.serverSeq != null,
                    ),
                ]..sort((a, b) {
                  final byTime = a.at.compareTo(b.at);
                  return byTime != 0 ? byTime : a.id.compareTo(b.id);
                }),
          );

  /// Writes a message and queues it for the server.
  Future<String> send(
    ThreadKind kind,
    String subjectId,
    String body, {
    required SubmissionOrigin origin,
    String? authorName,
  }) {
    final text = body.trim();
    if (text.isEmpty || text.length > 2000) {
      throw ArgumentError.value(body, 'body', 'empty or too long');
    }
    return _db.transaction(() async {
      final now = clock();
      final id = ids.next();
      await _db
          .into(_db.messages)
          .insert(
            MessagesCompanion.insert(
              id: id,
              subjectType: kind.wire,
              subjectId: subjectId,
              body: text,
              authorUserId: Value(origin.userId),
              installationId: Value(origin.installationId),
              collectorKey: Value(origin.collectorKey),
              authorName: Value(authorName ?? origin.collector?.fullName),
              writtenAtDevice: Value(now),
              readAt: Value(now),
            ),
          );
      await enqueueOutbox(
        _db,
        entity: 'message',
        entityId: id,
        op: OutboxOp.insert,
        payload: {
          'subject_type': kind.wire,
          'subject_id': subjectId,
          'body': text,
          'written_at_device': now.toUtc().toIso8601String(),
          'installation_id': origin.installationId,
          'collector_key': origin.collectorKey,
          'collector_snapshot': origin.snapshotJson,
        },
        at: now,
      );
      return id;
    });
  }

  /// Marks a thread read on this device.
  Future<void> markRead(ThreadKind kind, String subjectId) =>
      (_db.update(_db.messages)..where(
            (m) =>
                m.subjectType.equals(kind.wire) &
                m.subjectId.equals(subjectId) &
                m.readAt.isNull(),
          ))
          .write(MessagesCompanion(readAt: Value(clock())));

  /// Messages from others not yet read here.
  Stream<int> watchUnread(SubmissionOrigin me) =>
      watchInbox(me).map((t) => t.fold(0, (n, s) => n + s.unread));

  /// Every thread with a message, newest first.
  Stream<List<ThreadSummary>> watchInbox(SubmissionOrigin me) =>
      _db.select(_db.messages).watch().asyncMap((rows) async {
        final byThread = <(String, String), List<MessageRow>>{};
        for (final m in rows) {
          (byThread[(m.subjectType, m.subjectId)] ??= []).add(m);
        }
        final out = <ThreadSummary>[];
        for (final MapEntry(key: (type, id), value: list) in byThread.entries) {
          final kind = ThreadKind.parse(type);
          if (kind == null) continue;
          list.sort((a, b) => _at(a).compareTo(_at(b)));
          final last = list.last;
          out.add((
            kind: kind,
            subjectId: id,
            title: await subjectTitle(kind, id) ?? id,
            lastBody: last.body,
            lastAuthor: last.authorName,
            lastAt: _at(last),
            unread: list.where((m) => m.readAt == null && !_mine(m, me)).length,
          ));
        }
        return out..sort((a, b) => b.lastAt.compareTo(a.lastAt));
      });

  /// A short name for what a thread is about, from local data.
  Future<String?> subjectTitle(ThreadKind kind, String id) async {
    switch (kind) {
      case ThreadKind.source:
        final s = await (_db.select(
          _db.waterSources,
        )..where((w) => w.id.equals(id))).getSingleOrNull();
        return s == null ? null : (s.name ?? s.code);
      case ThreadKind.test:
        final row = await (_db.select(_db.testSessions).join([
          innerJoin(
            _db.waterSources,
            _db.waterSources.id.equalsExp(_db.testSessions.sourceId),
          ),
        ])..where(_db.testSessions.id.equals(id))).getSingleOrNull();
        if (row == null) return null;
        final s = row.readTable(_db.waterSources);
        final t = row.readTable(_db.testSessions);
        final day = t.testedAtDevice.toIso8601String().substring(0, 10);
        return '${s.name ?? s.code}, $day';
      case ThreadKind.research:
        final r = await (_db.select(
          _db.researchRecords,
        )..where((x) => x.id.equals(id))).getSingleOrNull();
        return r?.number;
      case ThreadKind.area:
        final a = await (_db.select(
          _db.adminUnits,
        )..where((u) => u.id.equals(id))).getSingleOrNull();
        return a?.name;
      case ThreadKind.collector:
        final p = await (_db.select(
          _db.collectorProfiles,
        )..where((c) => c.collectorKey.equals(id))).getSingleOrNull();
        if (p != null) return p.fullName;
        final t =
            await (_db.select(_db.testSessions)
                  ..where((s) => s.collectorKey.equals(id))
                  ..limit(1))
                .getSingleOrNull();
        final snap = t?.collectorSnapshot;
        if (snap == null) return null;
        try {
          final j = jsonDecode(snap);
          return j is Map ? j['full_name'] as String? : null;
        } on FormatException {
          return null;
        }
    }
  }
}
