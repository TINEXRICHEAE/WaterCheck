import 'dart:math' as math;

import 'entities.dart';

const _earthRadiusM = 6371008.8;

/// Great-circle distance in metres (haversine). Accurate to well under a
/// metre at the 100 m scale of the proximity check (SPEC §3.1 step 4).
double distanceMetres(GeoPoint a, GeoPoint b) {
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLon = rad(b.lon - a.lon);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) *
          math.cos(rad(b.lat)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * _earthRadiusM * math.asin(math.sqrt(h));
}

/// True when [point] is a usable latitude/longitude pair.
bool isValidCoordinate(GeoPoint point) =>
    point.lat >= -90 &&
    point.lat <= 90 &&
    point.lon >= -180 &&
    point.lon <= 180;
