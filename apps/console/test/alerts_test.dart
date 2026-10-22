import 'package:api_client/api_client.dart' show NotificationOut;
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _src = '01a1aaaa-0000-7000-8000-000000000001';
const _ses = '01a1aaaa-0000-7000-8000-000000000002';
const _res = '01a1aaaa-0000-7000-8000-000000000003';
const _alert = 'e5a06055-3d8d-58a8-8f9b-de57d18f7b2a';
const _profile = 'ba9093d7-4551-54b4-9da1-3c14a7041644';
const _at = '2026-10-10T08:30:00Z';

List<IncomingChange> _syncedAlert() => [
  const IncomingChange(
    entity: 'water_source',
    op: 'upsert',
    id: _src,
    data: {
      'id': _src,
      'village_id': 'ad625def-3111-5ddd-835f-b24118d37f01',
      'code': 'ABIM-ENT-001',
      'name': 'Main borehole',
      'source_type': 'borehole',
      'functional_status': 'functional',
      'lat': 2.71,
      'lon': 33.66,
      'is_active': true,
      'version': 1,
      'created_at_device': _at,
      'updated_at_device': _at,
    },
  ),
  const IncomingChange(
    entity: 'test_session',
    op: 'upsert',
    id: _ses,
    data: {
      'id': _ses,
      'source_id': _src,
      'reference_standard_id': _profile,
      'calibrated': true,
      'tested_at_device': _at,
      'collector_snapshot': {'full_name': 'Example Collector'},
    },
  ),
  const IncomingChange(
    entity: 'test_result',
    op: 'upsert',
    id: _res,
    data: {
      'id': _res,
      'session_id': _ses,
      'overall': 'unsafe',
      'standard_id': _profile,
      'computed_by': 'device',
      'flags': <Object?>[],
      'created_at_device': _at,
    },
  ),
  const IncomingChange(
    entity: 'reading',
    op: 'upsert',
    id: '01a1aaaa-0000-7000-8000-000000000004',
    data: {
      'id': '01a1aaaa-0000-7000-8000-000000000004',
      'session_id': _ses,
      'result_id': _res,
      'parameter_code': 'ph',
      'value': '9.4',
      'unit': 'pH',
      'result': 'high',
      'is_derived': false,
    },
  ),
  const IncomingChange(
    entity: 'alert',
    op: 'upsert',
    id: _alert,
    data: {
      'id': _alert,
      'source_id': _src,
      'trigger_result_id': _res,
      'trigger_rule': 'unsafe',
      'status': 'open',
      'severity': 'high',
      'opened_at': _at,
      'version': 1,
    },
  ),
];

Future<void> _note(WidgetTester tester, String text) async {
  await tester.enterText(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    ),
    text,
  );
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await settle(tester);
}

void main() {
  _windowsOffline();

  testWidgets('dashboard cards open lists that lead to the item', (
    tester,
  ) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    env.sync.serve['scope'] = _syncedAlert();
    final db = await pumpConsole(tester, env: env);

    await tester.tap(find.text('Open alerts'));
    await settle(tester);
    expect(find.text('Alerts not closed yet. Tap one to open it.'), findsOne);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Unsafe result: Main borehole'),
      ),
    );
    await settle(tester);
    expect(find.text('Acknowledge'), findsOneWidget);

    await tester.tap(find.text('Dashboard').first);
    await settle(tester);
    await tester.tap(find.text('Sources tested'));
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Main borehole (ABIM-ENT-001)'),
      ),
    );
    await settle(tester);
    expect(find.text('Edit history'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await disposeConsole(tester, db);
  });

  testWidgets('acknowledge, act and close an alert; each step is sent', (
    tester,
  ) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    env.sync.serve['scope'] = _syncedAlert();
    final db = await pumpConsole(tester, env: env);
    await tester.tap(find.text('Alerts').first);
    await settle(tester);
    expect(find.text('Unsafe result: Main borehole'), findsOneWidget);
    await tester.tap(find.text('Unsafe result: Main borehole'));
    await settle(tester);
    expect(find.text('PH'), findsOneWidget);
    expect(find.text('9.4 pH'), findsOneWidget);
    // Only the transitions the state machine allows are offered.
    expect(find.text('Close'), findsNothing);

    await tester.tap(find.text('Acknowledge'));
    await settle(tester);
    expect(find.widgetWithText(Chip, 'Acknowledged'), findsOneWidget);
    await tester.tap(find.text('Request lab confirmation'));
    await settle(tester);
    await _note(tester, 'Sample sent to the district lab');
    await tester.tap(find.widgetWithText(FilledButton, 'Action in progress'));
    await settle(tester);
    await tester.tap(find.text('Close'));
    await settle(tester);
    // Closing needs a note.
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(save.onPressed, isNull);
    await _note(tester, 'Borehole chlorinated; retest safe');
    expect(find.widgetWithText(Chip, 'Closed'), findsOneWidget);

    final events = env.sync.pushed
        .where((c) => c.entity == 'alert_event')
        .map((c) => c.data['event_type'])
        .toList();
    expect(events, [
      'acknowledged',
      'lab_requested',
      'action_in_progress',
      'closed',
    ]);
    expect(
      env.sync.pushed.every((c) => c.data['actor_id'] == 'u-admin@example.org'),
      isTrue,
    );
    expect(find.text('Lab confirmation requested'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('the bell shows unread notifications and opens the alert', (
    tester,
  ) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    env.sync.serve['scope'] = _syncedAlert();
    env.notifications.items.add(
      NotificationOut(
        id: 'n-1',
        alertId: _alert,
        kind: 'alert',
        title: 'Unsafe water result: Main borehole (ABIM-ENT-001), Entebbe',
        body: '…',
        createdAt: DateTime.utc(2026, 10, 10, 8, 31),
        readAt: null,
      ),
    );
    final db = await pumpConsole(tester, env: env);
    expect(
      find.descendant(
        of: find.byTooltip('Notifications'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Notifications'));
    await settle(tester);
    await tester.tap(
      find.text('Unsafe water result: Main borehole (ABIM-ENT-001), Entebbe'),
    );
    await settle(tester);
    expect(env.notifications.read, {'n-1'});
    expect(find.text('Acknowledge'), findsOneWidget);
    await disposeConsole(tester, db);
  });
}

void _windowsOffline() {
  testWidgets('Windows offline: dashboard and map from cache; an alert is '
      'acknowledged offline and synced on reconnect', (tester) async {
    final env = ConsoleTestEnv();
    await tester.runAsync(() => env.saveSession('admin@example.org', '2468'));
    env.sync.serve['scope'] = _syncedAlert();
    final db = await pumpConsole(tester, env: env);
    await enterPin(tester, '2468');
    expect(find.text('Open alerts'), findsOneWidget);

    // The connection drops.
    env.api.offline = true;
    env.sync.offline = true;
    await tester.tap(find.text('Sync now'));
    await settle(tester);
    expect(
      find.text('Connection lost. Showing the data from the last sync.'),
      findsOneWidget,
    );
    expect(find.text('of 1 sources'), findsOneWidget);
    await tester.tap(find.text('Sources').last);
    await settle(tester);
    await tester.tap(find.text('Map'));
    await settle(tester);
    expect(find.byTooltip('ABIM-ENT-001 · Unsafe'), findsOneWidget);

    await tester.tap(find.text('Alerts').first);
    await settle(tester);
    await tester.tap(find.text('Unsafe result: Main borehole'));
    await settle(tester);
    await tester.tap(find.text('Acknowledge'));
    await settle(tester);
    expect(find.widgetWithText(Chip, 'Acknowledged'), findsOneWidget);
    expect(env.sync.pushed.where((c) => c.entity == 'alert_event'), isEmpty);

    // Back online: the queued action goes up.
    env.api.offline = false;
    env.sync.offline = false;
    await tester.tap(find.text('Reconnect'));
    await settle(tester);
    final sent = env.sync.pushed.where((c) => c.entity == 'alert_event');
    expect(sent.map((c) => c.data['event_type']), ['acknowledged']);
    expect(
      find.text('Connection lost. Showing the data from the last sync.'),
      findsNothing,
    );
    await disposeConsole(tester, db);
  });
}
