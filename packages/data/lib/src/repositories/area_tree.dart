import 'reference_data_repository.dart';

/// The area list as a tree: paths, what lies below, where an area is.
class AreaTree {
  AreaTree(List<AdminUnit> units) : byId = {for (final u in units) u.id: u};

  final Map<String, AdminUnit> byId;

  /// From the top (Uganda) down to [id].
  List<AdminUnit> pathTo(String id) {
    final path = <AdminUnit>[];
    for (AdminUnit? u = byId[id]; u != null; u = byId[u.parentId]) {
      path.insert(0, u);
    }
    return path;
  }

  /// Whether [unitId] is [areaId] or lies below it.
  bool under(String unitId, String areaId) {
    for (AdminUnit? u = byId[unitId]; u != null; u = byId[u.parentId]) {
      if (u.id == areaId) return true;
    }
    return false;
  }

  /// The area's centre, or the nearest one above it that has a centre
  /// (parishes and villages often have none).
  ({double lat, double lon})? centre(String id) {
    for (AdminUnit? u = byId[id]; u != null; u = byId[u.parentId]) {
      if (u.lat != null && u.lon != null) return (lat: u.lat!, lon: u.lon!);
    }
    return null;
  }

  /// How close to look at an area of this level.
  static double zoomFor(String level) => switch (level) {
    'country' => 7,
    'region' => 8,
    'district' => 10,
    'subcounty' => 12,
    'parish' => 13,
    _ => 14,
  };
}
