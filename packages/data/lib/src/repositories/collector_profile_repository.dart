import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

/// Collector profiles kept on this phone (SPEC §2.1). Several may exist on a
/// shared phone; the collector picks "Who is testing?" before a session.
abstract interface class CollectorProfileRepository {
  Stream<List<CollectorSnapshot>> watchActive();

  /// Creates a profile (new `collector_key`) or saves an edit, which keeps
  /// the key and bumps `profile_version`.
  Future<CollectorSnapshot> save(CollectorProfileInput input, {String? key});

  /// Brings back a collector known to the server (a recovery code, ADR-020):
  /// same key, the server's details, at least the server's version.
  Future<CollectorSnapshot> restore(CollectorSnapshot snapshot);
  Future<void> deactivate(String collectorKey);
}

class CollectorProfileInput {
  const CollectorProfileInput({
    required this.fullName,
    required this.phone,
    required this.collectorType,
    required this.village,
    required this.parish,
    required this.subcounty,
    required this.district,
    this.organisation,
  });

  final String fullName;
  final String phone;
  final String collectorType;
  final String village;
  final String parish;
  final String subcounty;
  final String district;
  final String? organisation;
}

class DriftCollectorProfileRepository implements CollectorProfileRepository {
  DriftCollectorProfileRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  static CollectorSnapshot _snapshot(CollectorProfileRow r) =>
      CollectorSnapshot(
        collectorKey: r.collectorKey,
        profileVersion: r.profileVersion,
        fullName: r.fullName,
        phone: r.phone,
        collectorType: r.collectorType,
        village: r.village,
        parish: r.parish,
        subcounty: r.subcounty,
        district: r.district,
        organisation: r.organisation,
      );

  @override
  Stream<List<CollectorSnapshot>> watchActive() =>
      (_db.select(_db.collectorProfiles)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm(expression: t.fullName)]))
          .watch()
          .map((rows) => rows.map(_snapshot).toList());

  @override
  Future<CollectorSnapshot> save(CollectorProfileInput input, {String? key}) =>
      _db.transaction(() async {
        final existing = key == null
            ? null
            : await (_db.select(
                _db.collectorProfiles,
              )..where((t) => t.collectorKey.equals(key))).getSingleOrNull();
        if (key != null && existing == null) {
          throw ArgumentError.value(key, 'key', 'Unknown collector profile');
        }
        final row = CollectorProfilesCompanion.insert(
          collectorKey: key ?? ids.next(),
          profileVersion: (existing?.profileVersion ?? 0) + 1,
          fullName: input.fullName.trim(),
          phone: input.phone.trim(),
          collectorType: input.collectorType,
          village: input.village.trim(),
          parish: input.parish.trim(),
          subcounty: input.subcounty.trim(),
          district: input.district.trim(),
          organisation: Value(input.organisation?.trim()),
          updatedAt: clock(),
        );
        await _db.into(_db.collectorProfiles).insertOnConflictUpdate(row);
        return _snapshot(
          await (_db.select(_db.collectorProfiles)
                ..where((t) => t.collectorKey.equals(row.collectorKey.value)))
              .getSingle(),
        );
      });

  @override
  Future<CollectorSnapshot> restore(CollectorSnapshot snapshot) =>
      _db.transaction(() async {
        final existing =
            await (_db.select(_db.collectorProfiles)
                  ..where((t) => t.collectorKey.equals(snapshot.collectorKey)))
                .getSingleOrNull();
        final version = existing == null
            ? snapshot.profileVersion
            : (existing.profileVersion > snapshot.profileVersion
                  ? existing.profileVersion
                  : snapshot.profileVersion);
        await _db
            .into(_db.collectorProfiles)
            .insertOnConflictUpdate(
              CollectorProfilesCompanion.insert(
                collectorKey: snapshot.collectorKey,
                profileVersion: version,
                fullName: snapshot.fullName,
                phone: snapshot.phone,
                collectorType: snapshot.collectorType,
                village: snapshot.village,
                parish: snapshot.parish,
                subcounty: snapshot.subcounty,
                district: snapshot.district,
                organisation: Value(snapshot.organisation),
                isActive: const Value(true),
                updatedAt: clock(),
              ),
            );
        return _snapshot(
          await (_db.select(_db.collectorProfiles)
                ..where((t) => t.collectorKey.equals(snapshot.collectorKey)))
              .getSingle(),
        );
      });

  @override
  Future<void> deactivate(String collectorKey) =>
      (_db.update(_db.collectorProfiles)
            ..where((t) => t.collectorKey.equals(collectorKey)))
          .write(const CollectorProfilesCompanion(isActive: Value(false)));
}
