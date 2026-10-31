import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/console_sync.dart';
import '../../l10n/app_localizations.dart';

/// The in-app notifications (F-ALR-4): a bell with the unread count.
class InboxButton extends ConsumerWidget {
  const InboxButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final inbox = ref.watch(inboxProvider).value;
    final unread = inbox?.unread ?? 0;
    return IconButton(
      tooltip: l10n.inboxTitle,
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _InboxSheet(),
      ),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class _InboxSheet extends ConsumerWidget {
  const _InboxSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final loaded = ref.watch(inboxProvider);
    final inbox = loaded.value;
    final when = DateFormat('d MMM, HH:mm');
    final items = inbox?.items ?? const [];
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            ListTile(
              title: Text(
                l10n.inboxTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: BusyButton(
                kind: BusyButtonKind.text,
                onPressed: items.isEmpty
                    ? null
                    : () async {
                        await ref.read(notificationsApiProvider).markAllRead();
                        ref.invalidate(inboxProvider);
                      },
                child: Text(l10n.inboxMarkAll),
              ),
            ),
            // Loading is shown as loading, not as "offline" (2026-10-31).
            if (loaded.isLoading) const LinearProgressIndicator(),
            if (inbox == null && !loaded.isLoading)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.inboxOffline),
              )
            else if (inbox != null && items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.inboxEmpty),
              ),
            Expanded(
              child: ListView(
                children: [
                  for (final n in items)
                    ListTile(
                      leading: Icon(
                        n.kind == 'escalation'
                            ? Icons.priority_high
                            : Icons.warning_amber_rounded,
                        color: n.readAt == null
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                      title: Text(
                        n.title,
                        style: n.readAt == null
                            ? const TextStyle(fontWeight: FontWeight.w700)
                            : null,
                      ),
                      subtitle: Text(
                        when.format(WcTime.local(n.createdAt, context)),
                      ),
                      onTap: () async {
                        await ref.read(notificationsApiProvider).markRead(n.id);
                        ref.invalidate(inboxProvider);
                        if (context.mounted && n.alertId != null) {
                          Navigator.pop(context);
                          context.go('/alerts/${n.alertId}');
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
