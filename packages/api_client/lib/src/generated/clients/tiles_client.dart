// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/tiles_info.dart';

part 'tiles_client.g.dart';

@RestApi()
abstract class TilesClient {
  factory TilesClient(Dio dio, {String? baseUrl}) = _TilesClient;

  /// Info
  @GET('/v1/tiles/info')
  Future<TilesInfo> info();

  /// Download
  @GET('/v1/tiles/area.mbtiles')
  Future<void> download();

  /// Tile
  @GET('/v1/tiles/{z}/{x}/{y}.png')
  Future<void> tile({
    @Path('z') required int z,
    @Path('x') required int x,
    @Path('y') required int y,
  });
}
