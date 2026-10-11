import 'package:dio/dio.dart';

import 'map_tiles.dart';

/// Web: labelled images straight from the tile server.
Future<MapTiles> loadMapTiles(Dio dio) async {
  final template = await networkTemplate(Dio());
  return template == null ? MapTiles.none : MapTiles(urlTemplate: template);
}
