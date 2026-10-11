// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/dashboard_summary.dart';

part 'dashboard_client.g.dart';

@RestApi()
abstract class DashboardClient {
  factory DashboardClient(Dio dio, {String? baseUrl}) = _DashboardClient;

  /// Summary.
  ///
  /// As collected, for the user's areas (or one of them). The web shows.
  /// this at once; the full data syncs behind it.
  @GET('/v1/dashboard/summary')
  Future<DashboardSummary> summary({
    @Query('days') int? days = 30,
    @Query('area_id') String? areaId,
  });
}
