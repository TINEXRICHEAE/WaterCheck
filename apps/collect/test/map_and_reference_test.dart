import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/features/map/map_screen.dart';

import 'support/harness.dart';

// ADR-019 slice B: reference data opens detail pages and the map; the
// sources list searches all of Uganda online.
void main() {
  testWidgets('reference data items open their pages', (tester) async {
    final db = await pumpCollect(tester, size: const Size(420, 1400));
    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('Reference data'));

    await tapAndSettle(tester, find.text('Required: temp, ph, ec, tds'));
    expect(find.text('Testing rules'), findsOneWidget);
    expect(find.textContaining('Within 100 m of the source'), findsOneWidget);
    await tapAndSettle(tester, find.text('pH'));
    expect(find.text('Limit in each limit set'), findsOneWidget);
    expect(find.text('No readings on this phone yet.'), findsOneWidget);
    await tapAndSettle(
      tester,
      find.textContaining('Class II (untreated').first,
    );
    expect(find.text('Calibrate with these limits'), findsOneWidget);
    expect(find.text('Where it is used'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('an area opens the map on that area, with its places', (
    tester,
  ) async {
    final db = await pumpCollect(tester, size: const Size(420, 1400));
    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('Reference data'));
    await tester.enterText(find.byType(TextField).first, 'Jinja');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.widgetWithText(ListTile, 'Jinja').first);
    expect(find.byType(MapScreen), findsOneWidget);
    expect(find.text('Jinja'), findsWidgets);
    // Its place in the list, and the sub-counties within it.
    expect(find.text('Uganda'), findsOneWidget);
    expect(find.text('12 areas within'), findsOneWidget);
    await tapAndSettle(tester, find.text('Budondo'));
    expect(find.textContaining('No source on this phone'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('the map search finds areas, places added from phones and '
      'sources; the path runs down to what was chosen', (tester) async {
    final db = await pumpCollect(tester, size: const Size(1200, 1000));
    await tapAndSettle(tester, find.text('Map'));
    await tester.enterText(find.byType(TextField).first, 'butag');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Butagaya').last);
    expect(find.text('Butagaya (sub-county)'), findsOneWidget);
    expect(find.text('Jinja (district)'), findsOneWidget);
    // No "Uganda (country)" twice: the country is the first chip only.
    expect(find.textContaining('(country)'), findsNothing);
    // The layers menu: names, straight lines, road route, travel mode.
    await tapAndSettle(tester, find.byTooltip('Map layers'));
    expect(find.text('Route by road'), findsOneWidget);
    expect(find.text('Motorbike/car'), findsOneWidget);
    expect(find.text('Walking'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('a search reaches all of Uganda online; a district can be '
      'added to the phone', (tester) async {
    final svc = TestServices();
    svc.server.searchHits.add({
      'id': '01a1bbbb-0000-7000-8000-000000000001',
      'code': 'WC-7Q2K9',
      'name': 'Kitanaba borehole',
      'village_id': '01a1bbbb-0000-7000-8000-000000000002',
      'village': 'Kitanaba',
      'district_id': 'c03ea684-034a-5143-ad94-99304699c68d',
      'district': 'Jinja',
      'lat': 0.42,
      'lon': 33.2,
      'latest': null,
    });
    final db = await pumpCollect(tester, services: svc);
    await tester.enterText(find.byType(TextField).first, 'kitanaba');
    await tester.pump();
    await tapAndSettle(tester, find.text('Search all of Uganda'));
    expect(find.text('Elsewhere in Uganda (online)'), findsOneWidget);
    expect(find.text('Kitanaba borehole'), findsOneWidget);
    await tapAndSettle(tester, find.text('Get this district'));
    final saved = await tester.runAsync(
      () => DriftLocalSettingsRepository(db).read('sync.extra_districts'),
    );
    expect(saved, 'c03ea684-034a-5143-ad94-99304699c68d');
    await disposeApp(tester, db);
  });
}
