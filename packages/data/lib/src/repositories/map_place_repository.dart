import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

/// A name on the map placed in its sub-county (ADR-023), or a place
/// someone added from the map ([addedBy], ADR-028).
typedef MapName = ({
  String id,
  String name,
  String kind,
  double lat,
  double lon,
  String subcountyId,
  String? addedBy,
});

/// Kinds of place a person may add from the map (ADR-028).
const addedPlaceKinds = [
  'village',
  'trading_centre',
  'school',
  'health_centre',
  'market',
  'worship',
  'landmark',
  'other',
];

/// Names on the map for the districts this device holds: suggestions when a
/// place is typed or searched, and a guess of the sub-county at a point
/// when there is no connection.
class MapPlaceRepository {
  MapPlaceRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  static MapName _place(PlaceNameRow r) => (
    id: r.id,
    name: r.name,
    kind: r.kind,
    lat: r.lat,
    lon: r.lon,
    subcountyId: r.subcountyId,
    addedBy: r.addedAt == null ? null : (r.addedByName ?? ''),
  );

  /// Adds a place missing from the map (ADR-028): on this device at once,
  /// in [subcountyId] (the best guess; the server sets the real one from
  /// the boundaries), and queued for everyone.
  Future<MapName> add({
    required String name,
    required String kind,
    required double lat,
    required double lon,
    required String subcountyId,
    required SubmissionOrigin origin,
    String? byName,
  }) => _db.transaction(() async {
    final id = ids.next();
    final clean = name.trim().split(RegExp(r'\s+')).join(' ');
    final row = await _db
        .into(_db.placeNames)
        .insertReturning(
          PlaceNamesCompanion.insert(
            id: id,
            name: clean,
            kind: kind,
            lat: lat,
            lon: lon,
            subcountyId: subcountyId,
            addedByName: Value(origin.collector?.fullName ?? byName),
            addedAt: Value(clock()),
          ),
        );
    await enqueueOutbox(
      _db,
      entity: 'place_name',
      entityId: id,
      op: OutboxOp.insert,
      payload: {
        'name': clean,
        'kind': kind,
        'lat': lat,
        'lon': lon,
        'installation_id': origin.installationId,
        'collector_key': origin.collectorKey,
        'collector_snapshot': origin.snapshotJson,
      },
      at: clock(),
    );
    return _place(row);
  });

  /// An admin's correction, here at once; the server's copy follows.
  Future<void> rename(String id, String name) =>
      (_db.update(_db.placeNames)..where((p) => p.id.equals(id))).write(
        PlaceNamesCompanion(name: Value(name)),
      );

  /// An admin's removal, here at once; other devices drop it with sync.
  Future<void> forget(String id) =>
      (_db.delete(_db.placeNames)..where((p) => p.id.equals(id))).go();

  static double _d2(double lat1, double lon1, double lat2, double lon2) =>
      (lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2);

  Future<List<MapName>> all() async => [
    for (final r in await _db.select(_db.placeNames).get()) _place(r),
  ];

  /// Names containing [text]; those starting with it first, then the
  /// nearest to [nearLat]/[nearLon] when given.
  Future<List<MapName>> search(
    String text, {
    double? nearLat,
    double? nearLon,
    int limit = 20,
  }) async {
    final q = text.trim().toLowerCase();
    if (q.length < 2) return const [];
    final rows =
        await (_db.select(_db.placeNames)..where(
              (p) => p.name.lower().like('%${_escape(q)}%', escapeChar: r'\'),
            ))
            .get();
    final hits = [for (final r in rows) _place(r)];
    hits.sort((a, b) {
      final sa = a.name.toLowerCase().startsWith(q) ? 0 : 1;
      final sb = b.name.toLowerCase().startsWith(q) ? 0 : 1;
      if (sa != sb) return sa - sb;
      if (nearLat != null && nearLon != null) {
        final c = _d2(
          a.lat,
          a.lon,
          nearLat,
          nearLon,
        ).compareTo(_d2(b.lat, b.lon, nearLat, nearLon));
        if (c != 0) return c;
      }
      return a.name.compareTo(b.name);
    });
    return hits.take(limit).toList();
  }

  /// The sub-county of the nearest named place within about 5 km: a guess
  /// for when the server (which knows the boundaries) cannot be asked.
  Future<String?> nearestSubcounty(double lat, double lon) async {
    const box = 0.05;
    final rows =
        await (_db.select(_db.placeNames)..where(
              (p) =>
                  p.lat.isBetweenValues(lat - box, lat + box) &
                  p.lon.isBetweenValues(lon - box, lon + box),
            ))
            .get();
    if (rows.isEmpty) return null;
    rows.sort(
      (a, b) =>
          _d2(a.lat, a.lon, lat, lon).compareTo(_d2(b.lat, b.lon, lat, lon)),
    );
    return rows.first.subcountyId;
  }

  static String _escape(String s) =>
      s.replaceAll(r'\', r'\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
