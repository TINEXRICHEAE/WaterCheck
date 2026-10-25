@TestOn('vm')
library;

import 'dart:convert';

import 'package:data/data.dart';
import 'package:domain/domain.dart' show GeoFix;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  late AppDatabase db;
  late MapPlaceRepository repo;

  Future<void> pulled(
    String id,
    String name,
    double lat,
    double lon,
    String sub,
  ) => PullApplier(db).apply('place_name', {
    'id': id,
    'name': name,
    'kind': 'village',
    'lat': lat,
    'lon': lon,
    'subcounty_id': sub,
    'server_seq': 1,
  });

  setUp(() async {
    db = memoryDb();
    repo = MapPlaceRepository(db);
    // The same name in two sub-counties, and another nearby.
    await pulled('p1', 'Kabojja', 0.2935, 32.5067, 'kyengera');
    await pulled('p2', 'Kabojja', 1.2602, 32.4305, 'wabinyonyi');
    await pulled('p3', 'Nkokonjeru', 0.2990, 32.5010, 'kyengera');
  });
  tearDown(() => db.close());

  test('names starting with the text come first, nearest first', () async {
    final near = await repo.search('kab', nearLat: 1.25, nearLon: 32.43);
    expect(near.map((p) => p.subcountyId), ['wabinyonyi', 'kyengera']);
    final other = await repo.search('kab', nearLat: 0.29, nearLon: 32.5);
    expect(other.first.subcountyId, 'kyengera');
    expect(await repo.search('k'), isEmpty, reason: 'two letters at least');
    expect(await repo.search('100%'), isEmpty, reason: '% is not a wildcard');
  });

  test('the nearest named place gives the sub-county at a point', () async {
    expect(await repo.nearestSubcounty(0.2950, 32.5040), 'kyengera');
    expect(await repo.nearestSubcounty(1.26, 32.43), 'wabinyonyi');
    expect(await repo.nearestSubcounty(3.0, 34.0), isNull, reason: 'too far');
  });

  test('a place added from the map is here at once, queued for everyone, '
      'and leaves when an admin removes it', () async {
    final added = await repo.add(
      name: '  Kabojja   Market ',
      kind: 'market',
      lat: 0.2940,
      lon: 32.5060,
      subcountyId: 'kyengera',
      origin: origin,
    );
    expect(
      (added.name, added.addedBy),
      ('Kabojja Market', 'Example Collector'),
    );
    final found = await repo.search('kabojja m');
    expect(found.single.id, added.id);
    final queued = await db.select(db.outbox).getSingle();
    expect((queued.entity, queued.entityId), ('place_name', added.id));
    final payload = jsonDecode(queued.payload) as Map<String, Object?>;
    expect(payload['kind'], 'market');
    expect(payload['collector_key'], origin.collectorKey);
    // Names from the map have no "added by".
    expect((await repo.search('nkok')).single.addedBy, isNull);

    await PullApplier(db).apply('place_name', {
      'id': added.id,
      'name': 'Kabojja Market',
      'kind': 'market',
      'lat': 0.2940,
      'lon': 32.5060,
      'subcounty_id': 'kyengera',
      'added_by_name': 'Example Collector',
      'added_at': '2026-10-25T08:00:00Z',
      'removed_at': '2026-10-25T09:00:00Z',
      'server_seq': 2,
    });
    expect(await repo.search('kabojja m'), isEmpty);
  });

  test('trips are kept on this device per tester, with their fixes', () async {
    final trips = TripRepository(db);
    final id = await trips.start(
      toName: 'Kabojja',
      toLat: 0.2935,
      toLon: 32.5067,
      mode: 'foot',
      collectorKey: 'c-1',
    );
    for (var i = 0; i < 3; i++) {
      await trips.addFix(
        id,
        GeoFix(
          lat: 0.29 + i / 1000,
          lon: 32.5,
          at: DateTime.utc(2026, 10, 25, 8, i),
          altitudeM: 1150.0 + i,
          speedMps: 1.2,
        ),
      );
    }
    await trips.end(id, arrived: true);
    final listed = await trips.watch('c-1').first;
    expect(listed.single.points, 3);
    expect(listed.single.arrived, isTrue);
    expect(await trips.watch('c-2').first, isEmpty);
    final fixes = await trips.fixes(id);
    expect(fixes.map((f) => f.altitudeM), [1150, 1151, 1152]);
    await trips.deleteFor('c-1');
    expect(await trips.watch(null).first, isEmpty);
    expect(await trips.fixes(id), isEmpty);
  });
}
