import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:ui_kit/map_kit.dart' show deviceHasNoGps;

import '../../l10n/app_localizations.dart';
import 'ip_location.dart';

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
    try {
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
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 45),
        ),
      );
      return GeoPoint(lat: p.latitude, lon: p.longitude, accuracyM: p.accuracy);
    } on Object catch (e) {
      throw LocationException(problemOf(e));
    }
  }
}

/// Why a location call failed. A browser refusing (or a phone's location
/// switched off for it) arrives as a plugin error, not as a permission
/// state; each becomes the reason the screen explains (2026-10-25).
LocationProblem problemOf(Object e) => switch (e) {
  LocationException(:final problem) => problem,
  PermissionDeniedException() => LocationProblem.denied,
  LocationServiceDisabledException() => LocationProblem.serviceOff,
  TimeoutException() => LocationProblem.timeout,
  _ when e.toString().contains('Timeout') => LocationProblem.timeout,
  _ => LocationProblem.unavailable,
};

/// The reason in plain words; in a browser, where to allow location.
String locationProblemText(AppLocalizations l10n, LocationProblem p) =>
    switch (p) {
      LocationProblem.serviceOff =>
        kIsWeb ? l10n.locationOffWeb : l10n.locationServiceOff,
      LocationProblem.denied =>
        kIsWeb ? l10n.locationBlockedWeb : l10n.locationDenied,
      LocationProblem.deniedForever =>
        kIsWeb ? l10n.locationBlockedWeb : l10n.locationDeniedForever,
      LocationProblem.timeout => l10n.locationTimeout,
      LocationProblem.unavailable => l10n.locationUnavailable,
    };

/// Computers: their own location read fresh, else the internet
/// connection's guess, or a point set by hand (2026-10-29).
///
/// connection, set more closely by hand (2026-10-28).
final locationServiceProvider = Provider<LocationService>(
  (ref) => deviceHasNoGps
      ? ComputerLocation(ref)
      : const GeolocatorLocationService(),
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
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return false;
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      return p == LocationPermission.always ||
          p == LocationPermission.whileInUse;
    } on Object {
      return false;
    }
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
      throw LocationException(
        await Geolocator.isLocationServiceEnabled().catchError((_) => true)
            ? LocationProblem.denied
            : LocationProblem.serviceOff,
      );
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
  (ref) =>
      deviceHasNoGps ? ComputerLocation(ref) : const GeolocatorLiveLocation(),
);
