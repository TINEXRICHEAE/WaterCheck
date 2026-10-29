import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Computers have no GPS (2026-10-28). Their own location is used, read
/// fresh; only when they give none is it guessed from the internet
/// connection, and the person may set it by hand (2026-10-29).
bool get deviceHasNoGps => const {
  TargetPlatform.windows,
  TargetPlatform.macOS,
  TargetPlatform.linux,
}.contains(defaultTargetPlatform);

/// Roughly where the device is, from its public address: a centre and the
/// circle it may be anywhere in.
class IpArea {
  const IpArea({required this.centre, required this.radiusM, this.place});

  final LatLng centre;
  final double radiusM;

  /// "Kampala, Central Region".
  final String? place;

  static const _distance = Distance();

  bool holds(LatLng p) => _distance(centre, p) <= radiusM;

  /// [p] if it lies in the area, else the nearest point on its edge: a
  /// person cannot place themselves outside it.
  LatLng clamp(LatLng p) {
    final d = _distance(centre, p);
    if (d <= radiusM) return p;
    final bearing = _distance.bearing(centre, p);
    return _distance.offset(centre, radiusM, bearing);
  }

  /// Asks the server (`/v1/places/ip-location`); null when unknown or
  /// offline.
  static Future<IpArea?> ask(Dio dio) async {
    try {
      final r = await dio.get<Map<String, dynamic>>('/v1/places/ip-location');
      final j = r.data!;
      return IpArea(
        centre: LatLng(
          (j['lat'] as num).toDouble(),
          (j['lon'] as num).toDouble(),
        ),
        radiusM: (j['accuracy_m'] as num).toDouble(),
        place: [
          j['city'] as String?,
          j['region'] as String?,
        ].whereType<String>().join(', '),
      );
    } on Object {
      return null;
    }
  }
}

/// The rough area on a map, so the person sees where they may place
/// themselves.
class IpAreaLayer extends StatelessWidget {
  const IpAreaLayer({super.key, required this.area});

  final IpArea area;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return CircleLayer(
      circles: [
        CircleMarker(
          point: area.centre,
          radius: area.radiusM,
          useRadiusInMeter: true,
          color: c.withValues(alpha: 0.06),
          borderColor: c.withValues(alpha: 0.5),
          borderStrokeWidth: 1.5,
        ),
      ],
    );
  }
}
