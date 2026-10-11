// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/activation_code_out.dart';
import '../models/chain_out.dart';
import '../models/credentials_out.dart';
import '../models/installation_out.dart';
import '../models/new_user_in.dart';
import '../models/user_changes_in.dart';
import '../models/user_out.dart';

part 'admin_client.g.dart';

@RestApi()
abstract class AdminClient {
  factory AdminClient(Dio dio, {String? baseUrl}) = _AdminClient;

  /// Activation Codes.
  ///
  /// Recent codes; the codes themselves were shown once and are not stored.
  @GET('/v1/admin/activation-codes')
  Future<List<ActivationCodeOut>> activationCodes();

  /// Users
  @GET('/v1/admin/users')
  Future<List<UserOut>> users();

  /// New User
  @POST('/v1/admin/users')
  Future<CredentialsOut> newUser({@Body() required NewUserIn body});

  /// Change User
  @PATCH('/v1/admin/users/{user_id}')
  Future<UserOut> changeUser({
    @Path('user_id') required String userId,
    @Body() required UserChangesIn body,
  });

  /// Reset Password
  @POST('/v1/admin/users/{user_id}/reset-password')
  Future<CredentialsOut> resetPassword({
    @Path('user_id') required String userId,
  });

  /// Installations
  @GET('/v1/admin/installations')
  Future<List<InstallationOut>> installations();

  /// Chain
  @GET('/v1/admin/areas/{area_id}/chain')
  Future<ChainOut> chain({@Path('area_id') required String areaId});
}
