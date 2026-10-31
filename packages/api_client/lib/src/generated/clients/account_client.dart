// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/activity_out.dart';
import '../models/ended.dart';
import '../models/reset_confirm.dart';
import '../models/reset_request.dart';
import '../models/session_out.dart';

part 'account_client.g.dart';

@RestApi()
abstract class AccountClient {
  factory AccountClient(Dio dio, {String? baseUrl}) = _AccountClient;

  /// My Sessions.
  ///
  /// Where this account is signed in: one row per sign-in, newest use.
  /// first. The one making the request is marked current.
  @GET('/v1/me/sessions')
  Future<List<SessionOut>> mySessions();

  /// End Session.
  ///
  /// Signs one sign-in out (its page asks to sign in again within 15.
  /// minutes, when its access runs out).
  @POST('/v1/me/sessions/{session_id}/sign-out')
  Future<void> endSession({@Path('session_id') required String sessionId});

  /// End Other Sessions.
  ///
  /// Signs out every sign-in but this one.
  @POST('/v1/me/sessions/sign-out-others')
  Future<Ended> endOtherSessions();

  /// My Activity.
  ///
  /// This account's recent sign-ins and security changes, newest first.
  @GET('/v1/me/activity')
  Future<List<ActivityOut>> myActivity();

  /// Request Password Reset.
  ///
  /// Sends a reset code (or shows it to IT admins until email is set up).
  /// Answers the same whether or not the account exists. A second request.
  /// within a minute keeps the same code.
  @POST('/v1/auth/password-reset')
  Future<void> requestPasswordReset({@Body() required ResetRequest body});

  /// Confirm Password Reset.
  ///
  /// Sets a new password with a reset code; every sign-in of the account.
  /// ends, and the person signs in with the new password.
  @POST('/v1/auth/password-reset/confirm')
  Future<void> confirmPasswordReset({@Body() required ResetConfirm body});
}
