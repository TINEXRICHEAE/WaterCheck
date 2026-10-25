import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Why a GPS fix could not be taken; the UI explains each in plain words.
enum LocationProblem { serviceOff, denied, deniedForever, timeout, unavailable }

class LocationException implements Exception {
  const LocationException(this.problem);
  final LocationProblem problem;

  @override
  String toString() => 'LocationException($problem)';
}

/// GPS behind an interface so screens and tests do not depend on a plugin.
abstract interface class LocationService {
  /// A single fix with its accuracy, or throws [LocationException].
  Future<GeoPoint> currentFix();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<GeoPoint> currentFix() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationProblem.serviceOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationProblem.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationProblem.deniedForever);
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 45),
        ),
      );
      return GeoPoint(lat: p.latitude, lon: p.longitude, accuracyM: p.accuracy);
    } on Exception catch (e) {
      throw LocationException(
        e.toString().contains('Timeout')
            ? LocationProblem.timeout
            : LocationProblem.unavailable,
      );
    }
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => const GeolocatorLocationService(),
);

/// Fixes while travelling (live navigation) and the full detail of one fix
/// (pictures), ADR-029.
abstract interface class LiveLocation {
  /// A fix about every 5 m moved; errors when location is off or refused.
  Stream<GeoFix> watch();

  /// The current fix with altitude, speed and direction, waiting at most
  /// [wait]; null when there is none (a picture is kept without one).
  Future<GeoFix?> detail({Duration wait});
}

class GeolocatorLiveLocation implements LiveLocation {
  const GeolocatorLiveLocation();

  static Future<bool> _allowed() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  /// A browser reports what it does not know as 0; a phone as -1 or 0
  /// accuracy. Unknown values become null.
  static GeoFix fixOf(Position p) => GeoFix(
    lat: p.latitude,
    lon: p.longitude,
    at: p.timestamp,
    accuracyM: p.accuracy > 0 ? p.accuracy : null,
    altitudeM: p.altitudeAccuracy > 0 || (!kIsWeb && p.altitude != 0)
        ? p.altitude
        : null,
    speedMps: p.speed >= 0 && (p.speedAccuracy > 0 || !kIsWeb || p.speed > 0)
        ? p.speed
        : null,
    headingDeg: p.heading >= 0 && (p.headingAccuracy > 0 || p.heading > 0)
        ? p.heading
        : null,
  );

  @override
  Stream<GeoFix> watch() async* {
    if (!await _allowed()) {
      throw const LocationException(LocationProblem.denied);
    }
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).map(fixOf);
  }

  @override
  Future<GeoFix?> detail({Duration wait = const Duration(seconds: 15)}) async {
    try {
      if (!await _allowed()) return null;
      final p = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: wait,
        ),
      );
      return fixOf(p);
    } on Object {
      return null;
    }
  }
}

final liveLocationProvider = Provider<LiveLocation>(
  (ref) => const GeolocatorLiveLocation(),
);
