import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/ui_kit_localizations.dart';
import 'conversation_view.dart';
import 'identity_section.dart';
import 'search_field.dart';

/// Someone to write to (ADR-032): an account or a tester, by username, with
/// the real name only where it may be seen.
class PersonEntry {
  const PersonEntry({
    required this.kind,
    required this.id,
    required this.handle,
    this.fullName,
    this.public = false,
  });

  /// 'user' (a Console account) or 'collector' (a tester on Collect).
  final String kind;
  final String id;
  final String handle;
  final String? fullName;
  final bool public;

  String get label => personLabel(handle, fullName);
}

class ChatSummary {
  const ChatSummary({
    required this.id,
    required this.other,
    required this.lastAt,
    this.lastBody,
    this.unread = 0,
  });

  final String id;
  final PersonEntry other;
  final DateTime lastAt;
  final String? lastBody;
  final int unread;
}

class ChatLine {
  const ChatLine({
    required this.id,
    required this.mine,
    required this.body,
    required this.at,
  });

  final String id;
  final bool mine;
  final String body;
  final DateTime at;
}

/// What a chat needs from the app: the Console speaks for its account,
/// Collect for the tester on the phone. Online only.
abstract interface class ChatBackend {
  Future<List<ChatSummary>> chats();
  Future<List<PersonEntry>> people(String query);
  Future<ChatSummary> start(PersonEntry person);
  Future<List<ChatLine>> messages(String chatId);
  Future<void> send(String chatId, String body);
}

/// Direct chats, then the people on this side to write to, searchable
/// (2026-10-28). Shown under a messages page's own threads.
class PeopleChatsSection extends StatefulWidget {
  const PeopleChatsSection({
    super.key,
    required this.backend,
    required this.historyKey,
  });

  final ChatBackend backend;

  /// Where this list's recent searches are kept.
  final String historyKey;

  @override
  State<PeopleChatsSection> createState() => _PeopleChatsSectionState();
}

class _PeopleChatsSectionState extends State<PeopleChatsSection> {
  List<ChatSummary>? _chats;
  List<PersonEntry>? _people;
  Object? _error;
  var _query = '';
  Timer? _wait;
  Timer? _again;

  @override
  void initState() {
    super.initState();
    _load();
    // New messages arrive without a sync: look again while open.
    _again = Timer.periodic(const Duration(seconds: 20), (_) => _loadChats());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The page's own search box, when there is one.
    final outer = SearchQuery.maybeOf(context);
    if (outer != null && outer != _query) _search(outer);
  }

  @override
  void dispose() {
    _wait?.cancel();
    _again?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.wait([_loadChats(), _loadPeople()]);
  }

  Future<void> _loadChats() async {
    try {
      final c = await widget.backend.chats();
      if (mounted) setState(() => _chats = c);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _loadPeople() async {
    final q = _query;
    try {
      final p = await widget.backend.people(q);
      if (mounted && q == _query) setState(() => _people = p);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _search(String q) {
    _query = q;
    if (mounted) setState(() {});
    _wait?.cancel();
    _wait = Timer(const Duration(milliseconds: 300), _loadPeople);
  }

  Future<void> _open(ChatSummary chat) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(backend: widget.backend, chat: chat),
      ),
    );
    await _loadChats();
  }

  Future<void> _write(PersonEntry p) async {
    final chat = await widget.backend.start(p);
    if (mounted) await _open(chat);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM, HH:mm');
    final chats = _chats;
    final people = _people;
    final q = _query.trim().toLowerCase();
    bool matches(PersonEntry p) =>
        q.isEmpty ||
        p.handle.toLowerCase().contains(q) ||
        (p.fullName ?? '').toLowerCase().contains(q);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (SearchQuery.maybeOf(context) == null) ...[
          SearchField(
            value: _query,
            label: l10n.chatsSearch,
            history: widget.historyKey,
            onChanged: _search,
          ),
          const SizedBox(height: 12),
        ],
        Text(l10n.chatsTitle, style: text.titleMedium),
        if (_error != null && chats == null)
          ListTile(
            leading: const Icon(Icons.cloud_off_outlined),
            title: Text(l10n.chatsOffline),
            trailing: IconButton(
              tooltip: l10n.retry,
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() => _error = null);
                _load();
              },
            ),
          )
        else if (chats == null)
          const LinearProgressIndicator()
        else if (chats.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.chatsNone),
          ),
        for (final c in chats ?? const <ChatSummary>[])
          if (matches(c.other))
            Card(
              child: ListTile(
                leading: Badge(
                  isLabelVisible: c.unread > 0,
                  label: Text('${c.unread}'),
                  child: _Avatar(c.other),
                ),
                title: Text(c.other.label),
                subtitle: Text(
                  [?c.lastBody, when.format(c.lastAt.toLocal())].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(c),
              ),
            ),
        const SizedBox(height: 16),
        Text(l10n.chatsPeople, style: text.titleMedium),
        Text(l10n.chatsPeopleHint, style: text.bodySmall),
        if (people == null && _error == null) const LinearProgressIndicator(),
        if (people != null && people.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l10n.chatsNobody),
          ),
        for (final p in people ?? const <PersonEntry>[])
          ListTile(
            leading: _Avatar(p),
            title: Text(p.label),
            subtitle: Text(
              p.public ? l10n.identityPublic : l10n.identityAnonymous,
            ),
            trailing: IconButton(
              tooltip: l10n.chatsWrite,
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => _write(p),
            ),
            onTap: () => _write(p),
          ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.person);

  final PersonEntry person;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    child: Icon(
      person.kind == 'collector' ? Icons.person_outline : Icons.badge_outlined,
    ),
  );
}

/// One chat: the messages, refreshed while open, and a box to write.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.backend, required this.chat});

  final ChatBackend backend;
  final ChatSummary chat;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatLine>? _lines;
  Timer? _again;

  @override
  void initState() {
    super.initState();
    _load();
    _again = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _again?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final l = await widget.backend.messages(widget.chat.id);
      if (mounted) setState(() => _lines = l);
    } on Object {
      // Offline: keep what is shown; the next look tries again.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final lines = _lines;
    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.other.label)),
      body: lines == null
          ? const Center(child: CircularProgressIndicator())
          : ConversationView(
              emptyText: l10n.chatsStart,
              messages: [
                for (final m in lines)
                  ConversationMessage(
                    id: m.id,
                    body: m.body,
                    at: m.at,
                    mine: m.mine,
                    authorName: m.mine ? null : widget.chat.other.handle,
                  ),
              ],
              onSend: (body) async {
                try {
                  await widget.backend.send(widget.chat.id, body);
                } on Object {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.chatsOffline)));
                  }
                  rethrow;
                }
                await _load();
              },
            ),
    );
  }
}

/// A person's card: their username (real name where it may be seen) and a
/// way to write to them. Opened from credits such as "Published by".
Future<void> showPersonCard(
  BuildContext context, {
  required PersonEntry person,
  required ChatBackend backend,
}) async {
  final l10n = UiKitLocalizations.of(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _Avatar(person),
              title: Text(person.label),
              subtitle: Text(
                person.public ? l10n.identityPublic : l10n.identityAnonymous,
              ),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(l10n.chatsWrite),
              onPressed: () async {
                final nav = Navigator.of(context);
                Navigator.pop(sheet);
                try {
                  final chat = await backend.start(person);
                  await nav.push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatPage(backend: backend, chat: chat),
                    ),
                  );
                } on Object {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.chatsOffline)));
                  }
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
