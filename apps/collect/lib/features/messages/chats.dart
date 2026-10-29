import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../research/research.dart';
import '../sync/collect_sync.dart';

/// Chats between people (ADR-032), spoken for the tester on this phone, on
/// the side shown now. Online only.
class CollectChats implements ChatBackend {
  CollectChats(this._dio, this._key, this._side);

  final Dio? _dio;
  final String? _key;
  final Side _side;

  PeopleClient get _api {
    final dio = _dio;
    if (dio == null || _key == null) throw const ApiFailure(ApiFailure.offline);
    return WaterCheckApi(dio).people;
  }

  static PersonEntry person(Person p) => PersonEntry(
    kind: p.kind.json ?? 'user',
    id: p.id,
    handle: p.handle,
    fullName: p.fullName,
    public: p.public,
  );

  static ChatSummary summary(ChatOut c) => ChatSummary(
    id: c.id,
    other: person(c.other),
    lastAt: c.lastAt,
    lastBody: c.lastBody,
    unread: c.unread,
  );

  @override
  Future<List<ChatSummary>> chats() async => [
    for (final c in await _api.deviceChats(side: _side, collectorKey: _key!))
      summary(c),
  ];

  @override
  Future<List<PersonEntry>> people(String query) async => [
    for (final p in await _api.devicePeople(
      side: _side,
      collectorKey: _key!,
      q: query.trim(),
    ))
      person(p),
  ];

  @override
  Future<ChatSummary> start(PersonEntry person) async => summary(
    await _api.deviceStartChat(
      collectorKey: _key!,
      body: ChatStart(
        toKind: person.kind == 'collector'
            ? ChatStartToKind.collector
            : ChatStartToKind.user,
        toId: person.id,
        side: _side == Side.research
            ? ChatStartSide.research
            : ChatStartSide.water,
      ),
    ),
  );

  @override
  Future<List<ChatLine>> messages(String chatId) async => [
    for (final m in await _api.deviceChatMessages(
      chatId: chatId,
      collectorKey: _key!,
    ))
      ChatLine(id: m.id, mine: m.mine, body: m.body, at: m.sentAt),
  ];

  @override
  Future<void> send(String chatId, String body) => _api.deviceSendChatMessage(
    chatId: chatId,
    collectorKey: _key!,
    body: ChatMessageIn(body: body),
  );
}

final collectChatsProvider = Provider<ChatBackend>((ref) {
  final side = ref.watch(appModeProvider) == AppMode.research
      ? Side.research
      : Side.water;
  return CollectChats(
    ref.watch(collectApiDioProvider),
    ref.watch(submissionOriginProvider)?.collectorKey,
    side,
  );
});
