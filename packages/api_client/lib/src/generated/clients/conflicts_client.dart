// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/conflict_out.dart';
import '../models/resolve_in.dart';

part 'conflicts_client.g.dart';

@RestApi()
abstract class ConflictsClient {
  factory ConflictsClient(Dio dio, {String? baseUrl}) = _ConflictsClient;

  /// Open Conflicts
  @GET('/v1/conflicts')
  Future<List<ConflictOut>> openConflicts({
    @Query('source_id') String? sourceId,
  });

  /// Resolve
  @POST('/v1/conflicts/{conflict_id}/resolve')
  Future<ConflictOut> resolve({
    @Path('conflict_id') required String conflictId,
    @Body() required ResolveIn body,
  });
}
