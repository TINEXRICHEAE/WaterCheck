import 'package:api_client/api_client.dart' show PointOut;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';

import '../map/map_tiles.dart';

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

class _PointsMapState extends ConsumerState<PointsMap>
    with TickerProviderStateMixin {
  final _map = MapController();
  late final _motion = MapMotion(_map, this);

  @override
  void dispose() {
    _motion.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = ref.watch(mapTilesProvider).value ?? MapTiles.none;
    final at = [
      for (final p in widget.points) LatLng(p.lat.toDouble(), p.lon.toDouble()),
    ];
    final codes = {for (final p in widget.points) p.formCode}.toList()..sort();
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
          ),
          children: [
            if (tiles.available)
              TileLayer(
                urlTemplate: tiles.urlTemplate,
                tileProvider: tiles.provider,
                maxNativeZoom: 18,
                userAgentPackageName: 'org.watercheck.console',
              ),
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
              ],
            ),
          ],
        ),
        if (widget.interactive)
          Positioned(
            top: 8,
            left: 8,
            right: 60,
            child: MapSearchBar(
              places: [
                for (final p in widget.points)
                  MapPlace(
                    id: p.id,
                    name: p.number,
                    isSource: false,
                    fromMap: true,
                    lat: p.lat.toDouble(),
                    lon: p.lon.toDouble(),
                    detail: [p.formCode, ?p.collector].join(' · '),
                  ),
              ],
              onSelected: (p) => _motion.moveTo(LatLng(p.lat!, p.lon!), 18),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: MapNavigationButtons(motion: _motion),
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
