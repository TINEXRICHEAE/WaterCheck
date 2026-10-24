@TestOn('vm')
library;

import 'package:data/data.dart';
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
}
