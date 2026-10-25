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
import '../location/location_service.dart';
import '../sources/online_search.dart';
import '../sources/source_providers.dart';
import '../sources/source_status.dart';
import '../sync/refresh_button.dart';
import 'map_tiles.dart';

/// Open alerts on this device, for the notices at the bottom of the map.
final _openAlertsProvider = StreamProvider<List<AlertListItem>>(
  (ref) => ref.watch(alertRepositoryProvider).watchList(),
);

/// The map in Collect (ADR-019 slice B, ADR-021): the sources on this phone
/// by status over the labelled map of Uganda. One search finds any area
/// (including places added from phones) or source; the map flies there.
/// [areaId] or [sourceId] (from the address) say what is chosen, and
/// [placeId] a name on the map in that area (ADR-023), pinned; the path
/// above it reads Uganda › region › district › … › source. Layers: source
/// names, straight-line distances from here, and the road route to the
/// chosen source, place or area by motorbike/car or on foot (ADR-028).
/// "Go" follows the device there live and keeps the trip (ADR-029); a long
/// press adds a place missing from the map.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, this.areaId, this.sourceId, this.placeId});

  final String? areaId;
  final String? sourceId;
  final String? placeId;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final _map = MapController();
  late final _motion = MapMotion(_map, this);
  final _sheet = DraggableScrollableController();

  /// Wide screens: the list beside the map, closed until asked for.
  var _listOpen = false;

  /// "You are here", kept current while the map is open (2026-10-25).
  StreamSubscription<GeoFix>? _hereFixes;

  /// Places found online and chosen, not (yet) on this device.
  final _online = <String, MapName>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hereFixes = ref.read(liveLocationProvider).watch().listen(
        (f) {
          if (mounted) setState(() => _here = LatLng(f.lat, f.lon));
        },
        // Location off or refused: the locate button still asks.
        onError: (Object _) {},
      );
    });
  }

  /// Live navigation (ADR-029): the trip, its fixes and its stored record.
  LiveTrip? _trip;
  StreamSubscription<GeoFix>? _fixes;
  String? _tripId;
  var _tripEnded = false;
  var _layers = const MapLayers();
  LatLng? _here;
  var _locating = false;
  MapRoute? _route;
  String? _routeKey;

  /// The name on the map in the address (ADR-023), if any.
  MapName? _place() => widget.placeId == null
      ? null
      : (ref.read(mapNamesProvider).value ?? const <MapName>[])
                .where((m) => m.id == widget.placeId)
                .firstOrNull ??
            _online[widget.placeId];

  /// Places anywhere in Uganda from the server, for the search box.
  Future<List<MapPlace>> _searchOnline(String text, AreaTree tree) async {
    final ui = UiKitLocalizations.of(context);
    final hits = await ref.read(onlinePlaceSearchProvider)(text);
    return [
      for (final h in hits)
        if (h.lat != null &&
            h.lon != null &&
            h.subcountyId != null &&
            tree.byId[h.subcountyId] != null &&
            // Areas on this device are already in the local list.
            tree.byId[h.id] == null)
          MapPlace(
            id: h.id,
            name: h.name,
            isSource: false,
            fromMap: true,
            lat: h.lat,
            lon: h.lon,
            areaId: h.subcountyId,
            addedBy: h.addedBy,
            detail: [
              if (h.addedBy case final by?) ui.placeAddedBy(by),
              ?tree.byId[h.subcountyId]?.name,
              ?tree.byId[tree.byId[h.subcountyId]?.parentId]?.name,
            ].join(' · '),
          ),
    ];
  }

  var _routeLoading = false;

  @override
  void didUpdateWidget(MapScreen old) {
    super.didUpdateWidget(old);
    if (old.areaId != widget.areaId ||
        old.sourceId != widget.sourceId ||
        old.placeId != widget.placeId) {
      _route = null;
      _routeKey = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _flyToChoice());
    }
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

  /// Follows the device to [to] live, keeping the trip on this phone.
  Future<void> _go(LatLng to, String name) async {
    await _stop();
    final trips = ref.read(tripRepositoryProvider);
    final mode = _layers.mode;
    final api = ref.read(credentialsProvider)?.apiUrl ?? defaultApiUrl();
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
            if (trip.follow) {
              _map.move(at, math.max(_map.camera.zoom, 15));
            }
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

  /// Arrival ends the stored trip at once; the panel stays until Done.
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

  /// Adds a place missing from the map at [at] (ADR-028): in the sub-county
  /// of the nearest known name or area centre; the server sets the real one.
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
    context.go('/map?area=$sub&place=${place.id}');
  }

  /// The sub-county whose centre is nearest [at], within about 15 km.
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

  /// A tap on the sheet's handle opens the list halfway, or folds it back.
  void _toggleSheet() {
    if (!_sheet.isAttached) return;
    _sheet.animateTo(
      _sheet.size > 0.3 ? 0.12 : 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
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
    // A name on the map: the point itself, in its sub-county.
    final place = _place();
    if (place != null) return _motion.moveTo(LatLng(place.lat, place.lon), 15);
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
    final alerts = ref.watch(_openAlertsProvider).value ?? const [];
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
    // Where routes and "Go" lead (ADR-028): the chosen source, else the
    // named place, else the chosen area's centre (sub-county and below).
    final pinned = _place();
    final target = chosenAt != null
        ? (at: chosenAt, name: chosen!.source.name ?? chosen.source.code)
        : pinned != null
        ? (at: LatLng(pinned.lat, pinned.lon), name: pinned.name)
        : area != null &&
              const {'subcounty', 'parish', 'village'}.contains(area.level) &&
              centre != null
        ? (at: LatLng(centre.lat, centre.lon), name: area.name)
        : null;
    final trip = _trip;
    if (target != null && trip == null) _ensureRoute(target.at);

    // Straight lines: to what is chosen, else to the 5 nearest sources.
    final here = _here;
    const distance = Distance();
    final lineTargets = here == null || !_layers.lines || trip != null
        ? const <LatLng>[]
        : target != null
        ? [target.at]
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
      for (final m in ref.watch(mapNamesProvider).value ?? const <MapName>[])
        MapPlace(
          id: m.id,
          name: m.name,
          isSource: false,
          fromMap: true,
          lat: m.lat,
          lon: m.lon,
          areaId: m.subcountyId,
          detail: [
            if (m.addedBy case final by?) ui.placeAddedBy(by),
            l10n.mapOnMap(
              [
                ?tree.byId[m.subcountyId]?.name,
                ?tree.byId[tree.byId[m.subcountyId]?.parentId]?.name,
              ].join(', '),
            ),
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
            interactionOptions: mapInteraction,
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
            // A long press (or right-click) adds a place (ADR-028).
            onLongPress: (_, p) => _addPlace(p, tree),
            onSecondaryTap: (_, p) => _addPlace(p, tree),
            // Moving the map by hand stops following the device.
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
            if (trip?.route case final r?)
              RouteLayer(route: r)
            else if (_layers.route && _route != null && trip == null)
              RouteLayer(route: _route!),
            if (trip != null) TrackLayer(fixes: trip.track),
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
                if (_place() case final pin?)
                  Marker(
                    point: LatLng(pin.lat, pin.lon),
                    width: 180,
                    height: 64,
                    alignment: const Alignment(0, -0.6),
                    child: Tooltip(
                      message: pin.name,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PinLabel(pin.name),
                          const Icon(Icons.location_pin, size: 32),
                        ],
                      ),
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
              MapSearchBar(
                places: places,
                online: (t) => _searchOnline(t, tree),
                onSelected: (p) {
                  if (p.fromMap) {
                    // Found online: kept so the pin shows (ADR-028).
                    _online[p.id] = (
                      id: p.id,
                      name: p.name,
                      kind: 'place',
                      lat: p.lat!,
                      lon: p.lon!,
                      subcountyId: p.areaId!,
                      addedBy: p.addedBy,
                    );
                    // Its sub-county is chosen (the path and the list
                    // follow); the map goes to the named point.
                    context.go('/map?area=${p.areaId}&place=${p.id}');
                    return;
                  }
                  context.go(
                    p.isSource ? '/map?source=${p.id}' : '/map?area=${p.id}',
                  );
                },
              ),
              // The path to what is chosen, folded on phones (2026-10-25).
              if (path.isNotEmpty || chosen != null) ...[
                const SizedBox(height: 6),
                MapPathBar(
                  items: [
                    MapPathItem(
                      label: l10n.mapAllAreas,
                      icon: Icons.public,
                      onTap: () => context.go('/map'),
                    ),
                    for (final u in path)
                      MapPathItem(
                        label: '${u.name} (${areaLevelText(l10n, u.level)})',
                        onTap: () => context.go('/map?area=${u.id}'),
                      ),
                    if (chosen != null)
                      MapPathItem(
                        label: chosen.source.name ?? chosen.source.code,
                        icon: Icons.water_drop,
                        onTap: () =>
                            context.push('/sources/${chosen.source.id}'),
                      ),
                  ],
                ),
              ],
              if (trip != null) ...[
                const SizedBox(height: 6),
                LiveTripPanel(trip: trip, onStop: _stop),
              ] else if (target != null || chosen != null) ...[
                const SizedBox(height: 6),
                _TargetBar(
                  line: [
                    if (chosen == null && pinned?.addedBy != null)
                      ui.placeAddedBy(pinned!.addedBy!),
                    if (target == null)
                      l10n.mapNoLocation
                    else if (here == null)
                      l10n.mapLocateForDistance
                    else
                      distanceSummary(
                        ui,
                        straight: distance(here, target.at),
                        route: _layers.route ? _route : null,
                        mode: _layers.mode,
                        routeWanted: _layers.route,
                        routeLoading: _routeLoading,
                      ),
                  ].join(' · '),
                  onGo: target == null
                      ? null
                      : () => _go(target.at, target.name),
                  onOpen: chosen == null
                      ? null
                      : () => context.push('/sources/${chosen.source.id}'),
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
              if (MediaQuery.sizeOf(context).width > 760) ...[
                const SizedBox(height: 6),
                Material(
                  elevation: 2,
                  shape: const CircleBorder(),
                  color: Theme.of(context).colorScheme.surface,
                  child: IconButton(
                    tooltip: _listOpen ? l10n.mapListHide : l10n.mapListShow,
                    icon: Icon(_listOpen ? Icons.close_fullscreen : Icons.list),
                    onPressed: () => setState(() => _listOpen = !_listOpen),
                  ),
                ),
              ],
            ],
          ),
        ),
        // The bottom is for notices about sources: open alerts, newest first.
        if (alerts.isNotEmpty)
          Positioned(
            left: 8,
            right: 8,
            // Phones: above the peeking list.
            bottom: isPhone(context) ? 92 : 12,
            child: _AlertNotices(alerts: alerts),
          ),
      ],
    );

    Widget list([ScrollController? scroll]) => ListView(
      controller: scroll,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (scroll != null)
          // The sheet's handle: drag up for the list, or tap it.
          Tooltip(
            message: UiKitLocalizations.of(context).mapMore,
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
            // Wide: the map fills the screen; the list opens beside it, a
            // share of the width (2026-10-25).
            ? Row(
                children: [
                  Expanded(child: map),
                  if (_listOpen)
                    SizedBox(
                      width: box.maxWidth * 0.3,
                      child: Material(elevation: 2, child: list()),
                    ),
                ],
              )
            // Narrower: the map keeps the whole screen; the list is a
            // sheet that peeks from the bottom and is pulled up (2026-10-25).
            : Stack(
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

/// What is chosen, under the search: distance and route, "Go" and the
/// way into a source (ADR-028).
class _TargetBar extends StatelessWidget {
  const _TargetBar({required this.line, this.onGo, this.onOpen});

  final String line;
  final VoidCallback? onGo;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 2, 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                line,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: isPhone(context)
                    ? Theme.of(context).textTheme.labelSmall
                    : null,
              ),
            ),
            if (onGo != null)
              Tooltip(
                message: ui.tripGoTooltip,
                child: TextButton.icon(
                  onPressed: onGo,
                  icon: const Icon(Icons.navigation, size: 16),
                  label: Text(ui.tripGo),
                ),
              ),
            if (onOpen != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l10n.mapOpenSource,
                icon: const Icon(Icons.open_in_new, size: 18),
                onPressed: onOpen,
              ),
          ],
        ),
      ),
    );
  }
}

/// Open alerts on this device, one line each (newest first, three at
/// most): a tap shows the source on the map; the arrow opens the alert.
class _AlertNotices extends StatelessWidget {
  const _AlertNotices({required this.alerts});

  final List<AlertListItem> alerts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colours = Theme.of(context).extension<StatusColors>()!;
    final text = Theme.of(context).textTheme;
    final shown = alerts.take(3).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in shown)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.go('/map?source=${a.sourceId}'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 2, 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: a.severity == 'high' || a.severity == 'critical'
                            ? colours.unsafe
                            : colours.due,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          (a.triggerRule == 'unsafe' || a.triggerRule == 'ecoli'
                              ? l10n.mapAlertUnsafe
                              : l10n.mapAlertOther)(
                            a.sourceName ?? a.sourceCode,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelMedium,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: l10n.mapAlertOpen,
                        icon: const Icon(Icons.chevron_right, size: 18),
                        onPressed: () => context.push('/alerts/${a.id}'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (alerts.length > shown.length)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              l10n.mapAlertsMore(alerts.length - shown.length),
              style: text.labelSmall,
            ),
          ),
      ],
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

/// The name over a searched place's pin.
class _PinLabel extends StatelessWidget {
  const _PinLabel(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(6),
      boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black26)],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    ),
  );
}
