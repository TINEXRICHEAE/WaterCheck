import 'package:domain/domain.dart' show GeoFix;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Where this device is, for "you are here" and distances on the map,
/// kept current while a page shows it: a fresh, accurate fix (GPS, not a
/// network guess), then a new one every 10 m moved (2026-10-25). Null when
/// location is off, refused or unavailable; the map then shows no
/// distance lines.
final deviceLocationProvider = StreamProvider.autoDispose<LatLng?>((
  ref,
) async* {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      yield null;
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      yield null;
      return;
    }
  } catch (_) {
    yield null;
    return;
  }
  try {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    yield LatLng(p.latitude, p.longitude);
  } catch (_) {
    // No fix yet: the stream below may still give one.
  }
  yield* Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      )
      .map<LatLng?>((p) => LatLng(p.latitude, p.longitude))
      .handleError((Object _) {});
});

/// Fixes while travelling (ADR-029): about every 5 m. Errors when location
/// is off or refused. A browser often gives no altitude, speed or heading
/// (it reports 0); those become null.
final deviceFixesProvider = Provider<Stream<GeoFix> Function()>(
  (ref) => () async* {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('location_off');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw StateError('location_refused');
    }
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).map(
      (p) => GeoFix(
        lat: p.latitude,
        lon: p.longitude,
        at: p.timestamp,
        accuracyM: p.accuracy > 0 ? p.accuracy : null,
        altitudeM: p.altitudeAccuracy > 0 || (!kIsWeb && p.altitude != 0)
            ? p.altitude
            : null,
        speedMps:
            p.speed >= 0 && (p.speedAccuracy > 0 || !kIsWeb || p.speed > 0)
            ? p.speed
            : null,
        headingDeg: p.heading >= 0 && (p.headingAccuracy > 0 || p.heading > 0)
            ? p.heading
            : null,
      ),
    );
  },
);

/// Straight-line distance in metres.
double metresBetween(LatLng a, LatLng b) => const Distance()(a, b);
