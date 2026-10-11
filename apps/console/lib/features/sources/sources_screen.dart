import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import '../dashboard/filter_bar.dart';
import '../map/sources_map.dart';

enum SourceFilter { all, unsafe, overdue, notTested }

class SourcesQuery {
  const SourcesQuery({
    this.text = '',
    this.filter = SourceFilter.all,
    this.map = false,
  });

  final String text;
  final SourceFilter filter;
  final bool map;
}

class SourcesQueryNotifier extends Notifier<SourcesQuery> {
  @override
  SourcesQuery build() => const SourcesQuery();

  void text(String t) =>
      state = SourcesQuery(text: t, filter: state.filter, map: state.map);

  void filter(SourceFilter f) =>
      state = SourcesQuery(text: state.text, filter: f, map: state.map);

  void map(bool m) =>
      state = SourcesQuery(text: state.text, filter: state.filter, map: m);
}

/// Search, filter and list/map choice; the dashboard map card opens the map.
final sourcesQueryProvider =
    NotifierProvider<SourcesQueryNotifier, SourcesQuery>(
      SourcesQueryNotifier.new,
    );

bool _matches(SourceView s, SourcesQuery q) {
  final t = q.text.trim().toLowerCase();
  if (t.isNotEmpty &&
      !s.code.toLowerCase().contains(t) &&
      !(s.name ?? '').toLowerCase().contains(t)) {
    return false;
  }
  return switch (q.filter) {
    SourceFilter.all => true,
    SourceFilter.unsafe => s.latest?.overall == OverallStatus.unsafe,
    SourceFilter.overdue => s.schedule.status == ScheduleStatus.overdue,
    SourceFilter.notTested => s.latest == null,
  };
}

/// All sources in the selected area (SPEC P9), with filters. Status is a
/// badge with icon and text, never colour alone.
class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final q = ref.watch(sourcesQueryProvider);
    final data = ref.watch(dashboardProvider).value;
    final rows = [
      for (final s in data?.sources ?? const <SourceView>[])
        if (_matches(s, q)) s,
    ]..sort((a, b) => a.code.compareTo(b.code));
    final when = DateFormat('d MMM y');
    // Map: only the map, edge to edge, with floating controls.
    if (q.map) {
      return SourcesMap(
        sources: rows,
        overlay: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surface,
          child: _ViewToggle(map: q.map),
        ),
      );
    }
    final header = <Widget>[
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.navSources,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          _ViewToggle(map: q.map),
        ],
      ),
      const SizedBox(height: 12),
      const FilterBar(showPeriod: false),
      const SizedBox(height: 12),
      TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          labelText: l10n.sourcesSearch,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: ref.read(sourcesQueryProvider.notifier).text,
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          for (final f in SourceFilter.values)
            ChoiceChip(
              label: Text(switch (f) {
                SourceFilter.all => l10n.filterAll,
                SourceFilter.unsafe => l10n.filterUnsafe,
                SourceFilter.overdue => l10n.filterOverdue,
                SourceFilter.notTested => l10n.filterNotTested,
              }),
              selected: q.filter == f,
              onSelected: (_) =>
                  ref.read(sourcesQueryProvider.notifier).filter(f),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Text(l10n.sourcesCount(rows.length)),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...header,
        for (final s in rows)
          Card(
            child: ListTile(
              leading: StatusBadge(
                s.latest?.overall.display ?? SourceStatus.notTested,
              ),
              title: Text(s.name == null ? s.code : '${s.name} (${s.code})'),
              subtitle: Text(
                [
                  s.latest == null
                      ? l10n.neverTested
                      : l10n.lastTested(
                          when.format(s.latest!.testedAt.toLocal()),
                        ),
                  if (s.schedule.status == ScheduleStatus.overdue)
                    l10n.overdueShort,
                  if (s.functionalStatus != 'functional')
                    l10n.functionalStatus(s.functionalStatus),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/sources/${s.id}'),
            ),
          ),
      ],
    );
  }
}

class _ViewToggle extends ConsumerWidget {
  const _ViewToggle({required this.map});

  final bool map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          icon: const Icon(Icons.list),
          label: Text(l10n.viewList),
        ),
        ButtonSegment(
          value: true,
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.viewMap),
        ),
      ],
      selected: {map},
      onSelectionChanged: (v) =>
          ref.read(sourcesQueryProvider.notifier).map(v.single),
    );
  }
}
