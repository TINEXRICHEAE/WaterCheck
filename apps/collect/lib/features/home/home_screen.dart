import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../collectors/active_collector_chip.dart';
import '../sources/source_providers.dart';
import '../sources/source_status.dart';
import '../sync/collect_sync.dart';

/// Home: the village's sources with status, due/overdue, sync state and
/// "Test a source" (SPEC §3.1 step 2).
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
        data: (list) => list.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.homeEmpty, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/sources/new'),
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: Text(l10n.sourcesAdd),
                      ),
                    ],
                  ),
                ),
              )
            // Pull down to sync now.
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(syncControllerProvider.notifier).run(force: true),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final s = list[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(s.source.name ?? s.source.code),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (s.source.name != null) Text(s.source.code),
                          SourceScheduleText(s),
                        ],
                      ),
                      trailing: StatusBadge(statusOf(s)),
                      onTap: () => context.push('/sources/${s.source.id}'),
                    );
                  },
                ),
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
