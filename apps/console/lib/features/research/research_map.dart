import '../map/device_location.dart';
import '../map/ip_location.dart';

import 'package:ui_kit/ui_kit.dart';
import 'package:domain/domain.dart' show GeoFix;
import 'package:dio/dio.dart';

import 'dart:math' as math;
import 'dart:async';

import 'package:api_client/api_client.dart' show PointOut;
import 'package:data/data.dart' show AdminUnit, AreaTree, defaultApiUrl;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';

import '../../l10n/app_localizations.dart';
import '../map/map_tiles.dart';
import '../map/sources_map.dart'
    show
        areaPlaces,
        mapAreasProvider,
        mapNamePlacesProvider,
        searchPlacesOnline;

/// One colour per form, the same on every map and legend.
Color formColour(BuildContext context, String formCode, List<String> codes) {
  const palette = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFAD1457),
    Color(0xFFEF6C00),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFF5D4037),
  ];
  final i = codes.indexOf(formCode);
  return i < 0
      ? Theme.of(context).colorScheme.primary
      : palette[i % palette.length];
}

/// The points of interview, by research number (never a name), coloured
/// by form; a search finds a number, a tap opens the record. Floating
/// controls as on the water map.
class PointsMap extends ConsumerStatefulWidget {
  const PointsMap({
    super.key,
    required this.points,
    this.overlay,
    this.interactive = true,
  });

  final List<PointOut> points;

  /// Shown at the bottom left (the list/map toggle).
  final Widget? overlay;

  /// False for a small preview: no search, no gestures but zoom buttons.
  final bool interactive;

  @override
  ConsumerState<PointsMap> createState() => _PointsMapState();
}

typedef _Target = ({LatLng at, String name, String? recordId, bool pin});

class _PointsMapState extends ConsumerState<PointsMap>
    with TickerProviderStateMixin {
  final _map = MapController();
  late final _motion = MapMotion(_map, this);

  // The water map's tools on research too (2026-10-28): layers, road
  // route, straight lines and "Go" with live navigation.
  var _layers = const MapLayers();
  _Target? _target;
  MapRoute? _route;
  String? _routeKey;
  var _routeLoading = false;
  LiveTrip? _trip;
  StreamSubscription<GeoFix>? _fixes;

  /// This computer's location is being set by hand (2026-10-28).
  var _placing = false;

  void _choose(_Target t, double zoom) {
    setState(() {
      _target = t;
      _route = null;
      _routeKey = null;
    });
    _motion.moveTo(t.at, zoom);
  }

  /// A point close up; a place where it is; an area around its centre.
  void _go(MapPlace p, AreaTree tree) {
    if (p.lat != null && p.lon != null) {
      final point = p.icon == Icons.assignment_outlined;
      _choose((
        at: LatLng(p.lat!, p.lon!),
        name: p.name,
        recordId: point ? p.id : null,
        pin: !point,
      ), point ? 18 : 15);
      return;
    }
    final c = tree.centre(p.id);
    final u = tree.byId[p.id];
    if (c != null && u != null) {
      _choose((
        at: LatLng(c.lat, c.lon),
        name: u.name,
        recordId: null,
        pin: false,
      ), AreaTree.zoomFor(u.level));
    }
  }

  Future<void> _travel(LatLng to, String name) async {
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
  void dispose() {
    unawaited(_fixes?.cancel());
    _trip?.dispose();
    _motion.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = ref.watch(mapTilesProvider).value ?? MapTiles.none;
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final units = widget.interactive
        ? ref.watch(mapAreasProvider).value ?? const <AdminUnit>[]
        : const <AdminUnit>[];
    final tree = AreaTree(units);
    final at = [
      for (final p in widget.points) LatLng(p.lat.toDouble(), p.lon.toDouble()),
    ];
    final codes = {for (final p in widget.points) p.formCode}.toList()..sort();
    final me = widget.interactive
        ? ref.watch(deviceLocationProvider).value
        : null;
    final target = _target;
    final trip = _trip;
    if (me != null && target != null && trip == null) {
      _ensureRoute(me, target.at);
    }
    const distance = Distance();
    final lines = me == null || !_layers.lines || trip != null
        ? const <LatLng>[]
        : target != null
        ? [target.at]
        : ([...at]..sort((a, b) => distance(me, a).compareTo(distance(me, b))))
              .take(5)
              .toList();
    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            crs: const NoRepeatCrs(),
            interactionOptions: mapInteraction,
            initialCenter: at.isEmpty ? const LatLng(1.37, 32.29) : at.first,
            initialZoom: at.isEmpty ? 7 : 15,
            initialCameraFit: at.length > 1
                ? CameraFit.coordinates(
                    coordinates: at,
                    padding: const EdgeInsets.all(48),
                    maxZoom: 17,
                  )
                : null,
            minZoom: 5,
            maxZoom: 19,
            onPositionChanged: (_, byHand) {
              if (byHand && (trip?.follow ?? false)) trip!.setFollow(false);
            },
            onTap: (_, p) {
              if (!_placing) return;
              setState(() => _placing = false);
              placeHere(context, ref, p);
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
            if (widget.interactive) ?ipAreaLayer(ref),
            if (trip?.route case final r?)
              RouteLayer(route: r)
            else if (_layers.route && _route != null && trip == null)
              RouteLayer(route: _route!),
            if (trip != null) TrackLayer(fixes: trip.track),
            if (me != null && lines.isNotEmpty)
              StraightLinesLayer(from: me, to: lines),
            MarkerLayer(
              markers: [
                for (final p in widget.points)
                  Marker(
                    point: LatLng(p.lat.toDouble(), p.lon.toDouble()),
                    width: 150,
                    height: 46,
                    alignment: const Alignment(0, 0.4),
                    child: _Pin(
                      point: p,
                      colour: formColour(context, p.formCode, codes),
                    ),
                  ),
                if (target case final t? when t.pin)
                  Marker(
                    point: t.at,
                    width: 32,
                    height: 32,
                    alignment: const Alignment(0, -0.6),
                    child: Tooltip(
                      message: t.name,
                      child: const Icon(Icons.location_pin, size: 32),
                    ),
                  ),
                if (me != null)
                  Marker(
                    point: me,
                    width: 22,
                    height: 22,
                    child: HereMarker(headingDeg: trip?.last?.headingDeg),
                  ),
              ],
            ),
          ],
        ),
        if (widget.interactive)
          Positioned(
            top: 8,
            left: 8,
            right: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only the points this account may see come from the
                // server; every area and place in Uganda can be searched
                // (2026-10-27).
                MapSearchBar(
                  history: 'console.research.map',
                  places: [
                    for (final p in widget.points)
                      MapPlace(
                        id: p.id,
                        name: p.number,
                        isSource: false,
                        fromMap: true,
                        icon: Icons.assignment_outlined,
                        lat: p.lat.toDouble(),
                        lon: p.lon.toDouble(),
                        detail: [p.formCode, ?p.collector].join(' · '),
                      ),
                    ...areaPlaces(l10n, units, tree),
                    ...?ref.watch(mapNamePlacesProvider).value,
                  ],
                  online: (t) => searchPlacesOnline(context, ref, t, tree),
                  onSelected: (p) => _go(p, tree),
                ),
                if (deviceHasNoGps) ...[
                  const SizedBox(height: 6),
                  IpPlaceBar(
                    placing: _placing,
                    onPlacing: (v) => setState(() => _placing = v),
                  ),
                ],
                if (trip != null) ...[
                  const SizedBox(height: 6),
                  LiveTripPanel(trip: trip, onStop: _stop),
                ] else if (target != null) ...[
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
                              [
                                target.name,
                                if (me != null)
                                  distanceSummary(
                                    ui,
                                    straight: distance(me, target.at),
                                    route: _layers.route ? _route : null,
                                    mode: _layers.mode,
                                    routeWanted: _layers.route,
                                    routeLoading: _routeLoading,
                                  ),
                              ].join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Tooltip(
                            message: ui.tripGoTooltip,
                            child: TextButton.icon(
                              onPressed: () => _travel(target.at, target.name),
                              icon: const Icon(Icons.navigation, size: 16),
                              label: Text(ui.tripGo),
                            ),
                          ),
                          if (target.recordId case final id?)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: l10n.researchOpenRecord,
                              icon: const Icon(Icons.open_in_new, size: 18),
                              onPressed: () =>
                                  context.go('/research/records/$id'),
                            ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: MaterialLocalizations.of(context)
                                .closeButtonTooltip,
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _target = null),
                          ),
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
              if (widget.interactive) ...[
                Material(
                  elevation: 2,
                  shape: const CircleBorder(),
                  color: Theme.of(context).colorScheme.surface,
                  child: IconButton(
                    tooltip: me == null ? l10n.mapNoLocation : l10n.mapLocateMe,
                    icon: Icon(
                      me == null ? Icons.location_disabled : Icons.my_location,
                    ),
                    onPressed: me == null
                        ? () {
                            ref.invalidate(deviceLocationProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 10),
                                content: Text(l10n.mapLocationHelp),
                              ),
                            );
                          }
                        : () => _motion.moveTo(me, 14),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              MapNavigationButtons(motion: _motion),
              if (widget.interactive) ...[
                const SizedBox(height: 6),
                MapLayersButton(
                  layers: _layers,
                  onChanged: (v) => setState(() {
                    if (v.mode != _layers.mode) _routeKey = null;
                    _layers = v;
                  }),
                ),
              ],
            ],
          ),
        ),
        if (codes.length > 1)
          Positioned(
            right: 8,
            bottom: 8,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in codes)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: formColour(context, c, codes),
                          ),
                          const SizedBox(width: 6),
                          Text(c),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.overlay != null)
          Positioned(left: 8, bottom: 8, child: widget.overlay!),
      ],
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.point, required this.colour});

  final PointOut point;
  final Color colour;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: [point.number, point.formCode, ?point.collector].join(' · '),
    child: GestureDetector(
      onTap: () => context.go('/research/records/${point.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: colour, size: 26),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colour),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                point.number,
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
