// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/admin_unit_out.dart';
import '../models/catalogue.dart';
import '../models/collector_summary.dart';
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

  /// Collectors.
  ///
  /// Collectors seen in the user's area, built from submissions (§2.1):.
  /// the latest self-declared snapshot, counts and last submission.
  @GET('/v1/collectors')
  Future<List<CollectorSummary>> collectors();
}
