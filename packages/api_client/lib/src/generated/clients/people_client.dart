// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/chat_message_in.dart';
import '../models/chat_message_out.dart';
import '../models/chat_out.dart';
import '../models/chat_start.dart';
import '../models/collector_identity.dart';
import '../models/collector_identity_in.dart';
import '../models/handle_check.dart';
import '../models/identity.dart';
import '../models/identity_in.dart';
import '../models/person.dart';
import '../models/side.dart';

part 'people_client.g.dart';

@RestApi()
abstract class PeopleClient {
  factory PeopleClient(Dio dio, {String? baseUrl}) = _PeopleClient;

  /// My Identity
  @GET('/v1/me/identity')
  Future<Identity> myIdentity();

  /// Set My Identity
  @PUT('/v1/me/identity')
  Future<Identity> setMyIdentity({@Body() required IdentityIn body});

  /// Check Handle.
  ///
  /// Whether a username can be had, as it is typed.
  @GET('/v1/people/handle-check')
  Future<HandleCheck> checkHandle({@Query('handle') required String handle});

  /// Collector Identity
  @GET('/v1/device/collectors/{collector_key}/identity')
  Future<CollectorIdentity> collectorIdentity({
    @Path('collector_key') required String collectorKey,
  });

  /// Set Collector Identity
  @PUT('/v1/device/collectors/{collector_key}/identity')
  Future<CollectorIdentity> setCollectorIdentity({
    @Path('collector_key') required String collectorKey,
    @Body() required CollectorIdentityIn body,
  });

  /// People.
  ///
  /// People on this side to write to: anonymous ones by username, public.
  /// ones (and those this account may see) with their names too.
  @GET('/v1/people')
  Future<List<Person>> people({
    @Query('side') Side? side,
    @Query('q') String? q = '',
    @Query('limit') int? limit = 100,
  });

  /// Device People
  @GET('/v1/device/people')
  Future<List<Person>> devicePeople({
    @Query('side') required Side side,
    @Query('collector_key') required String collectorKey,
    @Query('q') String? q = '',
    @Query('limit') int? limit = 100,
  });

  /// Chats
  @GET('/v1/chats')
  Future<List<ChatOut>> chats({@Query('side') Side? side});

  /// Start Chat
  @POST('/v1/chats')
  Future<ChatOut> startChat({@Body() required ChatStart body});

  /// Chat Messages
  @GET('/v1/chats/{chat_id}/messages')
  Future<List<ChatMessageOut>> chatMessages({
    @Path('chat_id') required String chatId,
  });

  /// Send Chat Message
  @POST('/v1/chats/{chat_id}/messages')
  Future<ChatMessageOut> sendChatMessage({
    @Path('chat_id') required String chatId,
    @Body() required ChatMessageIn body,
  });

  /// Device Chats
  @GET('/v1/device/chats')
  Future<List<ChatOut>> deviceChats({
    @Query('side') required Side side,
    @Query('collector_key') required String collectorKey,
  });

  /// Device Start Chat
  @POST('/v1/device/chats')
  Future<ChatOut> deviceStartChat({
    @Query('collector_key') required String collectorKey,
    @Body() required ChatStart body,
  });

  /// Device Chat Messages
  @GET('/v1/device/chats/{chat_id}/messages')
  Future<List<ChatMessageOut>> deviceChatMessages({
    @Path('chat_id') required String chatId,
    @Query('collector_key') required String collectorKey,
  });

  /// Device Send Chat Message
  @POST('/v1/device/chats/{chat_id}/messages')
  Future<ChatMessageOut> deviceSendChatMessage({
    @Path('chat_id') required String chatId,
    @Query('collector_key') required String collectorKey,
    @Body() required ChatMessageIn body,
  });
}
