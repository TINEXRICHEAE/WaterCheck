import 'dart:async';
import 'dart:math' as math;

import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart' show GeoFix;
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
import '../location/ip_map.dart';
import '../location/location_service.dart';
import '../map/map_screen.dart' show MapPinLabel, MapTargetBar, areaLevelText;
import '../map/map_tiles.dart';
import '../sources/online_search.dart';
import '../sync/refresh_button.dart';
import 'research.dart';

/// What is chosen on the research map: a record, a place or an area.
typedef _Target = ({
  LatLng at,
  String name,
  String? recordId,
  String? areaId,
  bool pin,
});

/// The research map (ADR-030), with the water map's tools (2026-10-28):
/// this collector's own records by research number (never a name), every
/// area and place in Uganda to search, layers (labels, straight lines,
/// road route by vehicle or on foot), "Go" with live navigation kept in My
/// trips, the path of the chosen area, a long press to add a missing
/// place, and the records nearby in a list.
class ResearchMapScreen extends ConsumerStatefulWidget {
  const ResearchMapScreen({super.key});

  @override
  ConsumerState<ResearchMapScreen> createState() => _ResearchMapScreenState();
}

class _ResearchMapScreenState extends ConsumerState<ResearchMapScreen>
    with TickerProviderStateMixin {
  final _map = MapController();
  late final _motion = MapMotion(_map, this);
  final _sheet = DraggableScrollableController();

  StreamSubscription<GeoFix>? _hereFixes;
  LatLng? _here;
  var _locating = false;
  var _layers = const MapLayers();
  _Target? _target;
  MapRoute? _route;
  String? _routeKey;
  var _routeLoading = false;

  LiveTrip? _trip;
  StreamSubscription<GeoFix>? _fixes;
  String? _tripId;

  /// A computer's location is being set by hand (2026-10-28).
  var _placing = false;
  var _tripEnded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hereFixes = ref.read(liveLocationProvider).watch().listen((f) {
        if (mounted) setState(() => _here = LatLng(f.lat, f.lon));
      }, onError: (Object _) {});
    });
  }

  @override
  void dispose() {
    unawaited(_hereFixes?.cancel());
    unawaited(_fixes?.cancel());
    if (_tripId case final id? when !_tripEnded) {
      unawaited(
        ref.read(tripRepositoryProvider).end(id, arrived: _trip!.arrived),
      );
    }
    _trip?.dispose();
    _motion.dispose();
    _map.dispose();
    _sheet.dispose();
    super.dispose();
  }

  String get _api => ref.read(credentialsProvider)?.apiUrl ?? defaultApiUrl();

  /// Follows the device to [to] live; the trip goes to My trips.
  Future<void> _go(LatLng to, String name) async {
    await _stop();
    final trips = ref.read(tripRepositoryProvider);
    final mode = _layers.mode;
    final api = _api;
    final id = await trips.start(
      toName: name,
      toLat: to.latitude,
      toLon: to.longitude,
      mode: mode == TravelMode.vehicle ? 'car' : 'foot',
      collectorKey: ref.read(submissionOriginProvider)?.collectorKey,
    );
    final trip = LiveTrip(
      target: to,
      targetName: name,
      mode: mode,
      routeTo: (from, to) => fetchRoute(
        Dio(),
        base: routingBase(api),
        mode: mode,
        from: from,
        to: to,
      ),
      onFix: (f) => unawaited(trips.addFix(id, f)),
    )..addListener(_tripChanged);
    if (!mounted) return;
    setState(() {
      _trip = trip;
      _tripId = id;
      _tripEnded = false;
    });
    _fixes = ref
        .read(liveLocationProvider)
        .watch()
        .listen(
          (f) {
            final at = LatLng(f.lat, f.lon);
            unawaited(trip.add(f));
            if (!mounted) return;
            setState(() => _here = at);
            if (trip.follow) _map.move(at, math.max(_map.camera.zoom, 15));
          },
          onError: (Object e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 10),
                content: Text(
                  locationProblemText(
                    AppLocalizations.of(context),
                    problemOf(e),
                  ),
                ),
              ),
            );
            unawaited(_stop());
          },
        );
  }

  void _tripChanged() {
    final trip = _trip, id = _tripId;
    if (trip != null && id != null && trip.arrived && !_tripEnded) {
      _tripEnded = true;
      unawaited(_fixes?.cancel());
      unawaited(ref.read(tripRepositoryProvider).end(id, arrived: true));
    }
    if (mounted) setState(() {});
  }

  Future<void> _stop() async {
    await _fixes?.cancel();
    _fixes = null;
    final trip = _trip, id = _tripId;
    if (id != null && !_tripEnded) {
      await ref.read(tripRepositoryProvider).end(id, arrived: false);
    }
    trip?.dispose();
    if (mounted) {
      setState(() {
        _trip = null;
        _tripId = null;
        _tripEnded = false;
      });
    }
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

  void _setLayers(MapLayers next) {
    final modeChanged = next.mode != _layers.mode;
    setState(() {
      _layers = next;
      if (modeChanged) _routeKey = null;
    });
    if ((next.lines || next.route) && _here == null) _locate(fly: false);
  }

  void _ensureRoute(LatLng to) {
    final here = _here;
    if (!_layers.route || here == null) return;
    final key = '$to|${_layers.mode}|$here';
    if (key == _routeKey) return;
    _routeKey = key;
    final api = _api;
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

  /// Chooses a record, a place or an area, and flies there.
  void _choose(_Target t, {double? zoom}) {
    setState(() {
      _target = t;
      _route = null;
      _routeKey = null;
    });
    _motion.moveTo(t.at, zoom ?? (t.recordId != null ? 17 : 15));
  }

  void _chooseArea(String id, AreaTree tree) {
    final u = tree.byId[id];
    final c = tree.centre(id);
    if (u == null || c == null) return;
    _choose((
      at: LatLng(c.lat, c.lon),
      name: u.name,
      recordId: null,
      areaId: u.id,
      pin: false,
    ), zoom: AreaTree.zoomFor(u.level));
  }

  /// Places anywhere in Uganda from the server, wherever this phone works.
  Future<List<MapPlace>> _searchOnline(String text, AreaTree tree) async {
    final hits = await ref.read(onlinePlaceSearchProvider)(text);
    return [
      for (final h in hits)
        if (h.lat != null && h.lon != null)
          MapPlace(
            id: h.id,
            name: h.name,
            isSource: false,
            fromMap: true,
            lat: h.lat,
            lon: h.lon,
            areaId: h.subcountyId,
            detail: tree.byId[h.subcountyId]?.name,
          ),
    ];
  }

  /// Adds a place missing from the map (ADR-028), as on the water map.
  Future<void> _addPlace(LatLng at, AreaTree tree) async {
    final ui = UiKitLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final origin = ref.read(submissionOriginProvider);
    if (origin == null) return;
    final repo = MapPlaceRepository(ref.read(databaseProvider));
    final sub =
        await repo.nearestSubcounty(at.latitude, at.longitude) ??
        _nearestSubcounty(at, tree);
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
      origin: origin,
    );
    ref.invalidate(mapNamesProvider);
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(ui.placeAdded(place.name))));
    _choose((at: at, name: place.name, recordId: null, areaId: sub, pin: true));
  }

  static String? _nearestSubcounty(LatLng at, AreaTree tree) {
    const distance = Distance();
    String? best;
    var bestM = 15000.0;
    for (final u in tree.byId.values) {
      if (u.level != 'subcounty') continue;
      final c = tree.centre(u.id);
      if (c == null) continue;
      final m = distance(at, LatLng(c.lat, c.lon));
      if (m < bestM) {
        bestM = m;
        best = u.id;
      }
    }
    return best;
  }

  void _toggleSheet() {
    if (!_sheet.isAttached) return;
    _sheet.animateTo(
      _sheet.size > 0.3 ? 0.12 : 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final units = ref.watch(adminUnitsProvider).value ?? const <AdminUnit>[];
    final tree = AreaTree(units);
    final template = ref.watch(mapTemplateProvider).value;
    final colour = Theme.of(context).colorScheme.primary;
    final records = [
      for (final r
          in ref.watch(researchRecordsProvider).value ??
              const <ResearchRecordItem>[])
        if (r.lat != null && r.lon != null) r,
    ];
    final points = [for (final r in records) LatLng(r.lat!, r.lon!)];
    final here = _here;
    final trip = _trip;
    final target = _target;
    if (target != null && trip == null) _ensureRoute(target.at);
    const distance = Distance();
    final lineTargets = here == null || !_layers.lines || trip != null
        ? const <LatLng>[]
        : target != null
        ? [target.at]
        : ([
                ...points,
              ]..sort((a, b) => distance(here, a).compareTo(distance(here, b))))
              .take(5)
              .toList();
    final path = target?.areaId == null
        ? const <AdminUnit>[]
        : [
            for (final u in tree.pathTo(target!.areaId!))
              if (u.level != 'country') u,
          ];
    final nearby = [...records]
      ..sort((a, b) {
        if (here == null) {
          return (b.finishedAt ?? DateTime(0)).compareTo(
            a.finishedAt ?? DateTime(0),
          );
        }
        return distance(
          here,
          LatLng(a.lat!, a.lon!),
        ).compareTo(distance(here, LatLng(b.lat!, b.lon!)));
      });

    final map = Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            crs: const NoRepeatCrs(),
            interactionOptions: mapInteraction,
            initialCenter: points.isEmpty
                ? const LatLng(1.37, 32.29)
                : points.first,
            initialZoom: points.isEmpty ? 7 : 15,
            initialCameraFit: points.length > 1
                ? CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.all(48),
                    maxZoom: 17,
                  )
                : null,
            minZoom: 5,
            maxZoom: 19,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            onTap: (_, p) {
              if (!_placing) return;
              setState(() => _placing = false);
              placeHere(context, ref, p);
            },
            onLongPress: (_, p) => _addPlace(p, tree),
            onSecondaryTap: (_, p) => _addPlace(p, tree),
            onPositionChanged: (_, byHand) {
              if (byHand && (trip?.follow ?? false)) trip!.setFollow(false);
            },
          ),
          children: [
            if (template != null)
              TileLayer(
                urlTemplate: template,
                maxNativeZoom: 18,
                userAgentPackageName: 'org.watercheck.collect',
              ),
            ?ipAreaLayer(ref),
            if (trip?.route case final r?)
              RouteLayer(route: r)
            else if (_layers.route && _route != null && trip == null)
              RouteLayer(route: _route!),
            if (trip != null) TrackLayer(fixes: trip.track),
            if (here != null && lineTargets.isNotEmpty)
              StraightLinesLayer(from: here, to: lineTargets),
            MarkerLayer(
              markers: [
                for (final r in records)
                  Marker(
                    point: LatLng(r.lat!, r.lon!),
                    width: _layers.labels ? 140 : 30,
                    height: _layers.labels ? 44 : 30,
                    alignment: _layers.labels
                        ? const Alignment(0, 0.4)
                        : Alignment.center,
                    child: Tooltip(
                      message: '${r.number} · ${r.formTitle}',
                      child: GestureDetector(
                        onTap: () => _choose((
                          at: LatLng(r.lat!, r.lon!),
                          name: r.number,
                          recordId: r.id,
                          areaId: null,
                          pin: false,
                        )),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.assignment_ind,
                              color: target?.recordId == r.id
                                  ? Theme.of(context).colorScheme.tertiary
                                  : colour,
                              size: 22,
                            ),
                            if (_layers.labels) MapPinLabel(r.number),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (target case final t? when t.pin)
                  Marker(
                    point: t.at,
                    width: 180,
                    height: 64,
                    alignment: const Alignment(0, -0.6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MapPinLabel(t.name),
                        const Icon(Icons.location_pin, size: 32),
                      ],
                    ),
                  ),
                if (here != null)
                  Marker(
                    point: here,
                    width: 22,
                    height: 22,
                    child: HereMarker(headingDeg: trip?.last?.headingDeg),
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
          top: 8,
          left: 8,
          right: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This collector's own records, and every area and place in
              // Uganda.
              MapSearchBar(
                history: 'collect.research.map',
                places: [
                  for (final r in records)
                    MapPlace(
                      id: r.id,
                      name: r.number,
                      isSource: false,
                      fromMap: true,
                      icon: Icons.assignment_outlined,
                      lat: r.lat,
                      lon: r.lon,
                      detail: r.formTitle,
                    ),
                  for (final u in units)
                    if (u.level != 'country')
                      MapPlace(
                        id: u.id,
                        name: u.name,
                        isSource: false,
                        detail: [
                          areaLevelText(l10n, u.level),
                          for (final p in tree.pathTo(u.id).reversed.skip(1))
                            if (p.level != 'country' && p.level != 'region')
                              p.name,
                        ].join(' · '),
                      ),
                  for (final m
                      in ref.watch(mapNamesProvider).value ?? const <MapName>[])
                    MapPlace(
                      id: m.id,
                      name: m.name,
                      isSource: false,
                      fromMap: true,
                      lat: m.lat,
                      lon: m.lon,
                      areaId: m.subcountyId,
                      detail: tree.byId[m.subcountyId]?.name,
                    ),
                ],
                online: (t) => _searchOnline(t, tree),
                onSelected: (p) {
                  final record = p.icon == Icons.assignment_outlined;
                  if (p.lat != null && p.lon != null) {
                    _choose((
                      at: LatLng(p.lat!, p.lon!),
                      name: p.name,
                      recordId: record ? p.id : null,
                      areaId: p.areaId,
                      pin: !record,
                    ));
                  } else {
                    _chooseArea(p.id, tree);
                  }
                },
              ),
              if (deviceHasNoGps) ...[
                const SizedBox(height: 6),
                IpPlaceBar(
                  placing: _placing,
                  onPlacing: (v) => setState(() => _placing = v),
                ),
              ],
              if (path.isNotEmpty || target != null) ...[
                const SizedBox(height: 6),
                MapPathBar(
                  items: [
                    MapPathItem(
                      label: l10n.mapAllAreas,
                      icon: Icons.public,
                      onTap: () => setState(() => _target = null),
                    ),
                    for (final u in path)
                      MapPathItem(
                        label: '${u.name} (${areaLevelText(l10n, u.level)})',
                        onTap: () => _chooseArea(u.id, tree),
                      ),
                    if (target != null && target.areaId != target.recordId)
                      if (target.recordId != null || target.pin)
                        MapPathItem(
                          label: target.name,
                          icon: target.recordId != null
                              ? Icons.assignment_ind
                              : Icons.location_pin,
                          onTap: () => _motion.moveTo(target.at, 17),
                        ),
                  ],
                ),
              ],
              if (trip != null) ...[
                const SizedBox(height: 6),
                LiveTripPanel(trip: trip, onStop: _stop),
              ] else if (target != null) ...[
                const SizedBox(height: 6),
                MapTargetBar(
                  line: here == null
                      ? l10n.mapLocateForDistance
                      : distanceSummary(
                          ui,
                          straight: distance(here, target.at),
                          route: _layers.route ? _route : null,
                          mode: _layers.mode,
                          routeWanted: _layers.route,
                          routeLoading: _routeLoading,
                        ),
                  onGo: () => _go(target.at, target.name),
                  openTooltip: l10n.researchOpenRecord,
                  onClose: () => setState(() => _target = null),
                  onOpen: target.recordId == null
                      ? null
                      : () =>
                            context.push('/research/record/${target.recordId}'),
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
              MapLayersButton(layers: _layers, onChanged: _setLayers),
              const SizedBox(height: 6),
              MapNavigationButtons(motion: _motion),
            ],
          ),
        ),
      ],
    );

    Widget list(ScrollController scroll) => ListView(
      controller: scroll,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Tooltip(
          message: ui.mapMore,
          child: InkWell(
            onTap: _toggleSheet,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            l10n.researchMineCount(records.length),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (records.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.researchMapNone),
          ),
        for (final r in nearby)
          ListTile(
            selected: target?.recordId == r.id,
            leading: const Icon(Icons.assignment_ind),
            title: Text(r.number),
            subtitle: Text(
              [
                r.formTitle,
                if (here != null)
                  formatMetres(distance(here, LatLng(r.lat!, r.lon!))),
              ].join(' · '),
            ),
            trailing: IconButton(
              tooltip: l10n.researchOpenRecord,
              icon: const Icon(Icons.open_in_new),
              onPressed: () => context.push('/research/record/${r.id}'),
            ),
            onTap: () => _choose((
              at: LatLng(r.lat!, r.lon!),
              name: r.number,
              recordId: r.id,
              areaId: null,
              pin: false,
            )),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(target?.name ?? l10n.researchMap),
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
          IconButton(
            tooltip: l10n.tripsTitle,
            icon: const Icon(Icons.route),
            onPressed: () => context.push('/research/profile/trips'),
          ),
          const SyncRefreshButton(),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: map),
          DraggableScrollableSheet(
            controller: _sheet,
            initialChildSize: 0.12,
            minChildSize: 0.08,
            maxChildSize: 0.85,
            snap: true,
            snapSizes: const [0.12, 0.5],
            builder: (context, scroll) => Material(
              elevation: 6,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: list(scroll),
            ),
          ),
        ],
      ),
    );
  }
}
