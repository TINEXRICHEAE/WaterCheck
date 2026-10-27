import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import 'research_dashboard.dart';
import 'research_state.dart';

/// A messages button with the number of records awaiting an answer.
class ResearchMessagesButton extends ConsumerWidget {
  const ResearchMessagesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final waiting = ref.watch(researchAwaitingProvider);
    return IconButton(
      tooltip: waiting == 0
          ? l10n.messagesTitle
          : l10n.researchAwaiting(waiting),
      onPressed: () => context.go('/research/messages'),
      icon: Badge(
        isLabelVisible: waiting > 0,
        label: Text('$waiting'),
        child: const Icon(Icons.forum_outlined),
      ),
    );
  }
}

/// Conversations with collectors about records in the project, newest
/// first; those whose last message came from a collector await an answer.
class ResearchMessagesScreen extends ConsumerWidget {
  const ResearchMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM, HH:mm');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.messagesTitle, style: text.headlineSmall),
        Text(l10n.researchMessagesListHint),
        const SizedBox(height: 12),
        const ProjectPicker(),
        const SizedBox(height: 12),
        ...switch (ref.watch(researchThreadsProvider)) {
          AsyncData(:final value) when value.isEmpty => [
            Text(l10n.messagesNone),
          ],
          AsyncData(:final value) => [
            for (final t in value)
              Card(
                child: ListTile(
                  leading: Icon(
                    t.lastFromTeam
                        ? Icons.mark_chat_read_outlined
                        : Icons.mark_chat_unread_outlined,
                  ),
                  title: Text(
                    '${l10n.researchRecordTitle(t.number)} · ${t.formCode}',
                  ),
                  subtitle: Text(
                    '${t.lastAuthor ?? '?'}: ${t.lastBody}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        when.format(t.lastAt.toLocal()),
                        style: text.bodySmall,
                      ),
                      if (!t.lastFromTeam)
                        Text(l10n.researchNeedsAnswer, style: text.labelSmall),
                    ],
                  ),
                  onTap: () => context.go('/research/records/${t.recordId}'),
                ),
              ),
          ],
          AsyncError(:final error) => [
            ErrorView(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(researchThreadsProvider),
            ),
          ],
          _ => [const Center(child: CircularProgressIndicator())],
        },
      ],
    );
  }
}

/// Research › Admin (IT admins): every research project on the server,
/// and the shared administration (people, phones, system), which serves
/// both water testing and research.
class ResearchAdminScreen extends ConsumerWidget {
  const ResearchAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final projects = ref.watch(researchProjectsProvider).value ?? const [];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.navAdmin, style: text.headlineSmall),
        Text(l10n.researchAdminHint),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (final (icon, title, path) in [
                (
                  Icons.people_outline,
                  l10n.researchAdminPeople,
                  '/admin/people',
                ),
                (
                  Icons.phone_android,
                  l10n.researchAdminPhones,
                  '/admin/phones',
                ),
                (Icons.security, l10n.researchAdminSecurity, '/admin/security'),
                (Icons.dns_outlined, l10n.researchAdminSystem, '/admin/system'),
                (
                  Icons.admin_panel_settings_outlined,
                  l10n.researchAdminAll,
                  '/admin',
                ),
              ])
                ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(path),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.researchAllProjects(projects.length),
          style: text.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final p in projects)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(p.code)),
              title: Text(p.title),
              subtitle: Text(
                [
                  ?p.owner,
                  l10n.researchFormsCount(p.forms),
                  l10n.researchRecordsCount(p.records),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await ref.read(chosenProjectProvider.notifier).set(p.id);
                if (context.mounted) context.go('/research');
              },
            ),
          ),
      ],
    );
  }
}
