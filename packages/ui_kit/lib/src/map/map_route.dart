import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// How a route is travelled (ADR-021): by motorbike or car by default, or
/// on foot.
enum TravelMode { vehicle, foot }

/// A road route: the line to draw, its length and travel time.
class MapRoute {
  const MapRoute({
    required this.points,
    required this.metres,
    required this.seconds,
  });

  final List<LatLng> points;
  final double metres;
  final double seconds;
}

/// The routing service next to the API: `…/api` → `…/route` (Caddy).
String routingBase(String apiUrl) {
  var root = apiUrl.endsWith('/')
      ? apiUrl.substring(0, apiUrl.length - 1)
      : apiUrl;
  if (root.endsWith('/api')) root = root.substring(0, root.length - 4);
  return '$root/route';
}

/// The shortest route by road (motorbike) or path (walking) between two
/// points from the self-hosted Valhalla service, or null when it cannot be
/// reached or finds no way.
Future<MapRoute?> fetchRoute(
  Dio dio, {
  required String base,
  required TravelMode mode,
  required LatLng from,
  required LatLng to,
}) async {
  final request = {
    'locations': [
      {'lat': from.latitude, 'lon': from.longitude},
      {'lat': to.latitude, 'lon': to.longitude},
    ],
    // Boda bodas are how most trips to a source are made.
    'costing': mode == TravelMode.vehicle ? 'motorcycle' : 'pedestrian',
    'directions_type': 'none',
  };
  try {
    final r = await dio.get<Map<String, dynamic>>(
      '$base/route',
      queryParameters: {'json': jsonEncode(request)},
    );
    final trip = r.data?['trip'] as Map?;
    if (trip == null) return null;
    final summary = trip['summary'] as Map;
    return MapRoute(
      points: [
        for (final leg in (trip['legs'] as List).cast<Map<dynamic, dynamic>>())
          ...decodePolyline6(leg['shape'] as String),
      ],
      metres: (summary['length'] as num).toDouble() * 1000,
      seconds: (summary['time'] as num).toDouble(),
    );
  } catch (_) {
    return null;
  }
}

/// Decodes Valhalla's encoded line (Google polyline, 6 decimals).
List<LatLng> decodePolyline6(String encoded) {
  final points = <LatLng>[];
  var index = 0, lat = 0, lon = 0;
  int next() {
    var result = 0, shift = 0, b = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    // Not `~(result >> 1)`: on the web `~` is unsigned 32-bit, which turned
    // every step south or west into a jump across the world (2026-10-22).
    return (result & 1) != 0 ? -(result >> 1) - 1 : result >> 1;
  }

  while (index < encoded.length) {
    lat += next();
    lon += next();
    points.add(LatLng(lat / 1e6, lon / 1e6));
  }
  return points;
}

/// "850 m", "3.2 km", "41 km".
String formatMetres(double m) => m < 1000
    ? '${m.round()} m'
    : '${(m / 1000).toStringAsFixed(m < 10000 ? 1 : 0)} km';

/// "12 min", "1 h 05 min".
String formatSeconds(double s) {
  final minutes = (s / 60).round();
  if (minutes < 60) return '${minutes < 1 ? 1 : minutes} min';
  return '${minutes ~/ 60} h ${(minutes % 60).toString().padLeft(2, '0')} min';
}
