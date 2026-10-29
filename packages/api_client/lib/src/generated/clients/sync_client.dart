// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/pull_response.dart';
import '../models/push_request.dart';
import '../models/push_response.dart';

part 'sync_client.g.dart';

@RestApi()
abstract class SyncClient {
  factory SyncClient(Dio dio, {String? baseUrl}) = _SyncClient;

  /// Push.
  ///
  /// Applies a batch; every record gets its own answer. Safe to resend.
  @POST('/v1/sync/push')
  Future<PushResponse> push({
    @Body() required PushRequest body,
  });

  /// Pull Changes
  @GET('/v1/sync/pull')
  Future<PullResponse> pullChanges({
    @Query('stream') required String stream,
    @Query('limit') int? limit = 500,
    @Query('cursor') String? cursor,
  });
}
