import 'dart:math' as math;

import 'package:data/data.dart';
import 'package:domain/domain.dart' show GeoFix;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'map_tiles.dart';

final _tripsProvider = StreamProvider.autoDispose<List<TripSummary>>(
  (ref) => ref
      .watch(tripRepositoryProvider)
      .watch(ref.watch(submissionOriginProvider)?.collectorKey),
);

final _fixesProvider = FutureProvider.autoDispose.family<List<GeoFix>, String>(
  (ref, id) => ref.watch(tripRepositoryProvider).fixes(id),
);

/// Totals of a trip's fixes: distance, top speed, lowest and highest point.
({double metres, double? topSpeed, double? low, double? high}) tripTotals(
  List<GeoFix> fixes,
) {
  const distance = Distance();
  var metres = 0.0;
  double? top, low, high;
  for (var i = 0; i < fixes.length; i++) {
    final f = fixes[i];
    if (i > 0) {
      metres += distance(
        LatLng(fixes[i - 1].lat, fixes[i - 1].lon),
        LatLng(f.lat, f.lon),
      );
    }
    if (f.speedMps case final s?) top = math.max(top ?? 0, s);
    if (f.altitudeM case final a?) {
      low = math.min(low ?? a, a);
      high = math.max(high ?? a, a);
    }
  }
  return (metres: metres, topSpeed: top, low: low, high: high);
}

/// Trips this tester followed live (ADR-029), kept on this phone only.
class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final when = DateFormat.yMMMd().add_Hm();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripsTitle)),
      body: switch (ref.watch(_tripsProvider)) {
        AsyncData(:final value) when value.isEmpty => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.tripsNone),
        ),
        AsyncData(:final value) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(l10n.tripsHint),
            ),
            for (final t in value)
              ListTile(
                leading: Icon(t.arrived ? Icons.flag : Icons.route),
                title: Text(t.toName),
                subtitle: Text(
                  [
                    when.format(t.startedAt.toLocal()),
                    if (t.endedAt case final end?)
                      formatSeconds(
                        end.difference(t.startedAt).inSeconds.toDouble(),
                      ),
                    t.arrived ? l10n.tripsArrived : l10n.tripsStopped,
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/trips/${t.id}'),
              ),
          ],
        ),
        AsyncError() => Center(child: Text(l10n.tripsNone)),
        _ => const PageLoading(),
      },
    );
  }
}

/// One trip: its track on the map, and its totals.
class TripScreen extends ConsumerWidget {
  const TripScreen({super.key, required this.tripId});

  final String tripId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final sure = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.tripsDeleteTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(ui.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.tripsDelete),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    await ref.read(tripRepositoryProvider).delete(tripId);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final trip = ref
        .watch(_tripsProvider)
        .value
        ?.where((t) => t.id == tripId)
        .firstOrNull;
    final fixes = ref.watch(_fixesProvider(tripId)).value;
    final template = ref.watch(mapTemplateProvider).value;
    if (trip == null || fixes == null) {
      return const Scaffold(body: PageLoading());
    }
    final totals = tripTotals(fixes);
    final to = LatLng(trip.toLat, trip.toLon);
    final points = [for (final f in fixes) LatLng(f.lat, f.lon)];
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.toName),
        actions: [
          IconButton(
            tooltip: l10n.tripsDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                crs: const NoRepeatCrs(),
                interactionOptions: mapInteraction,
                initialCenter: to,
                initialZoom: 15,
                initialCameraFit: points.isEmpty
                    ? null
                    : CameraFit.coordinates(
                        coordinates: [...points, to],
                        padding: const EdgeInsets.all(40),
                        maxZoom: 17,
                      ),
              ),
              children: [
                if (template != null)
                  TileLayer(
                    urlTemplate: template,
                    maxNativeZoom: 18,
                    userAgentPackageName: 'org.watercheck.collect',
                  ),
                TrackLayer(fixes: fixes),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: to,
                      width: 32,
                      height: 32,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.flag, size: 30),
                    ),
                    if (points.isNotEmpty)
                      Marker(
                        point: points.first,
                        width: 18,
                        height: 18,
                        child: const HereMarker(),
                      ),
                  ],
                ),
                if (template != null)
                  const SimpleAttributionWidget(
                    source: Text('OpenStreetMap contributors'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              [
                formatMetres(totals.metres),
                if (trip.endedAt case final end?)
                  formatSeconds(
                    end.difference(trip.startedAt).inSeconds.toDouble(),
                  ),
                if (totals.topSpeed case final s?)
                  l10n.tripsTopSpeed(ui.fixSpeed((s * 3.6).toStringAsFixed(0))),
                if (totals.low case final low?)
                  l10n.tripsAltitude(
                    low.round().toString(),
                    totals.high!.round().toString(),
                  ),
                trip.arrived ? l10n.tripsArrived : l10n.tripsStopped,
              ].join(' · '),
            ),
          ),
        ],
      ),
    );
  }
}
