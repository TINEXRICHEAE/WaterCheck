import 'dart:convert';

import 'package:data/data.dart';
import 'package:domain/domain.dart' show GeoFix;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _form = 'f-hq';

/// A published research form, as the `research` stream brings it.
Future<void> _publish(AppDatabase db) async {
  final pull = PullApplier(db);
  await pull.apply('research_project', {
    'id': 'p-ent',
    'code': 'ENT',
    'title': 'Household water treatment, Entebbe',
  });
  await pull.apply('research_form', {
    'id': _form,
    'project_id': 'p-ent',
    'code': 'HQ',
    'title': 'Household Questionnaire',
    'status': 'published',
    'collect_access': 'open',
    'hidden': false,
    'numbering': 'typed',
    'current_version': 1,
  });
  await pull.apply('research_form_version', {
    'form_id': _form,
    'version': 1,
    'definition': {
      'title': 'Household Questionnaire',
      'settings': {'numbering': 'typed', 'number_label': 'Household code'},
      'fields': [
        {
          'name': 'consent',
          'type': 'consent',
          'label': 'Do you agree to take part?',
          'required': true,
        },
        {
          'name': 'B6',
          'type': 'select_one',
          'label': 'How often do you clean the containers?',
          'required': true,
          'choices': [
            {'value': 'daily', 'label': 'Daily'},
            {'value': 'weekly', 'label': 'Weekly'},
          ],
        },
      ],
    },
  });
}

// ADR-030 R1: in Research, a collector fills a form offline; the record
// keeps its number and the point of interview, and waits to be sent.
void main() {
  testWidgets('Research: choose it, fill a form, finish; the record is '
      'queued with its number and point', (tester) async {
    final svc = TestServices();
    svc.live.detailed = GeoFix(
      lat: 2.7019,
      lon: 33.6531,
      at: DateTime.utc(2026, 11, 10, 8),
      accuracyM: 6,
    );
    final db = await pumpCollect(tester, services: svc, prepare: _publish);
    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('Research').first);
    await tapAndSettle(tester, find.text('Forms'));
    expect(find.text('Household Questionnaire'), findsOneWidget);
    await tapAndSettle(tester, find.text('Start'));

    // Finishing without answers points to what is missing.
    await tapAndSettle(tester, find.text('Finish'));
    expect(find.text('Give the research number'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'H-001');
    await settle(tester);
    await tapAndSettle(tester, find.text('Yes'));
    await tapAndSettle(tester, find.text('Weekly'));
    await tapAndSettle(tester, find.text('Finish'));
    expect(find.textContaining('Saved H-001'), findsOneWidget);

    final queued = (await tester.runAsync(() => db.select(db.outbox).get()))!
        .where((o) => o.entity == 'research_record');
    final record = jsonDecode(queued.single.payload) as Map<String, Object?>;
    expect(record['number'], 'H-001');
    expect(record['answers'], {'consent': 'yes', 'B6': 'weekly'});
    expect((record['lat'], record['lon']), (2.7019, 33.6531));
    expect(find.text('H-001'), findsOneWidget, reason: 'under My records');
    await disposeApp(tester, db);
  });
}
