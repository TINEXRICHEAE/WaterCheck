import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../messages/messages.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sync/refresh_button.dart';
import '../collectors/active_collector_chip.dart';
import '../sources/source_providers.dart';
import '../sources/source_browser.dart';

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
        data: (_) => SourceBrowser(
          onOpen: (s) => context.push('/sources/${s.source.id}'),
          onAdd: () => context.push('/sources/new'),
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
