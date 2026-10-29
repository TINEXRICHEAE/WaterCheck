import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/session.dart';
import '../research/research_mode.dart';

/// Chats between people (ADR-032), spoken for this Console account, on the
/// side shown now.
class ConsoleChats implements ChatBackend {
  ConsoleChats(this._api, this._side);

  final PeopleClient _api;
  final Side _side;

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
    for (final c in await _api.chats(side: _side)) summary(c),
  ];

  @override
  Future<List<PersonEntry>> people(String query) async => [
    for (final p in await _api.people(side: _side, q: query.trim())) person(p),
  ];

  @override
  Future<ChatSummary> start(PersonEntry person) async => summary(
    await _api.startChat(
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
    for (final m in await _api.chatMessages(chatId: chatId))
      ChatLine(id: m.id, mine: m.mine, body: m.body, at: m.sentAt),
  ];

  @override
  Future<void> send(String chatId, String body) => _api.sendChatMessage(
    chatId: chatId,
    body: ChatMessageIn(body: body),
  );
}

/// The chats of the side shown now.
final consoleChatsProvider = Provider<ChatBackend>((ref) {
  ref.watch(sessionProvider.select((s) => s.me?.id));
  final side = ref.watch(activeModeProvider).side == AppSide.research
      ? Side.research
      : Side.water;
  return ConsoleChats(
    WaterCheckApi(ref.watch(consoleDioProvider)).people,
    side,
  );
});

/// Opens a person's card from a credit (a version's publisher, a member).
Future<void> openPerson(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String label,
}) {
  final open = label.indexOf(' (');
  return showPersonCard(
    context,
    person: PersonEntry(
      kind: 'user',
      id: userId,
      handle: open < 0 ? label : label.substring(0, open),
      fullName: open < 0 ? null : label.substring(open + 2, label.length - 1),
    ),
    backend: ref.read(consoleChatsProvider),
  );
}
