// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/admin_unit_out.dart';
import '../models/catalogue.dart';
import '../models/collector_summary.dart';
import '../models/ip_location.dart';
import '../models/place_at.dart';
import '../models/place_hit.dart';
import '../models/place_rename.dart';
import '../models/source_hit.dart';

part 'reference_client.g.dart';

@RestApi()
abstract class ReferenceClient {
  factory ReferenceClient(Dio dio, {String? baseUrl}) = _ReferenceClient;

  /// Catalogue
  @GET('/v1/reference/catalogue')
  Future<Catalogue> catalogue();

  /// Reference Profiles.
  ///
  /// Published profiles as seed-format documents (custom ones come via sync).
  @GET('/v1/reference/profiles')
  Future<dynamic> referenceProfiles();

  /// Tester Profiles
  @GET('/v1/reference/tester-profiles')
  Future<dynamic> testerProfiles();

  /// Response Cards
  @GET('/v1/reference/response-cards')
  Future<dynamic> responseCards();

  /// Config
  @GET('/v1/reference/config/{key}')
  Future<dynamic> config({@Path('key') required String key});

  /// Admin Units
  @GET('/v1/reference/admin-units')
  Future<List<AdminUnitOut>> adminUnits();

  /// Search Sources.
  ///
  /// Sources anywhere, by code, name or village (ADR-019): a phone finds.
  /// sources beyond the districts it holds, then syncs that district.
  @GET('/v1/sources/search')
  Future<List<SourceHit>> searchSources({
    @Query('q') required String q,
    @Query('limit') int? limit = 30,
  });

  /// Search Places.
  ///
  /// Places anywhere in Uganda by name: official areas, places added from.
  /// devices, and the map's villages, trading centres and neighbourhoods.
  /// with the sub-county they lie in. Names starting with the text come.
  /// first, then the nearest to `near_lat`/`near_lon` when given.
  @GET('/v1/places/search')
  Future<List<PlaceHit>> searchPlaces({
    @Query('q') required String q,
    @Query('limit') int? limit = 20,
    @Query('near_lat') num? nearLat,
    @Query('near_lon') num? nearLon,
  });

  /// Locate Place.
  ///
  /// The sub-county (and its district) a point lies in, from the official.
  /// boundaries (ADR-023). 404 outside Uganda or before the shapes load.
  @GET('/v1/places/locate')
  Future<PlaceAt> locatePlace({
    @Query('lat') required num lat,
    @Query('lon') required num lon,
  });

  /// Collectors.
  ///
  /// Collectors seen in the user's area, built from submissions (§2.1):.
  /// the latest self-declared snapshot, counts and last submission.
  @GET('/v1/collectors')
  Future<List<CollectorSummary>> collectors();

  /// Rename Place.
  ///
  /// Renames a place someone added from the map (IT admins).
  @PATCH('/v1/places/{place_id}')
  Future<void> renamePlace({
    @Path('place_id') required String placeId,
    @Body() required PlaceRename body,
  });

  /// Remove Place.
  ///
  /// Removes a place someone added from the map (IT admins); devices drop.
  /// it with their next sync.
  @DELETE('/v1/places/{place_id}')
  Future<void> removePlace({@Path('place_id') required String placeId});

  /// Ip Location.
  ///
  /// Roughly where the caller is, from their public address: for devices.
  /// without GPS only (2026-10-28). 404 when the address is not known.
  @GET('/v1/places/ip-location')
  Future<IpLocation> ipLocation();
}
