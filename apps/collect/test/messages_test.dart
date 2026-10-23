import 'dart:convert';

import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'photos_test.dart' show addSource, openSource;
import 'support/harness.dart';

void main() {
  testWidgets('a collector writes on a source; a reply shows in Messages', (
    tester,
  ) async {
    late String sourceId;
    final db = await pumpCollect(
      tester,
      size: const Size(420, 1600),
      prepare: (db) async => sourceId = await addSource(db),
    );
    await openSource(tester);
    await tapAndSettle(tester, find.text('Messages about this source'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Write a message'),
      'The handle is broken.',
    );
    await tapAndSettle(tester, find.byTooltip('Send'));
    expect(find.text('The handle is broken.'), findsOneWidget);
    expect(
      find.byTooltip('Waiting to send (no connection yet)'),
      findsOneWidget,
    );
    final queued = (await tester.runAsync(
      () => (db.select(
        db.outbox,
      )..where((o) => o.entity.equals('message'))).getSingle(),
    ))!;
    expect(jsonDecode(queued.payload)['subject_id'], sourceId);

    // A stakeholder answers (as a pull brings it).
    await tester.runAsync(
      () => PullApplier(db).apply('message', {
        'id': 'reply-1',
        'subject_type': 'source',
        'subject_id': sourceId,
        'body': 'A mechanic comes on Monday.',
        'author_user_id': 'u-1',
        'author_name': 'District Officer',
        'written_at_device': DateTime.now().toUtc().toIso8601String(),
        'server_seq': 9,
      }),
    );
    await tester.pageBack();
    await settle(tester);
    expect(find.byTooltip('Messages: 1 new'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('Messages: 1 new'));
    expect(find.textContaining('A mechanic comes on Monday.'), findsOneWidget);
    await tapAndSettle(tester, find.textContaining('Source: Main borehole'));
    expect(find.text('A mechanic comes on Monday.'), findsOneWidget);
    expect(find.text('District Officer'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tester.pageBack();
    await settle(tester);
    expect(find.byTooltip('Messages'), findsOneWidget, reason: 'all read');
    await disposeApp(tester, db);
  });
}
