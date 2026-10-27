import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';

import '../../l10n/app_localizations.dart';
import '../map/map_tiles.dart';
import 'research.dart';

/// Where this tester's research records were made (ADR-030): each point by
/// its research number, never a name, so the collector can confirm their
/// own visits. A search finds a number.
class ResearchMapScreen extends ConsumerStatefulWidget {
  const ResearchMapScreen({super.key});

  @override
  ConsumerState<ResearchMapScreen> createState() => _ResearchMapScreenState();
}

class _ResearchMapScreenState extends ConsumerState<ResearchMapScreen>
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
    final l10n = AppLocalizations.of(context);
    final template = ref.watch(mapTemplateProvider).value;
    final records = [
      for (final r
          in ref.watch(researchRecordsProvider).value ??
              const <ResearchRecordItem>[])
        if (r.lat != null && r.lon != null) r,
    ];
    final points = [for (final r in records) LatLng(r.lat!, r.lon!)];
    final colour = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.researchMap)),
      body: Stack(
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
            ),
            children: [
              if (template != null)
                TileLayer(
                  urlTemplate: template,
                  maxNativeZoom: 18,
                  userAgentPackageName: 'org.watercheck.collect',
                ),
              MarkerLayer(
                markers: [
                  for (final r in records)
                    Marker(
                      point: LatLng(r.lat!, r.lon!),
                      width: 140,
                      height: 44,
                      alignment: const Alignment(0, 0.4),
                      child: GestureDetector(
                        onTap: () => context.push('/research/record/${r.id}'),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_ind, color: colour, size: 22),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  r.number,
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
            child: MapSearchBar(
              places: [
                for (final r in records)
                  MapPlace(
                    id: r.id,
                    name: r.number,
                    isSource: false,
                    fromMap: true,
                    lat: r.lat,
                    lon: r.lon,
                    detail: r.formTitle,
                  ),
              ],
              onSelected: (p) => _motion.moveTo(LatLng(p.lat!, p.lon!), 17),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: MapNavigationButtons(motion: _motion),
          ),
          if (records.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(l10n.researchMapNone),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
