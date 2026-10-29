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

/// One GPS fix with what the device knew at that moment (ADR-029): where,
/// how sure, how high, how fast, which way and when. Phones give all of
/// it; a browser often gives no altitude, speed or direction.
class GeoFix {
  const GeoFix({
    required this.lat,
    required this.lon,
    required this.at,
    this.accuracyM,
    this.altitudeM,
    this.speedMps,
    this.headingDeg,
    this.source = LocationSource.device,
  });

  final double lat;
  final double lon;
  final DateTime at;
  final double? accuracyM;
  final double? altitudeM;

  /// Metres per second.
  final double? speedMps;

  /// Degrees clockwise from north.
  final double? headingDeg;

  final LocationSource source;

  GeoPoint get point =>
      GeoPoint(lat: lat, lon: lon, accuracyM: accuracyM, source: source);
}
