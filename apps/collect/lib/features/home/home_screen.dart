import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../messages/messages.dart';
import '../research/research.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sync/refresh_button.dart';
import '../collectors/active_collector_chip.dart';
import '../sources/source_providers.dart';
import '../sources/source_browser.dart';
import '../testing/test_draft.dart';
import '../testing/water_draft_keeper.dart';

/// Home: the sources on this phone with status, due/overdue, sync state
/// and "Test a source" (SPEC §3.1 step 2): searchable and filtered, your
/// own first, then nearby, your area and elsewhere (2026-10-22).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(sourceSummariesProvider);
    final sync = ref.watch(syncSummaryProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            tooltip: l10n.sourcesAdd,
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () => context.push('/sources/new'),
          ),
          IconButton(
            tooltip: l10n.profileTitle,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
          const SideSwitchButton(),
          const MessagesButton(),
          const SyncRefreshButton(),
          SyncIndicator(
            compact: true,
            pending: sync?.pending ?? 0,
            rejected: sync?.rejected ?? 0,
            onTap: () => context.go('/sync'),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ActiveCollectorChip(),
            ),
          ),
        ),
      ),
      body: summaries.when(
        loading: () => const PageLoading(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(sourceSummariesProvider),
        ),
        data: (_) => Column(
          children: [
            const _UnfinishedTests(),
            Expanded(
              child: SourceBrowser(
                onOpen: (s) => context.push('/sources/${s.source.id}'),
                onAdd: () => context.push('/sources/new'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/test'),
        icon: const Icon(Icons.science_outlined),
        label: Text(l10n.homeTestSource),
      ),
    );
  }
}

/// Water tests not finished (ADR-034): carried on with, or thrown away.
class _UnfinishedTests extends ConsumerWidget {
  const _UnfinishedTests();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tests = ref.watch(waterDraftsProvider).value ?? const [];
    if (tests.isEmpty) return const SizedBox.shrink();
    final when = DateFormat.MMMd().add_Hm();
    final notifier = ref.read(testDraftProvider.notifier);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 176),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        children: [
          for (final t in tests)
            Card(
              child: BusyListTile(
                leading: const Icon(Icons.edit_note),
                title: Text(t.sourceName ?? t.sourceCode),
                subtitle: Text(
                  '${l10n.waterDraftUnfinished} · '
                  '${when.format(t.updatedAt.toLocal())}',
                ),
                trailing: IconButton(
                  tooltip: l10n.waterDraftDiscard,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirmAction(
                      context,
                      title: l10n.waterDraftDiscard,
                      message: l10n.waterDraftDiscardAsk,
                      confirm: l10n.waterDraftDiscard,
                      destructive: true,
                    )) {
                      await notifier.keeper.discard(t.id);
                    }
                  },
                ),
                onTap: () async {
                  final saved = await notifier.keeper.open(t.id);
                  if (saved == null || !context.mounted) return;
                  notifier.resume(saved);
                  final ready =
                      saved.profile != null &&
                      (saved.location != null || saved.farReason != null);
                  await context.push(ready ? '/test/entry' : '/test/setup');
                },
              ),
            ),
        ],
      ),
    );
  }
}
