@TestOn('vm')
library;

import 'dart:convert';

import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  late AppDatabase db;
  late MessageRepository repo;

  setUp(() {
    db = memoryDb();
    repo = MessageRepository(db, clock: fixedClock);
  });
  tearDown(() => db.close());

  test(
    'a message is kept, queued for the server, and read by its author',
    () async {
      final id = await repo.send(
        ThreadKind.source,
        'src-1',
        '  The tap is leaking.  ',
        origin: origin,
      );
      final thread = await repo
          .watchThread(ThreadKind.source, 'src-1', origin)
          .first;
      expect(thread.single.body, 'The tap is leaking.');
      expect(thread.single.mine, isTrue);
      expect(thread.single.sent, isFalse);
      expect(thread.single.authorName, 'Example Collector');
      final out = await db.select(db.outbox).getSingle();
      expect(out.entity, 'message');
      expect(out.entityId, id);
      final payload = jsonDecode(out.payload) as Map;
      expect(payload['subject_type'], 'source');
      expect(payload['collector_key'], origin.collectorKey);
      expect(await repo.watchUnread(origin).first, 0);
    },
  );

  test('replies from the server are unread until the thread is opened, and '
      'the server copy never clears "read"', () async {
    final mine = await repo.send(
      ThreadKind.test,
      'ses-1',
      'Faded strip.',
      origin: origin,
    );
    final applier = PullApplier(db);
    // The server's copy of my own message: author and time filled in.
    await applier.apply('message', {
      'id': mine,
      'subject_type': 'test',
      'subject_id': 'ses-1',
      'body': 'Faded strip.',
      'collector_key': origin.collectorKey,
      'author_name': 'Example Collector',
      'created_at_server': '2026-10-10T09:01:00Z',
      'server_seq': 7,
    });
    await applier.apply('message', {
      'id': 'm-2',
      'subject_type': 'test',
      'subject_id': 'ses-1',
      'body': 'Please test again tomorrow.',
      'author_user_id': 'u-1',
      'author_name': 'District Officer',
      'written_at_device': '2026-10-10T10:00:00Z',
      'server_seq': 8,
    });
    final thread = await repo
        .watchThread(ThreadKind.test, 'ses-1', origin)
        .first;
    expect(thread.map((m) => m.body), [
      'Faded strip.',
      'Please test again tomorrow.',
    ]);
    expect(thread.first.sent, isTrue);
    expect(thread.last.fromStaff, isTrue);
    expect(thread.last.mine, isFalse);
    expect(await repo.watchUnread(origin).first, 1);
    final inbox = await repo.watchInbox(origin).first;
    expect(inbox.single.lastBody, 'Please test again tomorrow.');
    expect(inbox.single.lastAuthor, 'District Officer');
    expect(inbox.single.unread, 1);

    await repo.markRead(ThreadKind.test, 'ses-1');
    expect(await repo.watchUnread(origin).first, 0);
    // A later pull of the same row keeps it read.
    await applier.apply('message', {
      'id': 'm-2',
      'subject_type': 'test',
      'subject_id': 'ses-1',
      'body': 'Please test again tomorrow.',
      'author_user_id': 'u-1',
      'author_name': 'District Officer',
      'server_seq': 8,
    });
    expect(await repo.watchUnread(origin).first, 0);
  });

  test('a Console user\'s messages are theirs by account', () async {
    const officer = SubmissionOrigin.console(userId: 'u-1');
    await repo.send(
      ThreadKind.area,
      'area-1',
      'Meeting on Friday.',
      origin: officer,
      authorName: 'District Officer',
    );
    final thread = await repo
        .watchThread(ThreadKind.area, 'area-1', officer)
        .first;
    expect(thread.single.mine, isTrue);
    expect(thread.single.fromStaff, isTrue);
    expect(
      (await repo.watchThread(ThreadKind.area, 'area-1', origin).first)
          .single
          .mine,
      isFalse,
    );
    expect(
      () => repo.send(ThreadKind.area, 'area-1', '   ', origin: officer),
      throwsArgumentError,
    );
  });
}
