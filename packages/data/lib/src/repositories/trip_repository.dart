import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

/// A trip followed live, with its totals (ADR-029).
typedef TripSummary = ({
  String id,
  String toName,
  double toLat,
  double toLon,
  String mode,
  DateTime startedAt,
  DateTime? endedAt,
  bool arrived,
  int points,
});

/// Trips followed live to a source or place (ADR-029), kept on this device
/// only: never synced, deleted by their owner or with their profile.
class TripRepository {
  TripRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  Future<String> start({
    required String toName,
    required double toLat,
    required double toLon,
    required String mode,
    String? collectorKey,
  }) async {
    final id = ids.next();
    await _db
        .into(_db.trips)
        .insert(
          TripsCompanion.insert(
            id: id,
            collectorKey: Value(collectorKey),
            toName: toName,
            toLat: toLat,
            toLon: toLon,
            mode: mode,
            startedAt: clock(),
          ),
        );
    return id;
  }

  Future<void> addFix(String tripId, GeoFix f) => _db
      .into(_db.tripPoints)
      .insert(
        TripPointsCompanion.insert(
          tripId: tripId,
          at: f.at,
          lat: f.lat,
          lon: f.lon,
          accuracyM: Value(f.accuracyM),
          altitudeM: Value(f.altitudeM),
          speedMps: Value(f.speedMps),
          headingDeg: Value(f.headingDeg),
        ),
      );

  Future<void> end(String tripId, {required bool arrived}) =>
      (_db.update(_db.trips)..where((t) => t.id.equals(tripId))).write(
        TripsCompanion(endedAt: Value(clock()), arrived: Value(arrived)),
      );

  /// This tester's trips, newest first.
  Stream<List<TripSummary>> watch(String? collectorKey) {
    final count = _db.tripPoints.id.count();
    final q =
        _db.select(_db.trips).join([
            leftOuterJoin(
              _db.tripPoints,
              _db.tripPoints.tripId.equalsExp(_db.trips.id),
            ),
          ])
          ..addColumns([count])
          ..groupBy([_db.trips.id])
          ..orderBy([OrderingTerm.desc(_db.trips.startedAt)]);
    if (collectorKey != null) {
      q.where(_db.trips.collectorKey.equals(collectorKey));
    }
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          () {
            final t = r.readTable(_db.trips);
            return (
              id: t.id,
              toName: t.toName,
              toLat: t.toLat,
              toLon: t.toLon,
              mode: t.mode,
              startedAt: t.startedAt,
              endedAt: t.endedAt,
              arrived: t.arrived,
              points: r.read(count) ?? 0,
            );
          }(),
      ],
    );
  }

  Future<List<GeoFix>> fixes(String tripId) async => [
    for (final p
        in await (_db.select(_db.tripPoints)
              ..where((p) => p.tripId.equals(tripId))
              ..orderBy([(p) => OrderingTerm.asc(p.id)]))
            .get())
      GeoFix(
        lat: p.lat,
        lon: p.lon,
        at: p.at,
        accuracyM: p.accuracyM,
        altitudeM: p.altitudeM,
        speedMps: p.speedMps,
        headingDeg: p.headingDeg,
      ),
  ];

  Future<void> delete(String tripId) => _db.transaction(() async {
    await (_db.delete(
      _db.tripPoints,
    )..where((p) => p.tripId.equals(tripId))).go();
    await (_db.delete(_db.trips)..where((t) => t.id.equals(tripId))).go();
  });

  /// Every trip of a tester whose profile leaves this device.
  Future<void> deleteFor(String collectorKey) => _db.transaction(() async {
    final ids =
        await (_db.selectOnly(_db.trips)
              ..addColumns([_db.trips.id])
              ..where(_db.trips.collectorKey.equals(collectorKey)))
            .map((r) => r.read(_db.trips.id)!)
            .get();
    await (_db.delete(_db.tripPoints)..where((p) => p.tripId.isIn(ids))).go();
    await (_db.delete(_db.trips)..where((t) => t.id.isIn(ids))).go();
  });
}
