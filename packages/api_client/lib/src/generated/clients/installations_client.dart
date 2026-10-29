// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/activate_request.dart';
import '../models/activate_response.dart';
import '../models/installation_me.dart';
import '../models/new_code_request.dart';
import '../models/new_code_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';

part 'installations_client.g.dart';

@RestApi()
abstract class InstallationsClient {
  factory InstallationsClient(Dio dio, {String? baseUrl}) = _InstallationsClient;

  /// Activate
  @POST('/v1/installations/activate')
  Future<ActivateResponse> activate({
    @Body() required ActivateRequest body,
  });

  /// Register.
  ///
  /// A device registers itself, no code needed (ADR-024).
  @POST('/v1/installations/register')
  Future<RegisterResponse> register({
    @Body() required RegisterRequest body,
  });

  /// Installation Me
  @GET('/v1/installations/me')
  Future<InstallationMe> installationMe();

  /// New Activation Code
  @POST('/v1/admin/activation-codes')
  Future<NewCodeResponse> newActivationCode({
    @Body() required NewCodeRequest body,
  });

  /// Revoke Installation
  @POST('/v1/admin/installations/{installation_id}/revoke')
  Future<void> revokeInstallation({
    @Path('installation_id') required String installationId,
  });
}
