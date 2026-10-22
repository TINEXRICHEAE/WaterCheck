import 'dart:math';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'reference_data_repository.dart';
import 'support.dart';

/// A collector's area by name, as picked or typed (district down to village).
typedef AreaNames = ({
  String district,
  String subcounty,
  String parish,
  String village,
});

/// Places a collector names that are not in the list yet (ADR-019). The
/// official list stops at sub-county; parishes and villages (and a new
/// sub-county, chosen as "Other") are added on the phone at once, marked
/// for the IT admin to review, and sent with the next sync.
class PlaceRepository {
  PlaceRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
    Random? random,
  }) : _random = random ?? Random.secure();

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;
  final Random _random;

  static String _norm(String s) =>
      s.trim().toLowerCase().split(RegExp(r'\s+')).join(' ');

  Future<AdminUnitRow?> _child(String? parentId, String level, String name) {
    final q = _db.select(_db.adminUnits)..where((u) => u.level.equals(level));
    if (parentId != null) q.where((u) => u.parentId.equals(parentId));
    return q.get().then(
      (rows) => rows.where((u) => _norm(u.name) == _norm(name)).firstOrNull,
    );
  }

  /// The village, if every level is already known; nothing is added.
  Future<AdminUnit?> findVillage(AreaNames a) async {
    final district = await _child(null, 'district', a.district);
    final subcounty = await _child(district?.id, 'subcounty', a.subcounty);
    final parish = await _child(subcounty?.id, 'parish', a.parish);
    final village = await _child(parish?.id, 'village', a.village);
    if (district == null || village == null) return null;
    return _toUnit(village);
  }

  /// The village for [a], adding the sub-county, parish and village that
  /// are missing. The district must be in the official list.
  Future<AdminUnit> ensureVillage(AreaNames a, SubmissionOrigin origin) =>
      _db.transaction(() async {
        final district = await _child(null, 'district', a.district);
        if (district == null) {
          throw ArgumentError.value(a.district, 'district', 'Unknown district');
        }
        var parent = district;
        for (final (level, name) in [
          ('subcounty', a.subcounty),
          ('parish', a.parish),
          ('village', a.village),
        ]) {
          parent =
              await _child(parent.id, level, name) ??
              await _add(parent, level, name, origin);
        }
        return _toUnit(parent);
      });

  Future<AdminUnitRow> _add(
    AdminUnitRow parent,
    String level,
    String name,
    SubmissionOrigin origin,
  ) async {
    final clean = name.trim().split(RegExp(r'\s+')).join(' ');
    final slug = clean.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    final base =
        '${parent.code}-${slug.isEmpty ? 'X' : slug.substring(0, min(6, slug.length))}';
    var code = base;
    // Two places may share a name and a short code: keep codes unique.
    while (await (_db.select(
          _db.adminUnits,
        )..where((u) => u.code.equals(code))).getSingleOrNull() !=
        null) {
      code = '$base-${_suffix()}';
    }
    final row = await _db
        .into(_db.adminUnits)
        .insertReturning(
          AdminUnitsCompanion.insert(
            id: ids.next(),
            level: level,
            name: clean,
            code: code,
            parentId: Value(parent.id),
          ),
        );
    await enqueueOutbox(
      _db,
      entity: 'admin_unit',
      entityId: row.id,
      op: OutboxOp.insert,
      payload: {
        'id': row.id,
        'level': level,
        'name': clean,
        'code': code,
        'parent_id': parent.id,
        'installation_id': origin.installationId,
        'collector_key': origin.collectorKey,
        'collector_snapshot': origin.snapshotJson,
      },
      at: clock(),
    );
    return row;
  }

  String _suffix() {
    const alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    return [
      for (var i = 0; i < 4; i++) alphabet[_random.nextInt(alphabet.length)],
    ].join();
  }

  static AdminUnit _toUnit(AdminUnitRow r) => (
    id: r.id,
    code: r.code,
    level: r.level,
    name: r.name,
    parentId: r.parentId,
    lat: r.centerLat,
    lon: r.centerLon,
  );
}
