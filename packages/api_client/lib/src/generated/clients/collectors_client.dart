// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/recover_in.dart';
import '../models/recovered_collector.dart';
import '../models/recovery_code_out.dart';

part 'collectors_client.g.dart';

@RestApi()
abstract class CollectorsClient {
  factory CollectorsClient(Dio dio, {String? baseUrl}) = _CollectorsClient;

  /// Issue Code.
  ///
  /// A one-time code for this collector, valid 24 hours.
  @POST('/v1/collectors/{collector_key}/recovery-code')
  Future<RecoveryCodeOut> issueCode({
    @Path('collector_key') required String collectorKey,
  });

  /// Recover.
  ///
  /// Redeems a code on an activated phone; each code works once.
  @POST('/v1/collectors/recover')
  Future<RecoveredCollector> recover({@Body() required RecoverIn body});
}
