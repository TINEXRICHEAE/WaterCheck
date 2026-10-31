import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_service.dart';
import '../sync/collect_sync.dart';
import 'online_search.dart';
import 'source_providers.dart';
import 'source_status.dart';

/// Within this distance a source counts as nearby.
const nearbyMetres = 5000.0;

enum SourceFilter { all, safe, unsafe, notTested, mine, others, nearby }

/// Where a source sits for the person testing: their own first, then the
/// nearest, then their area, then the rest (2026-10-22).
enum SourceGroup { mine, nearby, area, elsewhere }

/// The sources on this phone, searchable and filtered, grouped as
/// [SourceGroup]: on Home and when choosing what to test.
class SourceBrowser extends ConsumerStatefulWidget {
  const SourceBrowser({
    super.key,
    required this.onOpen,
    this.onAdd,
    this.bottomPadding = 96,
  });

  final void Function(SourceSummary) onOpen;

  /// Offered when there is no source yet.
  final VoidCallback? onAdd;
  final double bottomPadding;

  @override
  ConsumerState<SourceBrowser> createState() => _SourceBrowserState();
}

class _SourceBrowserState extends ConsumerState<SourceBrowser> {
  var _query = '';
  var _filter = SourceFilter.all;
  GeoPoint? _here;
  var _locating = false;

  /// The search also asks the server (sources beyond this phone).
  var _online = false;

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      final here = await ref.read(locationServiceProvider).currentFix();
      if (mounted) setState(() => _here = here);
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 10),
            content: Text(
              locationProblemText(AppLocalizations.of(context), e.problem),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _pick(SourceFilter f) {
    setState(() => _filter = f);
    if (f == SourceFilter.nearby && _here == null) _locate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(sourceSummariesProvider).value ?? const [];
    final units = ref.watch(adminUnitsProvider).value ?? const [];
    final me = ref.watch(activeCollectorProvider);
    final byId = {for (final u in units) u.id: u};
    final here = _here;

    // The sub-county a source's village lies in, by name.
    String? subcountyOf(String villageId) {
      for (AdminUnit? u = byId[villageId]; u != null; u = byId[u.parentId]) {
        if (u.level == 'subcounty') return u.name.toLowerCase();
      }
      return null;
    }

    double? distance(SourceSummary s) =>
        here == null || s.source.location == null
        ? null
        : distanceMetres(here, s.source.location!);
    bool mine(SourceSummary s) =>
        me != null && s.source.collectorKey == me.collectorKey;
    SourceGroup group(SourceSummary s) {
      if (mine(s)) return SourceGroup.mine;
      final d = distance(s);
      if (d != null && d <= nearbyMetres) return SourceGroup.nearby;
      if (me != null &&
          subcountyOf(s.source.villageId) == me.subcounty.toLowerCase()) {
        return SourceGroup.area;
      }
      return SourceGroup.elsewhere;
    }

    bool keep(SourceSummary s) {
      final q = _query.trim().toLowerCase();
      if (q.isNotEmpty &&
          !s.source.code.toLowerCase().contains(q) &&
          !(s.source.name ?? '').toLowerCase().contains(q) &&
          !(byId[s.source.villageId]?.name.toLowerCase().contains(q) ??
              false)) {
        return false;
      }
      final overall = s.latest?.overall;
      return switch (_filter) {
        SourceFilter.all => true,
        SourceFilter.safe => overall == OverallStatus.safe,
        SourceFilter.unsafe => overall == OverallStatus.unsafe,
        SourceFilter.notTested => overall == null,
        SourceFilter.mine => mine(s),
        SourceFilter.others => !mine(s),
        SourceFilter.nearby => (distance(s) ?? double.infinity) <= nearbyMetres,
      };
    }

    final list =
        [
          for (final s in summaries)
            if (keep(s)) (s, group(s)),
        ]..sort((a, b) {
          final g = a.$2.index.compareTo(b.$2.index);
          if (g != 0) return g;
          final da = distance(a.$1), db = distance(b.$1);
          if (da != null && db != null) return da.compareTo(db);
          return (a.$1.source.name ?? a.$1.source.code).compareTo(
            b.$1.source.name ?? b.$1.source.code,
          );
        });

    String filterLabel(SourceFilter f) => switch (f) {
      SourceFilter.all => l10n.filterAll,
      SourceFilter.safe => l10n.filterSafe,
      SourceFilter.unsafe => l10n.filterUnsafe,
      SourceFilter.notTested => l10n.filterNotTested,
      SourceFilter.mine => l10n.filterMine,
      SourceFilter.others => l10n.filterOthers,
      SourceFilter.nearby => l10n.filterNearby,
    };
    String groupLabel(SourceGroup g) => switch (g) {
      SourceGroup.mine => l10n.groupMine,
      SourceGroup.nearby => l10n.groupNearby,
      SourceGroup.area => l10n.groupArea,
      SourceGroup.elsewhere => l10n.groupElsewhere,
    };
    final filtered = _query.isNotEmpty || _filter != SourceFilter.all;

    final rows = <Widget>[];
    final term = _query.trim();
    final online = term.length >= 2 && _online
        ? ref.watch(onlineSourceSearchProvider(term))
        : null;
    SourceGroup? last;
    for (final (s, g) in list) {
      if (g != last) {
        last = g;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              groupLabel(g),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
      }
      final d = distance(s);
      final village = byId[s.source.villageId]?.name;
      rows.add(
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(s.source.name ?? s.source.code),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  if (s.source.name != null) s.source.code,
                  ?village,
                  if (d != null) l10n.distanceAway(_metres(d)),
                ].join(' · '),
              ),
              SourceScheduleText(s),
            ],
          ),
          trailing: StatusBadge(statusOf(s)),
          onTap: () => widget.onOpen(s),
        ),
      );
      rows.add(const Divider(height: 1));
    }

    // Beyond this phone's districts: ask the server (online).
    if (term.length >= 2) {
      final local = {for (final s in summaries) s.source.id};
      if (!_online) {
        rows.add(
          ListTile(
            leading: const Icon(Icons.travel_explore),
            title: Text(l10n.searchOnline),
            subtitle: Text(l10n.searchOnlineHint),
            onTap: () => setState(() => _online = true),
          ),
        );
      } else {
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.groupOnline,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        );
        final hits = online?.value;
        if (online == null || online.isLoading) {
          rows.add(const LinearProgressIndicator());
        } else if (hits == null) {
          rows.add(ListTile(title: Text(l10n.searchOnlineOffline)));
        } else {
          final fresh = [
            for (final h in hits)
              if (!local.contains(h.id)) h,
          ];
          if (fresh.isEmpty) {
            rows.add(ListTile(title: Text(l10n.searchOnlineNone)));
          }
          for (final h in fresh) {
            rows.add(
              ListTile(
                title: Text(h.name ?? h.code),
                subtitle: Text(
                  [
                    if (h.name != null) h.code,
                    h.village,
                    ?h.district,
                  ].join(' · '),
                ),
                trailing: h.districtId == null
                    ? null
                    : BusyButton(
                        kind: BusyButtonKind.text,
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final msg = l10n.searchOnlineAdded(h.district ?? '');
                          await addDistrict(ref, h.districtId!);
                          messenger.showSnackBar(SnackBar(content: Text(msg)));
                        },
                        child: Text(l10n.searchOnlineGet),
                      ),
              ),
            );
          }
        }
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SearchField(
            value: _query,
            label: l10n.sourcesSearch,
            history: 'collect.sources',
            onChanged: (v) => setState(() {
              _query = v;
              _online = false;
            }),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              for (final f in SourceFilter.values) ...[
                ChoiceChip(
                  label: Text(filterLabel(f)),
                  selected: _filter == f,
                  avatar: f == SourceFilter.nearby && _locating
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onSelected: (_) => _pick(f),
                ),
                const SizedBox(width: 8),
              ],
              if (filtered)
                ResetFiltersButton(
                  onPressed: () => setState(() {
                    _query = '';
                    _filter = SourceFilter.all;
                  }),
                ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty && rows.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          summaries.isEmpty ? l10n.homeEmpty : l10n.pickNoMatch,
                          textAlign: TextAlign.center,
                        ),
                        if (summaries.isEmpty && widget.onAdd != null) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: widget.onAdd,
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: Text(l10n.sourcesAdd),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  // Pull down to sync now.
                  onRefresh: () => ref
                      .read(syncControllerProvider.notifier)
                      .run(force: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: widget.bottomPadding),
                    children: rows,
                  ),
                ),
        ),
      ],
    );
  }

  static String _metres(double m) => m < 1000
      ? '${m.round()} m'
      : '${(m / 1000).toStringAsFixed(m < 10000 ? 1 : 0)} km';
}
