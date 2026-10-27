import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

/// Collector profiles kept on this phone (SPEC §2.1). Several may exist on a
/// shared phone; the collector picks "Who is testing?" before a session.
/// Each profile belongs to one side (ADR-031): a person on both sides has a
/// linked profile on each.
abstract interface class CollectorProfileRepository {
  /// Active profiles, of one side when [side] is given.
  Stream<List<CollectorSnapshot>> watchActive({AppSide? side});

  /// Creates a profile (new `collector_key`) or saves an edit, which keeps
  /// the key, side and link and bumps `profile_version`.
  Future<CollectorSnapshot> save(CollectorProfileInput input, {String? key});

  /// Brings back a collector known to the server (a recovery code, ADR-020):
  /// same key, the server's details, at least the server's version.
  Future<CollectorSnapshot> restore(CollectorSnapshot snapshot);
  Future<void> deactivate(String collectorKey);

  /// Records that the profile accepted [version] of its side's documents.
  Future<CollectorSnapshot> acceptLegal(String collectorKey, int version);

  /// Links two profiles of the same person on different sides.
  Future<void> link(String a, String b);

  Future<CollectorSnapshot?> byKey(String collectorKey);
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
    this.email,
    this.side = AppSide.water,
    this.legalVersion,
    this.linkedKey,
  });

  final String fullName;
  final String phone;
  final String collectorType;
  final String village;
  final String parish;
  final String subcounty;
  final String district;
  final String? organisation;
  final String? email;

  /// For a new profile; an edit keeps the profile's side.
  final AppSide side;

  /// The side's documents accepted with this save (a new profile).
  final int? legalVersion;

  /// For a new profile made from the person's profile on another side.
  final String? linkedKey;
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
        email: r.email,
        side: AppSide.parse(r.side) ?? AppSide.water,
        legalVersion: r.legalVersion,
        linkedKey: r.linkedKey,
      );

  Future<CollectorProfileRow?> _row(String key) => (_db.select(
    _db.collectorProfiles,
  )..where((t) => t.collectorKey.equals(key))).getSingleOrNull();

  @override
  Future<CollectorSnapshot?> byKey(String collectorKey) async {
    final r = await _row(collectorKey);
    return r == null ? null : _snapshot(r);
  }

  @override
  Stream<List<CollectorSnapshot>> watchActive({AppSide? side}) =>
      (_db.select(_db.collectorProfiles)
            ..where(
              (t) =>
                  t.isActive.equals(true) &
                  (side == null
                      ? const Constant(true)
                      : t.side.equals(side.wire)),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.fullName)]))
          .watch()
          .map((rows) => rows.map(_snapshot).toList());

  @override
  Future<CollectorSnapshot> save(CollectorProfileInput input, {String? key}) =>
      _db.transaction(() async {
        final existing = key == null ? null : await _row(key);
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
          email: Value(
            (input.email?.trim().isEmpty ?? true) ? null : input.email!.trim(),
          ),
          side: Value(existing?.side ?? input.side.wire),
          legalVersion: Value(
            input.legalVersion ?? existing?.legalVersion ?? 0,
          ),
          linkedKey: Value(existing?.linkedKey ?? input.linkedKey),
          updatedAt: clock(),
        );
        await _db.into(_db.collectorProfiles).insertOnConflictUpdate(row);
        if (existing == null && input.linkedKey != null) {
          await _setLink(input.linkedKey!, row.collectorKey.value);
        }
        return _snapshot((await _row(row.collectorKey.value))!);
      });

  @override
  Future<CollectorSnapshot> restore(CollectorSnapshot snapshot) =>
      _db.transaction(() async {
        final existing = await _row(snapshot.collectorKey);
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
                email: Value(snapshot.email),
                side: Value(snapshot.side.wire),
                legalVersion: Value(
                  (existing?.legalVersion ?? 0) > snapshot.legalVersion
                      ? existing!.legalVersion
                      : snapshot.legalVersion,
                ),
                linkedKey: Value(snapshot.linkedKey ?? existing?.linkedKey),
                isActive: const Value(true),
                updatedAt: clock(),
              ),
            );
        return _snapshot((await _row(snapshot.collectorKey))!);
      });

  @override
  Future<void> deactivate(String collectorKey) =>
      (_db.update(_db.collectorProfiles)
            ..where((t) => t.collectorKey.equals(collectorKey)))
          .write(const CollectorProfilesCompanion(isActive: Value(false)));

  /// Accepting the documents is a change of the profile: its version goes
  /// up, so the server learns of it with the next record.
  @override
  Future<CollectorSnapshot> acceptLegal(String collectorKey, int version) =>
      _db.transaction(() async {
        final r = await _row(collectorKey);
        if (r == null) throw ArgumentError.value(collectorKey, 'collectorKey');
        await (_db.update(
          _db.collectorProfiles,
        )..where((t) => t.collectorKey.equals(collectorKey))).write(
          CollectorProfilesCompanion(
            legalVersion: Value(version),
            profileVersion: Value(r.profileVersion + 1),
            updatedAt: Value(clock()),
          ),
        );
        return _snapshot((await _row(collectorKey))!);
      });

  @override
  Future<void> link(String a, String b) =>
      _db.transaction(() => _setLink(a, b));

  Future<void> _setLink(String a, String b) async {
    for (final (key, other) in [(a, b), (b, a)]) {
      final r = await _row(key);
      if (r == null) continue;
      await (_db.update(
        _db.collectorProfiles,
      )..where((t) => t.collectorKey.equals(key))).write(
        CollectorProfilesCompanion(
          linkedKey: Value(other),
          profileVersion: Value(r.profileVersion + 1),
          updatedAt: Value(clock()),
        ),
      );
    }
  }
}
