import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/ui_kit_localizations.dart';
import 'map_route.dart';

/// Something the map search finds: an area (any level, including places
/// added from phones) or a water source.
class MapPlace {
  const MapPlace({
    required this.id,
    required this.name,
    required this.isSource,
    this.detail,
    this.fromMap = false,
    this.lat,
    this.lon,
    this.areaId,
  });

  final String id;
  final String name;
  final bool isSource;

  /// Where it is ("Butagaya · Jinja") or its level and code.
  final String? detail;

  /// A name on the map (ADR-023), not an official area or a source: picked,
  /// the map goes to [lat]/[lon], in the sub-county [areaId].
  final bool fromMap;
  final double? lat;
  final double? lon;
  final String? areaId;
}

/// One search box for areas and sources (2026-10-22): typing narrows both;
/// names starting with the text come first.
class MapSearchBar extends StatelessWidget {
  const MapSearchBar({
    super.key,
    required this.places,
    required this.onSelected,
    this.width = 360,
  });

  final List<MapPlace> places;
  final ValueChanged<MapPlace> onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return SizedBox(
      width: width,
      child: Autocomplete<MapPlace>(
        displayStringForOption: (p) => p.name,
        optionsBuilder: (v) {
          final q = v.text.trim().toLowerCase();
          if (q.length < 2) return const [];
          final hits = [
            for (final p in places)
              if (p.name.toLowerCase().contains(q) ||
                  (p.detail ?? '').toLowerCase().contains(q))
                p,
          ];
          int rank(MapPlace p) => p.name.toLowerCase().startsWith(q) ? 0 : 1;
          hits.sort((a, b) {
            final r = rank(a) - rank(b);
            return r != 0 ? r : a.name.compareTo(b.name);
          });
          return hits.take(30);
        },
        onSelected: (p) {
          FocusManager.instance.primaryFocus?.unfocus();
          onSelected(p);
        },
        fieldViewBuilder: (context, controller, focus, submit) => Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(28),
          child: TextField(
            controller: controller,
            focusNode: focus,
            onSubmitted: (_) => submit(),
            decoration: InputDecoration(
              hintText: l10n.mapSearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: l10n.refSearchClear,
                icon: const Icon(Icons.clear),
                onPressed: controller.clear,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        optionsViewBuilder: (context, select, options) => Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 360, maxWidth: width),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final p in options)
                    ListTile(
                      dense: true,
                      leading: Icon(
                        p.isSource
                            ? Icons.water_drop_outlined
                            : p.fromMap
                            ? Icons.signpost_outlined
                            : Icons.place,
                      ),
                      title: Text(p.name),
                      subtitle: p.detail == null ? null : Text(p.detail!),
                      onTap: () => select(p),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the map draws on top of the sources.
class MapLayers {
  const MapLayers({
    this.labels = true,
    this.lines = true,
    this.route = false,
    this.mode = TravelMode.vehicle,
  });

  /// Source names under the dots.
  final bool labels;

  /// Straight lines with distances from where you are.
  final bool lines;

  /// The road route to the chosen source, with distance and time.
  final bool route;
  final TravelMode mode;

  MapLayers copyWith({
    bool? labels,
    bool? lines,
    bool? route,
    TravelMode? mode,
  }) => MapLayers(
    labels: labels ?? this.labels,
    lines: lines ?? this.lines,
    route: route ?? this.route,
    mode: mode ?? this.mode,
  );
}

/// The layers menu: labels, straight-line distance, road route, and how
/// the route is travelled.
class MapLayersButton extends StatelessWidget {
  const MapLayersButton({
    super.key,
    required this.layers,
    required this.onChanged,
  });

  final MapLayers layers;
  final ValueChanged<MapLayers> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Material(
      elevation: 3,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: l10n.mapLayers,
        icon: const Icon(Icons.layers_outlined),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheet) => StatefulBuilder(
            builder: (sheet, setSheet) {
              var current = layers;
              void set(MapLayers next) {
                current = next;
                onChanged(next);
                setSheet(() {});
              }

              return SafeArea(
                child: _LayersBody(layers: current, onChanged: set),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LayersBody extends StatefulWidget {
  const _LayersBody({required this.layers, required this.onChanged});

  final MapLayers layers;
  final ValueChanged<MapLayers> onChanged;

  @override
  State<_LayersBody> createState() => _LayersBodyState();
}

class _LayersBodyState extends State<_LayersBody> {
  late var _l = widget.layers;

  void _set(MapLayers next) {
    setState(() => _l = next);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            value: _l.labels,
            title: Text(l10n.mapLabels),
            onChanged: (v) => _set(_l.copyWith(labels: v)),
          ),
          SwitchListTile(
            value: _l.lines,
            title: Text(l10n.mapStraight),
            subtitle: Text(l10n.mapStraightHint),
            onChanged: (v) => _set(_l.copyWith(lines: v)),
          ),
          SwitchListTile(
            value: _l.route,
            title: Text(l10n.mapRoute),
            subtitle: Text(l10n.mapRouteHint),
            onChanged: (v) => _set(_l.copyWith(route: v)),
          ),
          const SizedBox(height: 8),
          SegmentedButton<TravelMode>(
            segments: [
              ButtonSegment(
                value: TravelMode.vehicle,
                icon: const Icon(Icons.two_wheeler),
                label: Text(l10n.mapVehicle),
              ),
              ButtonSegment(
                value: TravelMode.foot,
                icon: const Icon(Icons.directions_walk),
                label: Text(l10n.mapWalking),
              ),
            ],
            selected: {_l.mode},
            onSelectionChanged: (s) => _set(_l.copyWith(mode: s.single)),
          ),
        ],
      ),
    );
  }
}

/// Straight lines from [from] to each of [to], with their lengths.
class StraightLinesLayer extends StatelessWidget {
  const StraightLinesLayer({super.key, required this.from, required this.to});

  final LatLng from;
  final List<LatLng> to;

  @override
  Widget build(BuildContext context) {
    final colour = Theme.of(context).colorScheme.primary;
    const distance = Distance();
    return Stack(
      children: [
        PolylineLayer(
          polylines: [
            for (final p in to)
              Polyline(
                points: [from, p],
                color: colour.withValues(alpha: 0.7),
                strokeWidth: 2,
                pattern: StrokePattern.dashed(segments: const [8, 6]),
              ),
          ],
        ),
        MarkerLayer(
          markers: [
            for (final p in to)
              Marker(
                point: LatLng(
                  (from.latitude + p.latitude) / 2,
                  (from.longitude + p.longitude) / 2,
                ),
                width: 72,
                height: 22,
                child: _Tag(formatMetres(distance(from, p))),
              ),
          ],
        ),
      ],
    );
  }
}

/// The road route, drawn under the dots.
class RouteLayer extends StatelessWidget {
  const RouteLayer({super.key, required this.route});

  final MapRoute route;

  @override
  Widget build(BuildContext context) => PolylineLayer(
    polylines: [
      Polyline(
        points: route.points,
        color: Theme.of(context).colorScheme.tertiary,
        strokeWidth: 5,
        borderColor: Colors.white,
        borderStrokeWidth: 2,
      ),
    ],
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(text, style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );
  }
}

/// "3.2 km straight · 4.8 km by road · 12 min (motorbike/car)".
String distanceSummary(
  UiKitLocalizations l10n, {
  required double straight,
  MapRoute? route,
  required TravelMode mode,
  bool routeWanted = false,
  bool routeLoading = false,
}) => [
  l10n.mapStraightLine(formatMetres(straight)),
  if (route != null)
    l10n.mapByRoad(
      formatMetres(route.metres),
      formatSeconds(route.seconds),
      mode == TravelMode.vehicle ? l10n.mapVehicle : l10n.mapWalking,
    )
  else if (routeWanted)
    routeLoading ? l10n.mapRouteLoading : l10n.mapRouteNone,
].join(' · ');
