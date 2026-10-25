import 'dart:async';
import 'dart:math' as math;

import 'package:api_client/api_client.dart' show PlaceRename, WaterCheckApi;
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:ui_kit/map_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../alerts/alerts_screen.dart' show severityColor, triggerText;
import '../dashboard/dashboard_state.dart'
    show dataVersionProvider, mapHomeProvider;
import '../sources/sources_screen.dart' show sourcesQueryProvider;
import 'device_location.dart';
import 'map_tiles.dart';

/// Below this zoom, nearby dots merge into one with a count.
const _clusterBelowZoom = 12.0;

/// From this zoom, each dot shows its code and status word.
const _labelsFromZoom = 13.0;

/// The source the full map should open on (set by the dashboard card).
class MapFocus extends Notifier<String?> {
  @override
  String? build() => null;

  void focus(String? sourceId) => state = sourceId;
}

final mapFocusProvider = NotifierProvider<MapFocus, String?>(MapFocus.new);

/// An area the map should open on, chosen on another page.
class MapAreaFocus extends Notifier<String?> {
  @override
  String? build() => null;

  void focus(String? areaId) => state = areaId;
}

final mapAreaFocusProvider = NotifierProvider<MapAreaFocus, String?>(
  MapAreaFocus.new,
);

/// Opens Sources › Map on an area (a collector's or a place, ADR-022).
void showAreaOnMap(BuildContext context, WidgetRef ref, String areaId) {
  ref.read(mapFocusProvider.notifier).focus(null);
  ref.read(mapAreaFocusProvider.notifier).focus(areaId);
  ref.read(sourcesQueryProvider.notifier).map(true);
  context.go('/sources');
}

/// Opens Sources › Map flying to [sourceId] ("Show on map", 2026-10-22).
void showSourceOnMap(BuildContext context, WidgetRef ref, String sourceId) {
  ref.read(mapFocusProvider.notifier).focus(sourceId);
  ref.read(sourcesQueryProvider.notifier).map(true);
  context.go('/sources');
}

/// Names on the map placed in their sub-county (ADR-023), ready for the
/// search box: built once, not on every redraw (an IT admin holds all
/// of Uganda's, about 64,000).
final mapNamePlacesProvider = FutureProvider<List<MapPlace>>((ref) async {
  // Again after each sync: the first one brings the names.
  ref.watch(consoleSyncProvider.select((s) => s.last));
  ref.watch(dataVersionProvider);
  final names = await MapPlaceRepository(ref.watch(databaseProvider)).all();
  final units = {
    for (final u
        in await ref.watch(referenceDataRepositoryProvider).adminUnits())
      u.id: u,
  };
  return [
    for (final m in names)
      MapPlace(
        id: m.id,
        name: m.name,
        isSource: false,
        fromMap: true,
        lat: m.lat,
        lon: m.lon,
        areaId: m.subcountyId,
        addedBy: m.addedBy,
        detail: [
          ?units[m.subcountyId]?.name,
          ?units[units[m.subcountyId]?.parentId]?.name,
        ].join(', '),
      ),
  ];
});

/// The area list, for the map search and the path to a chosen place.
final _mapAreasProvider = FutureProvider<List<AdminUnit>>(
  (ref) => ref.watch(referenceDataRepositoryProvider).adminUnits(),
);

final openAlertsProvider = StreamProvider<List<AlertListItem>>(
  (ref) => ref.watch(alertRepositoryProvider).watchList(),
);

/// What a dot says. Colours as on any map: red unsafe, tan caution
/// (inconclusive or overdue), green safe, grey not tested. The status word
/// is always given too (label, tooltip, screen reader), so colour is never
/// the only signal (SPEC §11).
enum MapStatus { unsafe, inconclusive, overdue, safe, untested }

MapStatus statusOf(SourceView s) => switch (s.latest?.overall) {
  OverallStatus.unsafe => MapStatus.unsafe,
  OverallStatus.inconclusive => MapStatus.inconclusive,
  OverallStatus.safe when s.schedule.status == ScheduleStatus.overdue =>
    MapStatus.overdue,
  OverallStatus.safe => MapStatus.safe,
  null => MapStatus.untested,
};

/// Worst first, for clusters.
int _severityRank(MapStatus s) => switch (s) {
  MapStatus.unsafe => 0,
  MapStatus.inconclusive || MapStatus.overdue => 1,
  MapStatus.safe => 2,
  MapStatus.untested => 3,
};

Color statusColor(BuildContext context, MapStatus s) {
  final c = Theme.of(context).extension<StatusColors>()!;
  return switch (s) {
    MapStatus.unsafe => c.unsafe,
    MapStatus.inconclusive || MapStatus.overdue => c.due,
    MapStatus.safe => c.safe,
    MapStatus.untested => c.neutral,
  };
}

String statusWord(AppLocalizations l10n, MapStatus s) => switch (s) {
  MapStatus.unsafe => l10n.mapUnsafe,
  MapStatus.inconclusive => l10n.mapInconclusive,
  MapStatus.overdue => l10n.mapOverdue,
  MapStatus.safe => l10n.mapSafe,
  MapStatus.untested => l10n.mapNotTested,
};

/// A source as the map needs it (from local data or the server summary).
typedef MapPoint = ({
  String id,
  String code,
  String? name,
  double lat,
  double lon,
  MapStatus status,
});

MapPoint pointOf(SourceView s) => (
  id: s.id,
  code: s.code,
  name: s.name,
  lat: s.lat!,
  lon: s.lon!,
  status: statusOf(s),
);

/// The issue a stakeholder should look at first: the newest open alert
/// on a located source, else the newest unsafe result.
typedef MapIssue = ({
  MapPoint point,
  String rule,
  String severity,
  DateTime at,
});

MapIssue? latestIssue(List<SourceView> sources, List<AlertListItem> alerts) {
  final located = {
    for (final s in sources)
      if (s.lat != null && s.lon != null) s.id: s,
  };
  final open = [...alerts]..sort((a, b) => b.openedAt.compareTo(a.openedAt));
  for (final a in open) {
    final s = located[a.sourceId];
    if (s != null) {
      return (
        point: pointOf(s),
        rule: a.triggerRule,
        severity: a.severity,
        at: a.openedAt,
      );
    }
  }
  final unsafe = [
    for (final s in located.values)
      if (s.latest?.overall == OverallStatus.unsafe) s,
  ]..sort((a, b) => b.latest!.testedAt.compareTo(a.latest!.testedAt));
  if (unsafe.isEmpty) return null;
  final s = unsafe.first;
  return (
    point: pointOf(s),
    rule: 'unsafe',
    severity: 'high',
    at: s.latest!.testedAt,
  );
}

String formatDistance(double metres) => metres < 1000
    ? '${metres.round()} m'
    : '${(metres / 1000).toStringAsFixed(metres < 10000 ? 1 : 0)} km';

/// Full-screen map of sources (Sources › Map): only the map, with floating
/// controls. [overlay] floats top left (the List/Map switch).
class SourcesMap extends ConsumerStatefulWidget {
  const SourcesMap({super.key, required this.sources, this.overlay});

  final List<SourceView> sources;
  final Widget? overlay;

  @override
  ConsumerState<SourcesMap> createState() => _SourcesMapState();
}

class _SourcesMapState extends ConsumerState<SourcesMap>
    with TickerProviderStateMixin {
  final _map = MapController();
  late final _motion = MapMotion(_map, this);
  var _layers = const MapLayers();

  /// What the search chose (2026-10-22, ADR-021): an area, or a source
  /// (then also the focus).
  String? _areaId;

  /// A name from the map that was searched for (ADR-023), pinned.
  MapPlace? _pin;
  MapRoute? _route;
  String? _routeKey;
  var _routeLoading = false;

  /// Live navigation (ADR-029); the Console does not keep the track.
  LiveTrip? _trip;
  StreamSubscription<GeoFix>? _fixes;

  @override
  void dispose() {
    unawaited(_fixes?.cancel());
    _trip?.dispose();
    _motion.dispose();
    _map.dispose();
    super.dispose();
  }

  /// Follows this device to [to] live.
  Future<void> _go(LatLng to, String name) async {
    await _stop();
    final mode = _layers.mode;
    final trip = LiveTrip(
      target: to,
      targetName: name,
      mode: mode,
      routeTo: (from, to) => fetchRoute(
        Dio(),
        base: routingBase(defaultApiUrl()),
        mode: mode,
        from: from,
        to: to,
      ),
    )..addListener(() => mounted ? setState(() {}) : null);
    setState(() => _trip = trip);
    _fixes = ref
        .read(deviceFixesProvider)()
        .listen(
          (f) {
            unawaited(trip.add(f));
            if (trip.arrived) unawaited(_fixes?.cancel());
            if (mounted && trip.follow) {
              _map.move(LatLng(f.lat, f.lon), math.max(_map.camera.zoom, 15));
            }
          },
          onError: (Object _) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).mapNoLocation),
              ),
            );
            unawaited(_stop());
          },
        );
  }

  Future<void> _stop() async {
    await _fixes?.cancel();
    _fixes = null;
    _trip?.dispose();
    if (mounted) setState(() => _trip = null);
  }

  /// Adds a place missing from the map at [at] (ADR-028), sent with the
  /// Console's next sync.
  Future<void> _addPlace(LatLng at, AreaTree tree) async {
    final ui = UiKitLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final me = ref.read(sessionProvider).me;
    if (me == null) return;
    final repo = MapPlaceRepository(ref.read(databaseProvider));
    String? nearestCentre() {
      String? best;
      var bestM = 15000.0;
      for (final u in tree.byId.values) {
        if (u.level != 'subcounty') continue;
        final c = tree.centre(u.id);
        if (c == null) continue;
        final m = metresBetween(at, LatLng(c.lat, c.lon));
        if (m < bestM) {
          bestM = m;
          best = u.id;
        }
      }
      return best;
    }

    final sub =
        await repo.nearestSubcounty(at.latitude, at.longitude) ??
        nearestCentre();
    if (!mounted) return;
    if (sub == null) {
      messenger.showSnackBar(SnackBar(content: Text(ui.placeOutside)));
      return;
    }
    final answer = await showAddPlaceDialog(context, kinds: addedPlaceKinds);
    if (answer == null || !mounted) return;
    final place = await repo.add(
      name: answer.name,
      kind: answer.kind,
      lat: at.latitude,
      lon: at.longitude,
      subcountyId: sub,
      origin: SubmissionOrigin.console(userId: me.id),
      byName: me.fullName,
    );
    ref.invalidate(mapNamePlacesProvider);
    unawaited(ref.read(consoleSyncProvider.notifier).run());
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(ui.placeAdded(place.name))));
    setState(() {
      _areaId = sub;
      _pin = MapPlace(
        id: place.id,
        name: place.name,
        isSource: false,
        fromMap: true,
        lat: place.lat,
        lon: place.lon,
        areaId: sub,
        addedBy: place.addedBy,
      );
    });
  }

  /// IT admins correct places people added (ADR-028).
  Future<void> _renamePin(MapPlace pin) async {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final name = TextEditingController(text: pin.name);
    final next = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.mapPlaceRenameTitle),
        content: TextField(
          controller: name,
          autofocus: true,
          maxLength: 120,
          decoration: InputDecoration(labelText: ui.placeName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(ui.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(c, name.text.trim()),
            child: Text(l10n.mapPlaceRename),
          ),
        ],
      ),
    );
    name.dispose();
    if (next == null || next.isEmpty || next == pin.name || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await WaterCheckApi(ref.read(consoleDioProvider)).reference.renamePlace(
        placeId: pin.id,
        body: PlaceRename(name: next),
      );
    } on DioException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.mapPlaceNotChanged)));
      return;
    }
    await MapPlaceRepository(ref.read(databaseProvider)).rename(pin.id, next);
    ref.invalidate(mapNamePlacesProvider);
    if (mounted) {
      setState(
        () => _pin = MapPlace(
          id: pin.id,
          name: next,
          isSource: false,
          fromMap: true,
          lat: pin.lat,
          lon: pin.lon,
          areaId: pin.areaId,
          addedBy: pin.addedBy,
          detail: pin.detail,
        ),
      );
    }
  }

  Future<void> _removePin(MapPlace pin) async {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.mapPlaceRemoveTitle(pin.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(ui.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.mapPlaceRemove),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await WaterCheckApi(ref.read(consoleDioProvider)).reference
          .removePlace(placeId: pin.id);
    } on DioException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.mapPlaceNotChanged)));
      return;
    }
    await MapPlaceRepository(ref.read(databaseProvider)).forget(pin.id);
    ref.invalidate(mapNamePlacesProvider);
    if (mounted) setState(() => _pin = null);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.mapPlaceRemoved(pin.name))),
    );
  }

  /// Places anywhere in Uganda from the server, for the search box:
  /// names on the map and places people added outside this account's
  /// districts, and parishes and villages added from phones (ADR-028).
  Future<List<MapPlace>> _searchOnline(String text, AreaTree tree) async {
    final ui = UiKitLocalizations.of(context);
    final hits = await WaterCheckApi(ref.read(consoleDioProvider)).reference
        .searchPlaces(q: text);
    return [
      for (final h in hits)
        if (h.lat != null &&
            h.lon != null &&
            h.subcountyId != null &&
            tree.byId[h.id] == null)
          MapPlace(
            id: h.id,
            name: h.name,
            isSource: false,
            fromMap: true,
            lat: h.lat!.toDouble(),
            lon: h.lon!.toDouble(),
            areaId: h.subcountyId,
            addedBy: h.addedBy,
            detail: [
              if (h.addedBy case final by?) ui.placeAddedBy(by),
              ?h.subcounty,
              ?h.district,
            ].join(' · '),
          ),
    ];
  }

  /// Flies to a source, or around an area's sources.
  void _choose(MapPlace p, AreaTree tree) {
    if (p.fromMap) {
      // Its sub-county in the path; the map at the named point, pinned.
      setState(() {
        _areaId = p.areaId;
        _pin = p;
      });
      ref.read(mapFocusProvider.notifier).focus(null);
      _motion.moveTo(LatLng(p.lat!, p.lon!), 15);
      return;
    }
    setState(() => _pin = null);
    if (p.isSource) {
      final s = widget.sources.where((x) => x.id == p.id).firstOrNull;
      setState(() => _areaId = s?.villageId);
      ref.read(mapFocusProvider.notifier).focus(p.id);
      if (s?.lat != null) _motion.moveTo(LatLng(s!.lat!, s.lon!), 16);
      return;
    }
    setState(() => _areaId = p.id);
    ref.read(mapFocusProvider.notifier).focus(null);
    final points = [
      for (final s in widget.sources)
        if (s.lat != null && tree.under(s.villageId, p.id))
          LatLng(s.lat!, s.lon!),
    ];
    if (points.isNotEmpty) {
      _motion.fit(points, maxZoom: 14);
      return;
    }
    final c = tree.centre(p.id);
    final u = tree.byId[p.id];
    if (c != null && u != null) {
      _motion.moveTo(LatLng(c.lat, c.lon), AreaTree.zoomFor(u.level));
    }
  }

  /// The road route from here to the chosen source, once per place, mode
  /// and position.
  void _ensureRoute(LatLng from, LatLng to) {
    if (!_layers.route) return;
    final key = '$from|$to|${_layers.mode}';
    if (key == _routeKey) return;
    _routeKey = key;
    final mode = _layers.mode;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _routeLoading = true);
      final route = await fetchRoute(
        Dio(),
        base: routingBase(defaultApiUrl()),
        mode: mode,
        from: from,
        to: to,
      );
      if (!mounted || _routeKey != key) return;
      setState(() {
        _route = route;
        _routeLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = ref.watch(mapTilesProvider).value ?? MapTiles.none;
    final me = ref.watch(deviceLocationProvider).value;
    final alerts = ref.watch(openAlertsProvider).value ?? const [];
    final focusId = ref.watch(mapFocusProvider);
    final home =
        ref.watch(mapHomeProvider).value ?? (lat: 1.37, lon: 32.29, zoom: 7.0);
    final placed = [
      for (final s in widget.sources)
        if (s.lat != null && s.lon != null) s,
    ];
    final issue = latestIssue(placed, alerts);
    final dots = [for (final s in placed) pointOf(s)];
    final focus = dots.where((d) => d.id == focusId).firstOrNull;
    final units = ref.watch(_mapAreasProvider).value ?? const <AdminUnit>[];
    final tree = AreaTree(units);
    // An area asked for by another page: choose it once the map is there.
    final askedArea = ref.watch(mapAreaFocusProvider);
    if (askedArea != null && tree.byId[askedArea] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(mapAreaFocusProvider.notifier).focus(null);
        final u = tree.byId[askedArea]!;
        _choose(MapPlace(id: u.id, name: u.name, isSource: false), tree);
      });
    }
    final chosenSource = widget.sources
        .where((s) => s.id == focusId)
        .firstOrNull;
    final areaId = chosenSource?.villageId ?? _areaId;
    final path = areaId == null
        ? const <AdminUnit>[]
        : [
            for (final u in tree.pathTo(areaId))
              if (u.level != 'country') u,
          ];
    final focusAt = focus == null ? null : LatLng(focus.lat, focus.lon);
    // Where routes and "Go" lead (ADR-028): the source, else the pinned
    // place, else the chosen area's centre (sub-county and below).
    final chosenArea = areaId == null ? null : tree.byId[areaId];
    final areaCentre = chosenArea == null ? null : tree.centre(chosenArea.id);
    final pin = _pin;
    final target = focusAt != null
        ? (at: focusAt, name: chosenSource?.name ?? focus!.code)
        : pin != null
        ? (at: LatLng(pin.lat!, pin.lon!), name: pin.name)
        : chosenArea != null &&
              const {
                'subcounty',
                'parish',
                'village',
              }.contains(chosenArea.level) &&
              areaCentre != null
        ? (at: LatLng(areaCentre.lat, areaCentre.lon), name: chosenArea.name)
        : null;
    final trip = _trip;
    if (me != null && target != null && trip == null) {
      _ensureRoute(me, target.at);
    }
    final isAdmin = ref.watch(sessionProvider).isAdmin;
    final places = [
      for (final u in units)
        if (u.level != 'country')
          MapPlace(
            id: u.id,
            name: u.name,
            isSource: false,
            detail: [
              l10n.areaLevel(u.level),
              for (final a in tree.pathTo(u.id).reversed.skip(1))
                if (a.level != 'country' && a.level != 'region') a.name,
            ].join(' · '),
          ),
      ...?ref.watch(mapNamePlacesProvider).value,
      for (final s in widget.sources)
        MapPlace(
          id: s.id,
          name: s.name ?? s.code,
          isSource: true,
          detail: [
            if (s.name != null) s.code,
            ?tree.byId[s.villageId]?.name,
          ].join(' · '),
        ),
    ];
    final points = [for (final d in dots) LatLng(d.lat, d.lon)];
    // Lines go from the device to the nearest points of concern.
    final concerns = me == null
        ? const <MapPoint>[]
        : ([
                for (final d in dots)
                  if (_severityRank(d.status) <= 1) d,
              ]..sort(
                (a, b) => metresBetween(
                  me,
                  LatLng(a.lat, a.lon),
                ).compareTo(metresBetween(me, LatLng(b.lat, b.lon))),
              ))
              .take(5)
              .toList();
    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          // Not keyed on the focus: choosing a place flies there instead.
          key: ValueKey(Object.hash(Object.hashAll(points), home)),
          options: MapOptions(
            crs: const NoRepeatCrs(),
            interactionOptions: mapInteraction,
            initialCenter: focus != null
                ? LatLng(focus.lat, focus.lon)
                : points.length == 1
                ? points.single
                : LatLng(home.lat, home.lon),
            // 13: close enough for the source, wide enough for nearby
            // village names and roads (rural areas look empty at 14).
            initialZoom: focus != null || points.length == 1 ? 13 : home.zoom,
            initialCameraFit: focus == null && points.length > 1
                ? CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.fromLTRB(48, 80, 48, 110),
                    maxZoom: 14,
                  )
                : null,
            minZoom: 5,
            maxZoom: 19,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            // A long press (or right-click) adds a place (ADR-028).
            onLongPress: (_, p) => _addPlace(p, tree),
            onSecondaryTap: (_, p) => _addPlace(p, tree),
            // Moving the map by hand stops following the device.
            onPositionChanged: (_, byHand) {
              if (byHand && (trip?.follow ?? false)) trip!.setFollow(false);
            },
          ),
          children: [
            if (tiles.available)
              TileLayer(
                urlTemplate: tiles.urlTemplate,
                tileProvider: tiles.provider,
                maxNativeZoom: 18,
                userAgentPackageName: 'org.watercheck.console',
              ),
            if (trip?.route case final r?)
              RouteLayer(route: r)
            else if (_layers.route &&
                _route != null &&
                target != null &&
                trip == null)
              RouteLayer(route: _route!),
            if (trip != null) TrackLayer(fixes: trip.track),
            if (_layers.lines && me != null && trip == null)
              target != null
                  ? StraightLinesLayer(from: me, to: [target.at])
                  : _DistanceLines(from: me, to: concerns),
            _Dots(
              points: dots,
              labels: _layers.labels,
              pulseId: focus?.id ?? issue?.point.id,
            ),
            if (trip?.here case final h?)
              MarkerLayer(
                markers: [
                  Marker(
                    point: h,
                    width: 22,
                    height: 22,
                    child: HereMarker(headingDeg: trip!.last?.headingDeg),
                  ),
                ],
              )
            else if (me != null)
              _YouAreHere(at: me),
            if (_pin case final pin?)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(pin.lat!, pin.lon!),
                    width: 200,
                    height: 64,
                    alignment: const Alignment(0, -0.6),
                    child: Tooltip(
                      message: [pin.name, ?pin.detail].join(' · '),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(blurRadius: 3, color: Colors.black26),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              child: Text(
                                pin.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Icon(Icons.location_pin, size: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (widget.overlay != null)
          Positioned(top: 12, left: 12, child: widget.overlay!),
        // One search for areas and sources; the path to what was chosen,
        // and its distance and route from here.
        Positioned(
          top: widget.overlay == null ? 8 : (isPhone(context) ? 56 : 68),
          left: 8,
          right: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MapSearchBar(
                places: places,
                online: (t) => _searchOnline(t, tree),
                onSelected: (p) => _choose(p, tree),
              ),
              if (path.isNotEmpty || chosenSource != null) ...[
                const SizedBox(height: 6),
                // Folded on phones: the last step; a tap shows the rest.
                MapPathBar(
                  items: [
                    for (final u in path)
                      MapPathItem(
                        label: u.name,
                        onTap: () => _choose(
                          MapPlace(id: u.id, name: u.name, isSource: false),
                          tree,
                        ),
                      ),
                    if (chosenSource != null)
                      MapPathItem(
                        label: chosenSource.name ?? chosenSource.code,
                        icon: Icons.water_drop,
                        onTap: () => context.go('/sources/${chosenSource.id}'),
                      ),
                  ],
                ),
              ],
              if (target != null && trip == null) ...[
                const SizedBox(height: 6),
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 2, 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: isPhone(context)
                                ? Theme.of(context).textTheme.labelSmall
                                : null,
                            [
                              if (pin?.addedBy case final by?
                                  when focusAt == null)
                                UiKitLocalizations.of(context).placeAddedBy(by),
                              if (me != null)
                                distanceSummary(
                                  UiKitLocalizations.of(context),
                                  straight: metresBetween(me, target.at),
                                  route: _layers.route ? _route : null,
                                  mode: _layers.mode,
                                  routeWanted: _layers.route,
                                  routeLoading: _routeLoading,
                                )
                              else
                                target.name,
                            ].join(' · '),
                          ),
                        ),
                        Tooltip(
                          message: UiKitLocalizations.of(context).tripGoTooltip,
                          child: TextButton.icon(
                            onPressed: () => _go(target.at, target.name),
                            icon: const Icon(Icons.navigation, size: 16),
                            label: Text(UiKitLocalizations.of(context).tripGo),
                          ),
                        ),
                        if (isAdmin &&
                            focusAt == null &&
                            pin?.addedBy != null) ...[
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: l10n.mapPlaceRename,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _renamePin(pin!),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: l10n.mapPlaceRemove,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => _removePin(pin!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Column(
            children: [
              _MapButton(
                tooltip: me == null ? l10n.mapNoLocation : l10n.mapLocateMe,
                icon: me == null ? Icons.location_disabled : Icons.my_location,
                onPressed: me == null
                    ? () => ref.invalidate(deviceLocationProvider)
                    : () => _map.move(me, 14),
              ),
              const SizedBox(height: 6),
              MapNavigationButtons(motion: _motion),
              const SizedBox(height: 6),
              MapLayersButton(
                layers: _layers,
                onChanged: (v) => setState(() {
                  if (v.mode != _layers.mode) _routeKey = null;
                  _layers = v;
                }),
              ),
            ],
          ),
        ),
        // The map credit (ODbL), small, above the issue card.
        if (tiles.available)
          Positioned(
            right: 12,
            bottom: issue == null ? 4 : (isPhone(context) ? 52 : 96),
            child: _Credit(text: '© ${l10n.mapAttribution}'),
          ),
        if (trip != null)
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: LiveTripPanel(trip: trip, onStop: _stop),
          )
        else if (issue != null)
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: IssueCallout(issue: issue, from: me),
          ),
      ],
    );
  }
}

class _Credit extends StatelessWidget {
  const _Credit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    ),
  );
}

/// Dashboard card: only the latest issue, pulsing, and the line from this
/// device to it. Tapping opens Sources › Map on that point.
class IssueMapCard extends ConsumerWidget {
  const IssueMapCard({super.key, required this.issue});

  final MapIssue? issue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tiles = ref.watch(mapTilesProvider).value ?? MapTiles.none;
    final me = ref.watch(deviceLocationProvider).value;
    final issue = this.issue;
    void open() {
      ref.read(mapFocusProvider.notifier).focus(issue?.point.id);
      ref.read(sourcesQueryProvider.notifier).map(true);
      context.go('/sources');
    }

    final at = issue == null ? null : LatLng(issue.point.lat, issue.point.lon);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              l10n.mapLatestIssue,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: TextButton.icon(
              onPressed: open,
              icon: const Icon(Icons.open_in_full),
              label: Text(l10n.mapOpenMap),
            ),
          ),
          if (issue == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.mapNoIssue),
            )
          else
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  FlutterMap(
                    key: ValueKey(issue.point.id),
                    options: MapOptions(
                      crs: const NoRepeatCrs(),
                      initialCameraFit: me == null
                          ? null
                          : CameraFit.coordinates(
                              coordinates: [at!, me],
                              padding: const EdgeInsets.fromLTRB(
                                48,
                                48,
                                48,
                                110,
                              ),
                              maxZoom: 14,
                            ),
                      initialCenter: at!,
                      initialZoom: 13,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                      onTap: (_, _) => open(),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                    children: [
                      if (tiles.available)
                        TileLayer(
                          urlTemplate: tiles.urlTemplate,
                          tileProvider: tiles.provider,
                          maxNativeZoom: 18,
                          userAgentPackageName: 'org.watercheck.console',
                        ),
                      if (me != null)
                        _DistanceLines(from: me, to: [issue.point]),
                      _Dots(
                        points: [issue.point],
                        labels: true,
                        pulseId: issue.point.id,
                        onTap: (_) => open(),
                      ),
                      if (me != null) _YouAreHere(at: me),
                    ],
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: IssueCallout(issue: issue, from: me),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The issue card over the map: what, how serious, how far, when.
class IssueCallout extends StatefulWidget {
  const IssueCallout({super.key, required this.issue, this.from});

  final MapIssue issue;
  final LatLng? from;

  @override
  State<IssueCallout> createState() => _IssueCalloutState();
}

/// On phones the latest issue is a one-line strip, opened on a tap
/// (2026-10-25), so the map keeps the screen.
class _IssueCalloutState extends State<IssueCallout> {
  bool? _open;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final issue = widget.issue;
    final from = widget.from;
    final color = severityColor(context, issue.severity);
    final s = issue.point;
    final far = from == null
        ? null
        : formatDistance(metresBetween(from, LatLng(s.lat, s.lon)));
    final open = _open ?? false;
    if (!open) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _open = true),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: color, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${triggerText(l10n, issue.rule)}: ${s.name ?? s.code}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelMedium,
                    ),
                  ),
                  Icon(
                    Icons.expand_less,
                    size: 18,
                    semanticLabel: UiKitLocalizations.of(context).mapMore,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/sources/${s.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(Icons.warning_amber_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${triggerText(l10n, issue.rule)}: ${s.name ?? s.code}',
                          style: text.titleSmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.mapSeverity(issue.severity),
                            style: text.labelMedium?.copyWith(color: color),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      [
                        s.code,
                        if (far != null) l10n.mapAway(far),
                        l10n.mapAgo(_ago(l10n, issue.at)),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.info_outline, semanticLabel: l10n.mapOpenSource),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: UiKitLocalizations.of(context).mapLess,
                icon: const Icon(Icons.expand_more),
                onPressed: () => setState(() => _open = false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _ago(AppLocalizations l10n, DateTime at) {
    final d = DateTime.now().toUtc().difference(at.toUtc());
    if (d.inDays >= 2) return l10n.durationDays(d.inDays);
    if (d.inHours >= 1) return l10n.durationHours(d.inHours);
    return l10n.durationMinutes(math.max(1, d.inMinutes));
  }
}

/// Dashed lines from this device to points of concern, with distances.
class _DistanceLines extends StatelessWidget {
  const _DistanceLines({required this.from, required this.to});

  final LatLng from;
  final List<MapPoint> to;

  @override
  Widget build(BuildContext context) {
    final ends = [for (final s in to) (s, LatLng(s.lat, s.lon))];
    return Stack(
      children: [
        PolylineLayer(
          polylines: [
            for (final (s, p) in ends)
              Polyline(
                points: [from, p],
                color: statusColor(context, s.status),
                strokeWidth: 2.5,
                pattern: StrokePattern.dashed(segments: const [10, 8]),
              ),
          ],
        ),
        MarkerLayer(
          markers: [
            for (final (_, p) in ends)
              Marker(
                point: LatLng(
                  (from.latitude + p.latitude) / 2,
                  (from.longitude + p.longitude) / 2,
                ),
                width: 90,
                height: 28,
                child: Center(
                  child: _Chip(text: formatDistance(metresBetween(from, p))),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _YouAreHere extends StatelessWidget {
  const _YouAreHere({required this.at});

  final LatLng at;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final blue = Theme.of(context).colorScheme.primary;
    return MarkerLayer(
      markers: [
        Marker(
          point: at,
          width: 28,
          height: 28,
          child: Tooltip(
            message: l10n.mapYouAreHere,
            child: Container(
              decoration: BoxDecoration(
                color: blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: blue.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Source dots, merged into counted clusters when zoomed out.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.points,
    required this.labels,
    this.pulseId,
    this.onTap,
  });

  final List<MapPoint> points;
  final bool labels;
  final String? pulseId;
  final void Function(MapPoint)? onTap;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final controller = MapController.maybeOf(context);
    final markers = <Marker>[];
    if (camera.zoom < _clusterBelowZoom && points.length > 1) {
      // Group by a 64-pixel screen grid.
      final cells = <(int, int), List<MapPoint>>{};
      for (final s in points) {
        final o = camera.getOffsetFromOrigin(LatLng(s.lat, s.lon));
        (cells[(o.dx ~/ 64, o.dy ~/ 64)] ??= []).add(s);
      }
      for (final group in cells.values) {
        if (group.length == 1 || group.any((s) => s.id == pulseId)) {
          markers.addAll(group.map(_dot));
          continue;
        }
        final worst = group
            .map((s) => s.status)
            .reduce((a, b) => _severityRank(a) <= _severityRank(b) ? a : b);
        final pts = [for (final s in group) LatLng(s.lat, s.lon)];
        markers.add(
          Marker(
            point: LatLng(
              pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length,
              pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length,
            ),
            width: 48,
            height: 48,
            child: _Cluster(
              count: group.length,
              status: worst,
              onTap: () => controller?.fitCamera(
                CameraFit.coordinates(
                  coordinates: pts,
                  padding: const EdgeInsets.all(64),
                ),
              ),
            ),
          ),
        );
      }
    } else {
      markers.addAll(points.map(_dot));
    }
    final showLabels = labels && camera.zoom >= _labelsFromZoom;
    return MarkerLayer(
      markers: [
        ...markers,
        if (showLabels)
          for (final s in points)
            Marker(
              point: LatLng(s.lat, s.lon),
              width: 180,
              height: 80,
              alignment: Alignment.topCenter,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _Chip(
                    text:
                        '${s.name ?? s.code} · ${statusWord(AppLocalizations.of(context), s.status)}',
                    dot: statusColor(context, s.status),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Marker _dot(MapPoint s) => Marker(
    point: LatLng(s.lat, s.lon),
    width: 44,
    height: 44,
    child: _Dot(point: s, pulse: s.id == pulseId, onTap: onTap),
  );
}

class _Dot extends StatefulWidget {
  const _Dot({required this.point, required this.pulse, this.onTap});

  final MapPoint point;
  final bool pulse;
  final void Function(MapPoint)? onTap;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _pulse.repeat();
  }

  @override
  void didUpdateWidget(_Dot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_pulse.isAnimating) _pulse.repeat();
    if (!widget.pulse) _pulse.stop();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = widget.point;
    final color = statusColor(context, s.status);
    final word = statusWord(l10n, s.status);
    return Semantics(
      button: true,
      label: '${s.name ?? s.code}, $word',
      child: Tooltip(
        message: '${s.code} · $word',
        child: InkResponse(
          radius: 22,
          onTap: () => widget.onTap != null
              ? widget.onTap!(s)
              : context.go('/sources/${s.id}'),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                if (widget.pulse)
                  Container(
                    width: 16 + 28 * _pulse.value,
                    height: 16 + 28 * _pulse.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.45 * (1 - _pulse.value)),
                    ),
                  ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Cluster extends StatelessWidget {
  const _Cluster({
    required this.count,
    required this.status,
    required this.onTap,
  });

  final int count;
  final MapStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = statusColor(context, status);
    return Semantics(
      button: true,
      label: l10n.mapCluster(count),
      child: InkResponse(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
            ],
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.dot});

  final String text;
  final Color? dot;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 2,
    borderRadius: BorderRadius.circular(8),
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Icon(Icons.circle, size: 10, color: dot),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 3,
    borderRadius: BorderRadius.circular(12),
    color: Theme.of(context).colorScheme.surface,
    child: IconButton(tooltip: tooltip, icon: Icon(icon), onPressed: onPressed),
  );
}
