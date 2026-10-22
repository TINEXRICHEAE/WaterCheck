import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../location/location_service.dart';
import '../sources/source_providers.dart';
import '../sources/source_status.dart';
import '../sync/refresh_button.dart';
import 'map_tiles.dart';

/// The map in Collect (ADR-019 slice B, ADR-021): the sources on this phone
/// by status over the labelled map of Uganda. One search finds any area
/// (including places added from phones) or source; the map flies there.
/// [areaId] or [sourceId] (from the address) say what is chosen; the path
/// above it reads Uganda › region › district › … › source. Layers: source
/// names, straight-line distances from here, and the road route to the
/// chosen source by motorbike/car or on foot.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.areaId, this.sourceId});

  final String? areaId;
  final String? sourceId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final _map = MapController();
  late final _motion = MapMotion(_map, this);
  var _layers = const MapLayers();
  LatLng? _here;
  var _locating = false;
  MapRoute? _route;
  String? _routeKey;
  var _routeLoading = false;

  @override
  void didUpdateWidget(MapScreen old) {
    super.didUpdateWidget(old);
    if (old.areaId != widget.areaId || old.sourceId != widget.sourceId) {
      _route = null;
      _routeKey = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _flyToChoice());
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    _map.dispose();
    super.dispose();
  }

  Future<void> _locate({bool fly = true}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final fix = await ref.read(locationServiceProvider).currentFix();
      final here = LatLng(fix.lat, fix.lon);
      if (!mounted) return;
      setState(() => _here = here);
      if (fly) await _motion.moveTo(here, 14);
    } on LocationException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).locationUnavailable),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Flies to the chosen source, or around the chosen area's sources.
  Future<void> _flyToChoice() async {
    final units = ref.read(adminUnitsProvider).value;
    final summaries = ref.read(sourceSummariesProvider).value;
    if (units == null || summaries == null) return;
    final tree = AreaTree(units);
    final source = summaries
        .where((s) => s.source.id == widget.sourceId)
        .firstOrNull;
    final loc = source?.source.location;
    if (loc != null) return _motion.moveTo(LatLng(loc.lat, loc.lon), 16);
    final areaId = source?.source.villageId ?? widget.areaId;
    final area = areaId == null ? null : tree.byId[areaId];
    if (area == null) return;
    final points = [
      for (final s in summaries)
        if (s.source.location != null &&
            tree.under(s.source.villageId, area.id))
          LatLng(s.source.location!.lat, s.source.location!.lon),
    ];
    if (points.isNotEmpty) return _motion.fit(points, maxZoom: 14);
    final c = tree.centre(area.id);
    if (c != null) {
      return _motion.moveTo(LatLng(c.lat, c.lon), AreaTree.zoomFor(area.level));
    }
  }

  void _setLayers(MapLayers next) {
    final modeChanged = next.mode != _layers.mode;
    setState(() {
      _layers = next;
      if (modeChanged) _routeKey = null;
    });
    if ((next.lines || next.route) && _here == null) _locate(fly: false);
  }

  /// The road route to [to], fetched once per place, mode and position.
  void _ensureRoute(LatLng to) {
    final here = _here;
    if (!_layers.route || here == null) return;
    final key = '$to|${_layers.mode}|$here';
    if (key == _routeKey) return;
    _routeKey = key;
    final api = ref.read(credentialsProvider)?.apiUrl ?? defaultApiUrl();
    final mode = _layers.mode;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _routeLoading = true);
      final route = await fetchRoute(
        Dio(),
        base: routingBase(api),
        mode: mode,
        from: here,
        to: to,
      );
      if (!mounted || _routeKey != key) return;
      setState(() {
        _route = route;
        _routeLoading = false;
      });
    });
  }

  Color _colour(BuildContext context, SourceStatus s) {
    final c = Theme.of(context).extension<StatusColors>()!;
    return switch (s) {
      SourceStatus.safe => c.safe,
      SourceStatus.unsafe || SourceStatus.overdue => c.unsafe,
      SourceStatus.inconclusive => c.inconclusive,
      SourceStatus.dueSoon => c.due,
      SourceStatus.notTested => c.neutral,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final units = ref.watch(adminUnitsProvider).value;
    final summaries = ref.watch(sourceSummariesProvider).value;
    final template = ref.watch(mapTemplateProvider).value;
    if (units == null || summaries == null) {
      return const Scaffold(body: PageLoading());
    }
    final tree = AreaTree(units);
    final chosen = summaries
        .where((s) => s.source.id == widget.sourceId)
        .firstOrNull;
    final areaId = chosen?.source.villageId ?? widget.areaId;
    final area = areaId == null ? null : tree.byId[areaId];
    final inArea =
        [
          for (final s in summaries)
            if (area == null || tree.under(s.source.villageId, area.id)) s,
        ]..sort(
          (a, b) => (a.source.name ?? a.source.code).compareTo(
            b.source.name ?? b.source.code,
          ),
        );
    LatLng? at(SourceSummary s) => s.source.location == null
        ? null
        : LatLng(s.source.location!.lat, s.source.location!.lon);
    final placed = [
      for (final s in summaries)
        if (s.source.location != null) s,
    ];
    final focusPoints = [for (final s in inArea) ?at(s)];
    final centre = area == null ? null : tree.centre(area.id);
    final within = area == null || chosen != null
        ? const <AdminUnit>[]
        : ([
            for (final u in units)
              if (u.parentId == area.id) u,
          ]..sort((a, b) => a.name.compareTo(b.name)));
    final path = area == null
        ? const <AdminUnit>[]
        : [
            for (final u in tree.pathTo(area.id))
              if (u.level != 'country') u,
          ];
    final chosenAt = chosen == null ? null : at(chosen);
    if (chosenAt != null) _ensureRoute(chosenAt);

    // Straight lines: to the chosen source, else to the 5 nearest.
    final here = _here;
    const distance = Distance();
    final lineTargets = here == null || !_layers.lines
        ? const <LatLng>[]
        : chosenAt != null
        ? [chosenAt]
        : ([
                for (final s in placed) at(s)!,
              ]..sort((a, b) => distance(here, a).compareTo(distance(here, b))))
              .take(5)
              .toList();

    // Search: every area (any level) and every source on this phone.
    final places = [
      for (final u in units)
        if (u.level != 'country')
          MapPlace(
            id: u.id,
            name: u.name,
            isSource: false,
            detail: [
              areaLevelText(l10n, u.level),
              for (final p in tree.pathTo(u.id).reversed.skip(1))
                if (p.level != 'country' && p.level != 'region') p.name,
            ].join(' · '),
          ),
      for (final s in summaries)
        MapPlace(
          id: s.source.id,
          name: s.source.name ?? s.source.code,
          isSource: true,
          detail: [
            if (s.source.name != null) s.source.code,
            ?tree.byId[s.source.villageId]?.name,
          ].join(' · '),
        ),
    ];

    final map = Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            crs: const NoRepeatCrs(),
            initialCenter:
                chosenAt ??
                (focusPoints.length == 1
                    ? focusPoints.single
                    : centre != null
                    ? LatLng(centre.lat, centre.lon)
                    : const LatLng(1.37, 32.29)),
            initialZoom: chosenAt != null
                ? 16
                : focusPoints.length == 1
                ? 13
                : area != null
                ? AreaTree.zoomFor(area.level)
                : 7,
            initialCameraFit: chosenAt == null && focusPoints.length > 1
                ? CameraFit.coordinates(
                    coordinates: focusPoints,
                    padding: const EdgeInsets.all(48),
                    maxZoom: 14,
                  )
                : null,
            minZoom: 5,
            maxZoom: 19,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
          ),
          children: [
            if (template != null)
              TileLayer(
                urlTemplate: template,
                maxNativeZoom: 18,
                userAgentPackageName: 'org.watercheck.collect',
              ),
            if (_layers.route && _route != null) RouteLayer(route: _route!),
            if (here != null && lineTargets.isNotEmpty)
              StraightLinesLayer(from: here, to: lineTargets),
            MarkerLayer(
              markers: [
                for (final s in placed)
                  Marker(
                    point: at(s)!,
                    width: _layers.labels ? 140 : 30,
                    height: _layers.labels ? 52 : 30,
                    alignment: _layers.labels
                        ? const Alignment(0, 0.3)
                        : Alignment.center,
                    child: _Dot(
                      colour: _colour(context, statusOf(s)),
                      chosen: s.source.id == widget.sourceId,
                      label: _layers.labels
                          ? (s.source.name ?? s.source.code)
                          : null,
                      tooltip:
                          '${s.source.name ?? s.source.code} · '
                          '${statusText(context, statusOf(s))}',
                      onTap: () => context.go('/map?source=${s.source.id}'),
                    ),
                  ),
                if (here != null)
                  Marker(
                    point: here,
                    width: 20,
                    height: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
              ],
            ),
            if (template != null)
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
          ],
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 72,
          child: Align(
            alignment: Alignment.topLeft,
            child: MapSearchBar(
              places: places,
              onSelected: (p) => context.go(
                p.isSource ? '/map?source=${p.id}' : '/map?area=${p.id}',
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: MapLayersButton(layers: _layers, onChanged: _setLayers),
        ),
        if (chosen != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 28,
            child: _ChosenCard(
              summary: chosen,
              line: chosenAt == null
                  ? l10n.mapNoLocation
                  : here == null
                  ? l10n.mapLocateForDistance
                  : distanceSummary(
                      ui,
                      straight: distance(here, chosenAt),
                      route: _layers.route ? _route : null,
                      mode: _layers.mode,
                      routeWanted: _layers.route,
                      routeLoading: _routeLoading,
                    ),
            ),
          ),
      ],
    );

    final list = ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (path.isNotEmpty || chosen != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionChip(
                  label: Text(l10n.mapAllAreas),
                  onPressed: () => context.go('/map'),
                ),
                for (final u in path)
                  ActionChip(
                    avatar: const Icon(Icons.chevron_right, size: 16),
                    label: Text('${u.name} (${areaLevelText(l10n, u.level)})'),
                    onPressed: chosen == null && u.id == area!.id
                        ? null
                        : () => context.go('/map?area=${u.id}'),
                  ),
                if (chosen != null)
                  ActionChip(
                    avatar: const Icon(Icons.water_drop, size: 16),
                    label: Text(chosen.source.name ?? chosen.source.code),
                    onPressed: () =>
                        context.push('/sources/${chosen.source.id}'),
                  ),
              ],
            ),
          ),
        if (within.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              l10n.mapWithin(within.length),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final u in within.take(60))
                  ActionChip(
                    label: Text(u.name),
                    onPressed: () => context.go('/map?area=${u.id}'),
                  ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            l10n.mapSourcesHere(inArea.length, focusPoints.length),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (inArea.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.mapNoSources),
          ),
        for (final s in inArea)
          ListTile(
            selected: s.source.id == widget.sourceId,
            leading: StatusBadge(statusOf(s)),
            title: Text(s.source.name ?? s.source.code),
            subtitle: Text(
              [
                if (s.source.name != null) s.source.code,
                ?tree.byId[s.source.villageId]?.name,
                if (s.source.location == null) l10n.mapNoLocation,
                if (here != null && at(s) != null)
                  formatMetres(distance(here, at(s)!)),
              ].join(' · '),
            ),
            trailing: IconButton(
              tooltip: l10n.mapOpenSource,
              icon: const Icon(Icons.open_in_new),
              onPressed: () => context.push('/sources/${s.source.id}'),
            ),
            onTap: () => context.go('/map?source=${s.source.id}'),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chosen?.source.name ??
              chosen?.source.code ??
              area?.name ??
              l10n.mapTitle,
        ),
        actions: [
          IconButton(
            tooltip: l10n.mapMyLocation,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            onPressed: _locate,
          ),
          const SyncRefreshButton(),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) => box.maxWidth > 760
            ? Row(
                children: [
                  Expanded(child: map),
                  SizedBox(width: 380, child: list),
                ],
              )
            : Column(
                children: [
                  SizedBox(height: box.maxHeight * 0.55, child: map),
                  const Divider(height: 1),
                  Expanded(child: list),
                ],
              ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.colour,
    required this.chosen,
    required this.tooltip,
    required this.onTap,
    this.label,
  });

  final Color colour;
  final bool chosen;
  final String tooltip;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final size = chosen ? 30.0 : 24.0;
    final dot = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colour,
        border: Border.all(color: Colors.white, width: chosen ? 3 : 2),
        boxShadow: chosen
            ? const [BoxShadow(blurRadius: 6, color: Colors.black38)]
            : null,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(Icons.water_drop, size: size * 0.5, color: Colors.white),
      ),
    );
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: label == null
            ? Center(child: dot)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  dot,
                  const SizedBox(height: 2),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The chosen source over the map: status, distance and route, and a way in.
class _ChosenCard extends StatelessWidget {
  const _ChosenCard({required this.summary, required this.line});

  final SourceSummary summary;
  final String line;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      child: ListTile(
        leading: StatusBadge(statusOf(summary)),
        title: Text(summary.source.name ?? summary.source.code),
        subtitle: Text(line),
        trailing: FilledButton.tonal(
          onPressed: () => context.push('/sources/${summary.source.id}'),
          child: Text(l10n.mapOpenSource),
        ),
      ),
    );
  }
}

String areaLevelText(AppLocalizations l10n, String level) => switch (level) {
  'country' => l10n.levelCountry,
  'region' => l10n.levelRegion,
  'district' => l10n.levelDistrict,
  'subcounty' => l10n.levelSubcounty,
  'parish' => l10n.levelParish,
  _ => l10n.levelVillage,
};

String statusText(BuildContext context, SourceStatus s) {
  final ui = UiKitLocalizations.of(context);
  return switch (s) {
    SourceStatus.safe => ui.statusSafe,
    SourceStatus.unsafe => ui.statusUnsafe,
    SourceStatus.inconclusive => ui.statusInconclusive,
    SourceStatus.notTested => ui.statusNotTested,
    SourceStatus.dueSoon => ui.statusDueSoon,
    SourceStatus.overdue => ui.statusOverdue,
  };
}
