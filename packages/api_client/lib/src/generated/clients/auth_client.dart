// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/appearance_in.dart';
import '../models/change_password_request.dart';
import '../models/join_request.dart';
import '../models/login_request.dart';
import '../models/me_response.dart';
import '../models/password_help_request.dart';
import '../models/preferences_in.dart';
import '../models/refresh_request.dart';
import '../models/sign_up_request.dart';
import '../models/switch_request.dart';
import '../models/token_response.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  /// Login
  @POST('/v1/auth/login')
  Future<TokenResponse> login({
    @Body() required LoginRequest body,
    @Header('X-Token-Transport') String? xTokenTransport,
  });

  /// Register.
  ///
  /// Anyone may make an account on a side; it works at once (ADR-031).
  @POST('/v1/auth/register')
  Future<TokenResponse> register({
    @Body() required SignUpRequest body,
    @Header('X-Token-Transport') String? xTokenTransport,
  });

  /// Join Side.
  ///
  /// Opens this person's account on another side (or signs in to it if it.
  /// exists) and returns its tokens: the app switches to that side.
  @POST('/v1/auth/join')
  Future<TokenResponse> joinSide({
    @Body() required JoinRequest body,
    @Header('X-Token-Transport') String? xTokenTransport,
  });

  /// Switch Side.
  ///
  /// Signs in to this person's linked account on another side.
  @POST('/v1/auth/switch')
  Future<TokenResponse> switchSide({
    @Body() required SwitchRequest body,
    @Header('X-Token-Transport') String? xTokenTransport,
  });

  /// Refresh.
  ///
  /// With a token in the body: from secure storage (Windows, Android).
  /// Without one: the web cookie (a `{}` body counts as none).
  @POST('/v1/auth/refresh')
  Future<TokenResponse> refresh({
    @Header('X-CSRF-Token') String? xCsrfToken,
    @Body() RefreshRequest? body,
  });

  /// Change Password
  @POST('/v1/auth/change-password')
  Future<TokenResponse> changePassword({
    @Body() required ChangePasswordRequest body,
    @Header('X-Token-Transport') String? xTokenTransport,
  });

  /// Logout
  @POST('/v1/auth/logout')
  Future<void> logout({
    @Header('X-CSRF-Token') String? xCsrfToken,
    @Body() RefreshRequest? body,
  });

  /// Password Help.
  ///
  /// "Forgot password": asks the IT admin for a new temporary password.
  /// Answers the same for unknown usernames.
  @POST('/v1/auth/password-help')
  Future<void> passwordHelp({
    @Body() required PasswordHelpRequest body,
  });

  /// Me
  @GET('/v1/me')
  Future<MeResponse> me();

  /// Set Appearance
  @PUT('/v1/me/appearance')
  Future<void> setAppearance({
    @Body() required AppearanceIn body,
  });

  /// Set Preferences
  @PUT('/v1/me/preferences')
  Future<void> setPreferences({
    @Body() required PreferencesIn body,
  });
}
