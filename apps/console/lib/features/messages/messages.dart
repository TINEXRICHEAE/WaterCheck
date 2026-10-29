import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import 'chats.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepository(ref.watch(databaseProvider)),
);

/// The signed-in person as a message author.
final _meProvider = Provider<SubmissionOrigin?>((ref) {
  final me = ref.watch(sessionProvider).me;
  return me == null ? null : SubmissionOrigin.console(userId: me.id);
});

final _threadProvider = StreamProvider.autoDispose
    .family<List<ThreadMessage>, (ThreadKind, String)>((ref, key) {
      final me = ref.watch(_meProvider);
      if (me == null) return Stream.value(const []);
      return ref
          .watch(messageRepositoryProvider)
          .watchThread(key.$1, key.$2, me);
    });

final _inboxProvider = StreamProvider.autoDispose<List<ThreadSummary>>((ref) {
  final me = ref.watch(_meProvider);
  if (me == null) return Stream.value(const []);
  return ref.watch(messageRepositoryProvider).watchInbox(me);
});

final unreadMessagesProvider = StreamProvider<int>((ref) {
  final me = ref.watch(_meProvider);
  if (me == null) return Stream.value(0);
  return ref.watch(messageRepositoryProvider).watchUnread(me);
});

/// The conversation about a test, a source, a collector or an area
/// (ADR-022), with the collectors in Collect. Opening it marks it read; a
/// message goes to the server with a sync started at once.
class ThreadSection extends ConsumerWidget {
  const ThreadSection({super.key, required this.kind, required this.subjectId});

  final ThreadKind kind;
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final messages =
        ref.watch(_threadProvider((kind, subjectId))).value ?? const [];
    if (messages.any((m) => !m.mine)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref.read(messageRepositoryProvider).markRead(kind, subjectId);
        }
      });
    }
    return ConversationView(
      emptyText: l10n.messagesEmpty,
      messages: [
        for (final m in messages)
          ConversationMessage(
            id: m.id,
            body: m.body,
            at: m.at,
            mine: m.mine,
            authorName: m.authorName,
            fromStaff: m.fromStaff,
            sent: m.sent,
          ),
      ],
      onSend: (body) async {
        final me = ref.read(sessionProvider).me;
        if (me == null) return;
        await ref
            .read(messageRepositoryProvider)
            .send(
              kind,
              subjectId,
              body,
              origin: SubmissionOrigin.console(userId: me.id),
              authorName: me.fullName,
            );
        ref.read(dataVersionProvider.notifier).bump();
        await ref.read(consoleSyncProvider.notifier).run(force: true);
      },
    );
  }
}

/// A messages button with the number of unread messages.
class MessagesButton extends ConsumerWidget {
  const MessagesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(unreadMessagesProvider).value ?? 0;
    return IconButton(
      tooltip: unread == 0 ? l10n.messagesTitle : l10n.messagesUnread(unread),
      onPressed: () => context.go('/dashboard/messages'),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.forum_outlined),
      ),
    );
  }
}

IconData _icon(ThreadKind kind) => switch (kind) {
  ThreadKind.test => Icons.science_outlined,
  ThreadKind.source => Icons.water_drop_outlined,
  ThreadKind.collector => Icons.person_outline,
  ThreadKind.area => Icons.place_outlined,
  ThreadKind.research => Icons.assignment_outlined,
};

/// Every conversation in my areas, newest first (ADR-022).
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final threads = ref.watch(_inboxProvider).value;
    if (threads == null) return const PageLoading();
    return SearchBuilder(
      label: l10n.searchMessages,
      history: 'console.messages',
      builder: (context, field, matches) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.messagesTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(l10n.messagesHint),
          const SizedBox(height: 12),
          if (threads.isEmpty) Text(l10n.messagesNone),
          field,
          const SizedBox(height: 8),
          for (final t in threads)
            if (matches([t.title, t.lastAuthor, t.lastBody]))
              Card(
                child: ListTile(
                  leading: Badge(
                    isLabelVisible: t.unread > 0,
                    label: Text('${t.unread}'),
                    child: Icon(_icon(t.kind)),
                  ),
                  title: Text('${l10n.messagesAbout(t.kind.name)}: ${t.title}'),
                  subtitle: Text(
                    '${t.lastAuthor ?? '?'}: ${t.lastBody}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(
                    '/dashboard/messages/${t.kind.name}/${t.subjectId}',
                  ),
                ),
              ),
          // People to write to directly (ADR-032).
          const SizedBox(height: 24),
          PeopleChatsSection(
            backend: ref.watch(consoleChatsProvider),
            historyKey: 'console.chats',
          ),
        ],
      ),
    );
  }
}

final _titleProvider = FutureProvider.autoDispose
    .family<String?, (ThreadKind, String)>(
      (ref, key) =>
          ref.watch(messageRepositoryProvider).subjectTitle(key.$1, key.$2),
    );

/// Where a test's page is: its source and its (first) result.
final _testPageProvider = FutureProvider.autoDispose.family<String?, String>((
  ref,
  sessionId,
) async {
  final db = ref.watch(databaseProvider);
  final session = await (db.select(
    db.testSessions,
  )..where((s) => s.id.equals(sessionId))).getSingleOrNull();
  final result =
      await (db.select(db.testResults)
            ..where((r) => r.sessionId.equals(sessionId))
            ..limit(1))
          .getSingleOrNull();
  if (session == null || result == null) return null;
  return '/sources/${session.sourceId}/tests/${result.id}';
});

/// One conversation, with a way to what it is about.
class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({super.key, required this.kind, required this.subjectId});

  final ThreadKind kind;
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final title = ref.watch(_titleProvider((kind, subjectId))).value;
    final open = switch (kind) {
      ThreadKind.source => '/sources/$subjectId',
      ThreadKind.collector => '/collectors/$subjectId',
      ThreadKind.area =>
        ref.watch(sessionProvider).isAdmin ? '/admin/places' : null,
      ThreadKind.test => ref.watch(_testPageProvider(subjectId)).value,
      ThreadKind.research => '/research/records/$subjectId',
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${l10n.messagesAbout(kind.name)}: ${title ?? ''}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (open != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.go(open),
              icon: Icon(_icon(kind)),
              label: Text(l10n.messagesOpen(kind.name)),
            ),
          ),
        const SizedBox(height: 8),
        ThreadSection(kind: kind, subjectId: subjectId),
      ],
    );
  }
}
