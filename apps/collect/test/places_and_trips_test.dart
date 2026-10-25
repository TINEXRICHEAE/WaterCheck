import 'dart:convert';

import 'package:data/data.dart';
import 'package:domain/domain.dart' show GeoFix;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:watercheck_collect/features/map/map_screen.dart';

import 'photos_test.dart' show addSource, cameraPhoto, openSource;
import 'support/harness.dart';

// ADR-028: routes to any place and places added from the map. ADR-029:
// live navigation kept as a trip on the device, and located pictures.
void main() {
  Future<({double lat, double lon})> centreOf(
    AppDatabase db,
    String name,
  ) async {
    final units = await DriftReferenceDataRepository(db).adminUnits();
    final u = units.firstWhere((u) => u.name == name);
    final c = AreaTree(units).centre(u.id)!;
    return (lat: c.lat, lon: c.lon);
  }

  Future<void> chooseOnMap(WidgetTester tester, String text) async {
    await tapAndSettle(tester, find.text('Map'));
    await tester.enterText(find.byType(TextField).first, text);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Budondo').last);
  }

  testWidgets('a chosen area has Go: the trip follows the device, arrives, '
      'and is kept under My trips', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(
      tester,
      services: svc,
      size: const Size(1200, 1000),
    );
    final at = await centreOf(db, 'Budondo');
    await chooseOnMap(tester, 'budond');
    expect(find.text('Go'), findsOneWidget);
    await tapAndSettle(tester, find.text('Go'));
    expect(find.text('To Budondo'), findsOneWidget);
    expect(find.text('Waiting for your position…'), findsOneWidget);

    // About 1 km south, then at the place.
    svc.live.fixes.add(
      GeoFix(
        lat: at.lat - 0.009,
        lon: at.lon,
        at: DateTime.now(),
        speedMps: 5,
        altitudeM: 1150,
      ),
    );
    await settle(tester);
    expect(find.textContaining('18 km/h'), findsOneWidget);
    expect(find.textContaining('1,150 m high'), findsOneWidget);
    expect(find.textContaining('left'), findsOneWidget);
    svc.live.fixes.add(GeoFix(lat: at.lat, lon: at.lon, at: DateTime.now()));
    await settle(tester);
    expect(find.text('You have arrived'), findsOneWidget);
    await tapAndSettle(tester, find.text('Done'));
    expect(find.text('To Budondo'), findsNothing);

    // Database reads outside the test clock (a watch leaves timers).
    final trips = (await tester.runAsync(
      () => TripRepository(db).watch(null).first,
    ))!;
    expect(trips.single.toName, 'Budondo');
    expect(trips.single.arrived, isTrue);
    expect(trips.single.points, 2);

    // My profile › My trips.
    GoRouter.of(tester.element(find.byType(MapScreen))).push('/profile/trips');
    await settle(tester);
    expect(find.text('Budondo'), findsOneWidget);
    await tapAndSettle(tester, find.text('Budondo'));
    expect(find.textContaining('Arrived'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('a long press adds a place: here at once, searchable, and '
      'queued for everyone', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(
      tester,
      services: svc,
      size: const Size(1200, 1000),
    );
    await chooseOnMap(tester, 'budond');
    await tester.longPress(find.byType(FlutterMap));
    await tester.pumpAndSettle();
    expect(find.text('Add a place that is not on the map'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Name'),
      'Kyabirwa Market',
    );
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Village'));
    await tapAndSettle(tester, find.text('Market').last);
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Add'));
    expect(find.text('Kyabirwa Market added'), findsOneWidget);

    final queued = (await tester.runAsync(() => db.select(db.outbox).get()))!
        .where((o) => o.entity == 'place_name');
    final payload = jsonDecode(queued.single.payload) as Map<String, Object?>;
    expect(payload['name'], 'Kyabirwa Market');
    expect(payload['kind'], 'market');
    final found = (await tester.runAsync(
      () => MapPlaceRepository(db).search('kyabirwa m'),
    ))!;
    expect(found.single.addedBy, isNotNull);
    // The pin is the new place, with "Go".
    expect(find.text('Kyabirwa Market'), findsWidgets);
    expect(find.text('Go'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('a picture keeps where and when it was taken, in its record '
      'and in the file', (tester) async {
    final svc = TestServices()..picker.next = cameraPhoto();
    svc.live.detailed = GeoFix(
      lat: 2.7019,
      lon: 33.6531,
      at: DateTime.utc(2026, 10, 25, 9, 15),
      accuracyM: 5,
      altitudeM: 1120,
    );
    final db = await pumpCollect(tester, services: svc, prepare: addSource);
    await openSource(tester);
    await tapAndSettle(tester, find.text('Choose photo'));
    final row = await db.select(db.attachments).getSingle();
    expect((row.takenLat, row.takenAltitudeM), (2.7019, 1120));
    final exif = img.decodeJpg(svc.photos.files.values.single)!.exif;
    expect(exif.gpsIfd['GPSLatitudeRef']!.toString(), 'N');
    expect(exif.gpsIfd['GPSDate']!.toString(), '2026:10:25');
    final sent = (await db.select(db.outbox).get()).firstWhere(
      (o) => o.entity == 'attachment',
    );
    expect(
      (jsonDecode(sent.payload) as Map)['taken_lat'],
      2.7019,
      reason: 'sent with the picture',
    );
    await disposeApp(tester, db);
  });

  testWidgets('the map search reaches places not on this device; the bottom '
      'shows open alerts', (tester) async {
    final svc = TestServices();
    String? sourceId;
    final db = await pumpCollect(
      tester,
      services: svc,
      size: const Size(1200, 1000),
      prepare: (db) async {
        sourceId = await addSource(db);
        await PullApplier(db).apply('alert', {
          'id': 'alert-1',
          'source_id': sourceId,
          'trigger_rule': 'unsafe',
          'status': 'open',
          'severity': 'high',
          'opened_at': '2026-10-25T08:00:00Z',
          'version': 1,
        });
      },
    );
    final units = (await tester.runAsync(
      () => DriftReferenceDataRepository(db).adminUnits(),
    ))!;
    final budondo = units.firstWhere((u) => u.name == 'Budondo');
    final c = AreaTree(units).centre(budondo.id)!;
    svc.server.placeHits.add({
      'id': 'f2d2c4a0-0000-7000-8000-000000000001',
      'name': 'Kalagala Landing',
      'kind': 'locality',
      'source': 'added',
      'lat': c.lat,
      'lon': c.lon,
      'subcounty_id': budondo.id,
      'added_by': 'Another Tester',
    });
    await tapAndSettle(tester, find.text('Map'));
    expect(find.text('Unsafe result: Main borehole'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'kalagala');
    await settle(tester);
    await tapAndSettle(tester, find.text('Kalagala Landing').last);
    // The pin, and under the search: who added it, and Go.
    expect(find.text('Kalagala Landing'), findsWidgets);
    expect(find.textContaining('Added by Another Tester'), findsOneWidget);
    expect(find.text('Go'), findsOneWidget);
    // A notice opens its source on the map.
    await tapAndSettle(tester, find.text('Unsafe result: Main borehole'));
    expect(find.byTooltip('Open'), findsOneWidget);
    await disposeApp(tester, db);
  });
}
