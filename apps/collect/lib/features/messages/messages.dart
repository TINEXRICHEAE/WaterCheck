import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../research/research.dart';

final messageRepositoryProvider = Provider<MessageRepository>(
  (ref) => MessageRepository(ref.watch(databaseProvider)),
);

final _threadProvider = StreamProvider.autoDispose
    .family<List<ThreadMessage>, (ThreadKind, String)>((ref, key) {
      final me = ref.watch(submissionOriginProvider);
      if (me == null) return Stream.value(const []);
      return ref
          .watch(messageRepositoryProvider)
          .watchThread(key.$1, key.$2, me);
    });

final _inboxProvider = StreamProvider.autoDispose<List<ThreadSummary>>((ref) {
  final me = ref.watch(submissionOriginProvider);
  if (me == null) return Stream.value(const []);
  return ref.watch(messageRepositoryProvider).watchInbox(me);
});

/// Messages from others not read on this device yet.
final unreadMessagesProvider = StreamProvider<int>((ref) {
  final me = ref.watch(submissionOriginProvider);
  if (me == null) return Stream.value(0);
  return ref.watch(messageRepositoryProvider).watchUnread(me);
});

/// The conversation about a test, a source, a collector or an area
/// (ADR-022), synced with the Console. Opening it marks it read.
class ThreadSection extends ConsumerStatefulWidget {
  const ThreadSection({super.key, required this.kind, required this.subjectId});

  final ThreadKind kind;
  final String subjectId;

  @override
  ConsumerState<ThreadSection> createState() => _ThreadSectionState();
}

class _ThreadSectionState extends ConsumerState<ThreadSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages =
        ref.watch(_threadProvider((widget.kind, widget.subjectId))).value ??
        const [];
    if (messages.any((m) => !m.mine)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(messageRepositoryProvider)
              .markRead(widget.kind, widget.subjectId);
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
        final origin = ref.read(submissionOriginProvider);
        if (origin == null) return;
        await ref
            .read(messageRepositoryProvider)
            .send(widget.kind, widget.subjectId, body, origin: origin);
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
      onPressed: () =>
          context.push(sidePath(ref.read(appModeProvider), '/messages')),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.forum_outlined),
      ),
    );
  }
}

String threadKindLabel(AppLocalizations l10n, ThreadKind kind) =>
    l10n.messagesAbout(kind.name);

/// Every conversation on this device, newest first (ADR-022).
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Each side's own conversations (ADR-031).
    final research = ref.watch(appModeProvider) == AppMode.research;
    final threads = ref
        .watch(_inboxProvider)
        .value
        ?.where((t) => (t.kind == ThreadKind.research) == research)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.messagesTitle)),
      body: threads == null
          ? const PageLoading()
          : threads.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.messagesNone),
            )
          : ListView(
              children: [
                for (final t in threads)
                  ListTile(
                    leading: Badge(
                      isLabelVisible: t.unread > 0,
                      label: Text('${t.unread}'),
                      child: Icon(_icon(t.kind)),
                    ),
                    title: Text('${threadKindLabel(l10n, t.kind)}: ${t.title}'),
                    subtitle: Text(
                      '${t.lastAuthor ?? '?'}: ${t.lastBody}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => context.push(
                      sidePath(
                        ref.read(appModeProvider),
                        '/messages/${t.kind.name}/${t.subjectId}',
                      ),
                    ),
                  ),
              ],
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

final _titleProvider = FutureProvider.autoDispose
    .family<String?, (ThreadKind, String)>(
      (ref, key) =>
          ref.watch(messageRepositoryProvider).subjectTitle(key.$1, key.$2),
    );

/// One conversation, full page.
class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({super.key, required this.kind, required this.subjectId});

  final ThreadKind kind;
  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final title = ref.watch(_titleProvider((kind, subjectId))).value;
    return Scaffold(
      appBar: AppBar(
        title: Text('${threadKindLabel(l10n, kind)}: ${title ?? ''}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (kind == ThreadKind.source)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push('/sources/$subjectId'),
                icon: const Icon(Icons.water_drop_outlined),
                label: Text(l10n.messagesOpenSource),
              ),
            ),
          if (kind == ThreadKind.research)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.push('/research/record/$subjectId'),
                icon: const Icon(Icons.assignment_outlined),
                label: Text(l10n.researchOpenRecord),
              ),
            ),
          ThreadSection(kind: kind, subjectId: subjectId),
        ],
      ),
    );
  }
}
