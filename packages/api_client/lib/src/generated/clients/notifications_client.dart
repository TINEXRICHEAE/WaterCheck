// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/inbox.dart';
import '../models/push_token_in.dart';
import '../models/sms_ack.dart';
import '../models/sms_provider_name.dart';

part 'notifications_client.g.dart';

@RestApi()
abstract class NotificationsClient {
  factory NotificationsClient(Dio dio, {String? baseUrl}) =
      _NotificationsClient;

  /// Inbox.
  ///
  /// The signed-in user's in-app notifications, newest first.
  @GET('/v1/notifications')
  Future<Inbox> inbox({@Query('limit') int? limit = 50});

  /// Mark Read
  @POST('/v1/notifications/{notification_id}/read')
  Future<void> markRead({
    @Path('notification_id') required String notificationId,
  });

  /// Mark All Read
  @POST('/v1/notifications/read-all')
  Future<void> markAllRead();

  /// Register Push Token.
  ///
  /// Registers this device for push (FCM; Android and web Console).
  @POST('/v1/push-tokens')
  Future<void> registerPushToken({@Body() required PushTokenIn body});

  /// Remove Push Token
  @DELETE('/v1/push-tokens/{token}')
  Future<void> removePushToken({@Path('token') required String token});

  /// Sms Inbound.
  ///
  /// Webhook for incoming SMS (form-encoded: ``from``, ``text``, ``id``).
  ///
  /// The provider does not sign callbacks, so the URL carries a secret token.
  /// The SMS itself must carry the installation's HMAC code (§8.5).
  @POST('/v1/sms/inbound/{provider}')
  Future<SmsAck> smsInbound({
    @Path('provider') required SmsProviderName provider,
    @Query('token') required String token,
  });
}
