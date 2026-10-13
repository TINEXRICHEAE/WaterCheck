import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'support/harness.dart';

const _village = 'ad625def-3111-5ddd-835f-b24118d37f01';
const _profile = 'ba9093d7-4551-54b4-9da1-3c14a7041644';
const _collector = '01a1aaaa-0000-7000-8000-0000000000c1';

String _id(int n) =>
    '01a1aaaa-0000-7000-8000-${n.toRadixString(16).padLeft(12, '0')}';

/// Two sources: one tested yesterday (unsafe, pH 9.4) by a collector, one
/// never tested. Dates follow the clock so the 30-day period holds.
List<IncomingChange> _area() {
  final at = DateTime.now()
      .toUtc()
      .subtract(const Duration(days: 1))
      .toIso8601String();
  IncomingChange source(int n, String code, String name, {double? lat}) =>
      IncomingChange(
        entity: 'water_source',
        op: 'upsert',
        id: _id(n),
        data: {
          'id': _id(n),
          'village_id': _village,
          'code': code,
          'name': name,
          'source_type': 'borehole',
          'functional_status': 'functional',
          'lat': ?lat,
          'lon': ?(lat == null ? null : 33.66),
          'is_active': true,
          'version': 1,
          'created_at_device': at,
          'updated_at_device': at,
        },
      );
  return [
    source(1, 'ABIM-ENT-001', 'Main borehole', lat: 2.71),
    source(2, 'ABIM-ENT-002', 'School spring'),
    IncomingChange(
      entity: 'test_session',
      op: 'upsert',
      id: _id(3),
      data: {
        'id': _id(3),
        'source_id': _id(1),
        'reference_standard_id': _profile,
        'calibrated': true,
        'tested_at_device': at,
        'collector_key': _collector,
        'collector_snapshot': {'full_name': 'Example Collector'},
      },
    ),
    IncomingChange(
      entity: 'test_result',
      op: 'upsert',
      id: _id(4),
      data: {
        'id': _id(4),
        'session_id': _id(3),
        'overall': 'unsafe',
        'standard_id': _profile,
        'computed_by': 'device',
        'flags': <Object?>[],
        'created_at_device': at,
      },
    ),
    IncomingChange(
      entity: 'reading',
      op: 'upsert',
      id: _id(5),
      data: {
        'id': _id(5),
        'session_id': _id(3),
        'result_id': _id(4),
        'parameter_code': 'ph',
        'value': '9.4',
        'unit': 'pH',
        'result': 'high',
        'is_derived': false,
      },
    ),
  ];
}

Future<AppDatabase> _open(WidgetTester tester, {Size? size}) async {
  final env = ConsoleTestEnv(cookieMode: true);
  env.api.sessionFor('admin@example.org');
  env.sync.serve['scope'] = _area();
  _env = env;
  return size == null
      ? pumpConsole(tester, env: env)
      : pumpConsole(tester, env: env, size: size);
}

late ConsoleTestEnv _env;

void main() {
  testWidgets('dashboard: KPIs, overdue sources and collector activity', (
    tester,
  ) async {
    final db = await _open(tester);
    expect(find.text('Sources tested'), findsOneWidget);
    expect(find.text('of 2 sources'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('1 unsafe test'), findsOneWidget);
    // Never tested is its own status, not overdue (Sources › Not tested).
    expect(find.text('No source is overdue for testing.'), findsOneWidget);
    expect(find.text('Example Collector'), findsOneWidget);
    expect(
      find.textContaining('Each result is shown under the profile used'),
      findsOneWidget,
    );
    await disposeConsole(tester, db);
  });

  testWidgets('sources: filters, then the detail; a submission is flagged', (
    tester,
  ) async {
    final db = await _open(tester);
    await tester.tap(find.text('Sources').last);
    await settle(tester);
    expect(find.text('2 sources'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Unsafe'));
    await settle(tester);
    expect(find.text('1 source'), findsOneWidget);
    expect(find.text('School spring (ABIM-ENT-002)'), findsNothing);
    await tester.tap(find.text('Main borehole (ABIM-ENT-001)'));
    await settle(tester);
    expect(find.text('Test history'), findsOneWidget);
    expect(find.textContaining('Example Collector ·'), findsOneWidget);
    expect(find.text('No photos.'), findsOneWidget);

    await tester.tap(find.byTooltip('Flag as suspicious'));
    await settle(tester);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Same readings as last week',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Flag'));
    await settle(tester);
    final flag = _env.sync.pushed.singleWhere(
      (c) => c.entity == 'submission_flag',
    );
    expect(flag.data['result_id'], _id(4));
    expect(flag.data['reason'], 'Same readings as last week');
    expect(find.byTooltip('Flagged as suspicious'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('map: coloured dots with names, distance from the device, '
      'the latest issue; a dot opens the source', (tester) async {
    final env = ConsoleTestEnv(cookieMode: true)
      ..location = const LatLng(2.70, 33.65);
    env.api.sessionFor('admin@example.org');
    env.sync.serve['scope'] = _area();
    _env = env;
    final db = await pumpConsole(tester, env: env);
    // The dashboard card points at the latest issue, with its distance.
    expect(find.text('Latest issue'), findsOneWidget);
    expect(find.textContaining('Unsafe result: Main borehole'), findsOneWidget);
    expect(find.textContaining('km away'), findsOneWidget);
    await tester.tap(find.text('Open map'));
    await settle(tester);
    // Sources › Map: the map alone, edge to edge, zoomed on that source.
    expect(find.text('Search by code or name'), findsNothing);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Main borehole · Unsafe'), findsOneWidget);
    expect(find.byTooltip('You are here'), findsOneWidget);
    expect(find.text('1.6 km'), findsOneWidget);
    // Dragging pans the map (it is not inside a scrolling list).
    final dot = find.byTooltip('ABIM-ENT-001 · Unsafe');
    final before = tester.getCenter(dot);
    await tester.drag(find.byType(FlutterMap), const Offset(-120, -80));
    await settle(tester);
    final after = tester.getCenter(dot);
    expect(after.dx, lessThan(before.dx - 60));
    expect(after.dy, lessThan(before.dy - 40));
    await tester.tap(dot);
    await settle(tester);
    expect(find.text('Test history'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('a stakeholder updates a source; the change is sent', (
    tester,
  ) async {
    final db = await _open(tester);
    await tester.tap(find.text('Sources').last);
    await settle(tester);
    await tester.tap(find.text('School spring (ABIM-ENT-002)'));
    await settle(tester);
    await tester.tap(find.text('Update source'));
    await settle(tester);
    await tester.tap(find.text('Functional').last);
    await settle(tester);
    await tester.tap(find.text('Broken').last);
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);
    final change = _env.sync.pushed.singleWhere(
      (c) => c.entity == 'water_source',
    );
    expect(change.data['functional_status'], 'broken');
    expect(find.textContaining('Broken'), findsWidgets);
    await disposeConsole(tester, db);
  });

  testWidgets('collectors: mark a collector known', (tester) async {
    final db = await _open(tester);
    await tester.tap(find.text('Collectors').last);
    await settle(tester);
    await tester.tap(find.byTooltip('Mark collector'));
    await settle(tester);
    await tester.tap(find.text('Mark as known'));
    await settle(tester);
    final mark = _env.sync.pushed.singleWhere(
      (c) => c.entity == 'collector_mark',
    );
    expect(mark.id, _collector);
    expect(mark.data['status'], 'known');
    expect(find.textContaining('Known'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('profile: notification channels are saved', (tester) async {
    final db = await _open(tester);
    await tester.tap(find.byTooltip('Account'));
    await settle(tester);
    await tester.tap(find.text('Profile and settings'));
    await settle(tester);
    expect(find.text('How alerts reach me'), findsOneWidget);

    // Theme and time zone follow the account (2026-10-13).
    await tester.tap(find.text('Dark'));
    await settle(tester);
    expect(_env.api.users['admin@example.org']!.appearance.theme, 'dark');
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    await tester.tap(find.text('East Africa Time, Kampala (UTC+3)'));
    await settle(tester);
    await tester.tap(find.text('UTC').last);
    await settle(tester);
    expect(_env.api.users['admin@example.org']!.appearance.zone, 'UTC');

    final sms = find.widgetWithText(SwitchListTile, 'SMS');
    await tester.scrollUntilVisible(
      sms,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await settle(tester);
    await tester.tap(sms);
    await settle(tester);
    expect(_env.api.users['admin@example.org']!.notify.sms, isFalse);
    expect(
      tester
          .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'SMS'))
          .value,
      isFalse,
    );

    // A page below a section's first page has a way back.
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    expect(find.text('How alerts reach me'), findsNothing);
    expect(find.byType(BackButton), findsNothing);
    await disposeConsole(tester, db);
  });

  testWidgets('connection lost: a banner, and the data stays', (tester) async {
    final db = await _open(tester);
    _env.sync.offline = true;
    await tester.tap(find.text('Sync now'));
    await settle(tester);
    expect(
      find.text('Connection lost. Showing the data from the last sync.'),
      findsOneWidget,
    );
    expect(find.text('of 2 sources'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('200% text: dashboard and sources lay out without overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = await _open(tester, size: const Size(1024, 768));
    expect(tester.takeException(), isNull);
    expect(find.text('Sources tested'), findsOneWidget);
    await tester.tap(find.text('Sources').last);
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('2 sources'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('keyboard: Tab reaches the filters and Enter opens a source', (
    tester,
  ) async {
    final db = await _open(tester);
    await tester.tap(find.text('Sources').last);
    await settle(tester);
    final tile = tester.element(
      find.ancestor(
        of: find.text('Main borehole (ABIM-ENT-001)'),
        matching: find.byType(ListTile),
      ),
    );
    bool inTile(BuildContext? c) {
      if (c == null) return false;
      if (c == tile) return true;
      var hit = false;
      c.visitAncestorElements((e) => !(hit = e == tile));
      return hit;
    }

    var reached = false;
    for (var i = 0; i < 60 && !reached; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      reached = inTile(FocusManager.instance.primaryFocus?.context);
    }
    expect(reached, isTrue, reason: 'Tab never reached the source row');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);
    expect(find.text('Test history'), findsOneWidget);
    await disposeConsole(tester, db);
  });
}
