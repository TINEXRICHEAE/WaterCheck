import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../app/console_sync.dart';
import 'map_tiles_io.dart' if (dart.library.js_interop) 'map_tiles_web.dart';

/// The map background (plan P9 "Map update", ADR-014): labelled map images
/// of all of Uganda from the self-hosted tile server, at any zoom. Windows
/// and Android also keep an offline pack of their area, used first.
class MapTiles {
  const MapTiles({
    this.provider,
    this.urlTemplate,
    this.minZoom = 6,
    this.maxZoom = 18,
    this.bounds,
  });

  /// No background (offline before the first download, or not built yet):
  /// the dots still show on a plain background.
  static const none = MapTiles();

  final TileProvider? provider;
  final String? urlTemplate;
  final int minZoom;
  final int maxZoom;
  final LatLngBounds? bounds;

  bool get available => provider != null || urlTemplate != null;
}

/// `bounds` metadata is `west,south,east,north`.
LatLngBounds? parseBounds(String? text) {
  final v = text?.split(',').map(double.tryParse).toList();
  if (v == null || v.length != 4 || v.contains(null)) return null;
  return LatLngBounds(LatLng(v[1]!, v[0]!), LatLng(v[3]!, v[2]!));
}

/// The tile server sits next to the API: `…/api` → `…/tiles`.
String tilesBaseUrl() {
  final api = defaultApiUrl();
  return '${api.endsWith('/api') ? api.substring(0, api.length - 4) : api}/tiles';
}

/// Network template for the labelled style, or null when the tile server
/// cannot be reached.
Future<String?> networkTemplate(Dio dio) async {
  try {
    final base = tilesBaseUrl();
    final styles = (await dio.get<List<dynamic>>('$base/styles.json')).data!;
    final id = (styles.first as Map)['id'];
    return '$base/styles/$id/256/{z}/{x}/{y}.png';
  } catch (_) {
    return null;
  }
}

/// Any failure leaves the dots on a plain background.
final mapTilesProvider = FutureProvider<MapTiles>((ref) async {
  try {
    return await loadMapTiles(ref.watch(consoleDioProvider));
  } catch (_) {
    return MapTiles.none;
  }
});
