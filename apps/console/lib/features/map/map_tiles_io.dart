import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'map_tiles.dart';

/// Windows/Android: the area's offline pack (downloaded once, labelled
/// images to zoom 16) is read first; anything outside it comes from the
/// tile server while online.
Future<MapTiles> loadMapTiles(Dio dio) async {
  final template = await networkTemplate(Dio());
  final dir = Directory(
    '${(await getApplicationSupportDirectory()).path}${Platform.pathSeparator}maps',
  );
  final file = File('${dir.path}${Platform.pathSeparator}area.mbtiles');
  if (!file.existsSync()) {
    try {
      await dir.create(recursive: true);
      final part = File('${file.path}.part');
      await dio.download('/v1/tiles/area.mbtiles', part.path);
      await part.rename(file.path);
    } catch (_) {
      // Offline or no pack yet: network images only (or none).
    }
  }
  if (!file.existsSync()) {
    return template == null ? MapTiles.none : MapTiles(urlTemplate: template);
  }
  final db = sqlite3.open(file.path, mode: OpenMode.readOnly);
  final meta = {
    for (final r in db.select('SELECT name, value FROM metadata'))
      r['name'] as String: r['value'] as String?,
  };
  return MapTiles(
    provider: MbtilesTileProvider(db, fallbackTemplate: template),
    bounds: parseBounds(meta['bounds']),
  );
}

/// Reads raster tiles from an MBTiles database (TMS rows: y is flipped),
/// falling back to the tile server for tiles the pack does not hold.
class MbtilesTileProvider extends TileProvider {
  MbtilesTileProvider(this._db, {this.fallbackTemplate});

  final Database _db;
  final String? fallbackTemplate;
  late final _tile = _db.prepare(
    'SELECT tile_data FROM tiles '
    'WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?',
  );

  /// A 1×1 transparent PNG, for tiles nobody has.
  static final _empty = Uint8List.fromList(const [
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
    0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
  ]);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final c = coordinates;
    final rows = _tile.select([c.z, c.x, (1 << c.z) - 1 - c.y]);
    if (rows.isNotEmpty) {
      return MemoryImage(rows.first['tile_data'] as Uint8List);
    }
    final template = fallbackTemplate;
    if (template == null) return MemoryImage(_empty);
    return NetworkImage(
      template
          .replaceFirst('{z}', '${c.z}')
          .replaceFirst('{x}', '${c.x}')
          .replaceFirst('{y}', '${c.y}'),
    );
  }

  // No dispose override: the TileLayer disposes its provider when the map
  // closes, but this one (and its database) lives as long as the app.
}
