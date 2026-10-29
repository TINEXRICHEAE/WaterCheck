import 'dart:async';
import 'dart:convert';

import 'package:data/data.dart' show defaultApiUrl;
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import 'location_service.dart';

/// Where a computer is (2026-10-29), in this order:
/// 1. a point the person set by hand on the map (anywhere), until they ask
///    for a fresh reading;
/// 2. the computer's own location, always read fresh (never a remembered
///    one), with its age and accuracy shown;
/// 3. only when the computer gives none (blocked or unavailable): a rough
///    guess from the internet connection, labelled as such.
class ComputerPosition {
  const ComputerPosition({
    required this.point,
    required this.source,
    required this.at,
    this.accuracyM,
    this.area,
    this.problem,
  });

  final LatLng point;
  final LocationSource source;

  /// When the reading was taken (or the point set).
  final DateTime at;
  final double? accuracyM;

  /// The internet guess's area, when that is the source.
  final IpArea? area;

  /// Why the computer gave no location of its own, when it did not.
  final String? problem;
}

class ComputerPositionNotifier extends AsyncNotifier<ComputerPosition?> {
  static const _key = 'location.by_hand';

  @override
  Future<ComputerPosition?> build() async {
    if (!deviceHasNoGps) return null;
    final settings = ref.read(localSettingsRepositoryProvider);
    final saved = await settings.read(_key);
    if (saved != null) {
      try {
        final j = jsonDecode(saved) as Map<String, dynamic>;
        return ComputerPosition(
          point: LatLng(
            (j['lat'] as num).toDouble(),
            (j['lon'] as num).toDouble(),
          ),
          source: LocationSource.hand,
          at: DateTime.parse(j['at'] as String),
        );
      } on Object {
        // A broken value: read the computer instead.
      }
    }
    final own = await _own();
    if (own.pos case final pos?) return pos;
    final api = ref.read(credentialsProvider)?.apiUrl ?? defaultApiUrl();
    final area = await IpArea.ask(Dio(BaseOptions(baseUrl: api)));
    if (area == null) return null;
    return ComputerPosition(
      point: area.centre,
      source: LocationSource.internet,
      at: DateTime.now().toUtc(),
      accuracyM: area.radiusM,
      area: area,
      problem: own.problem,
    );
  }

  /// The computer's own location, read fresh. In a browser it is asked
  /// for directly (the browser prompts); a separate permission check
  /// answered wrongly in some browsers. Without one, why: 'denied', 'off',
  /// 'timeout' or 'unavailable' (VS Code's preview gives none at all).
  static Future<({ComputerPosition? pos, String? problem})> _own() async {
    try {
      if (!kIsWeb) {
        if (!await Geolocator.isLocationServiceEnabled()) {
          return (pos: null, problem: 'off');
        }
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return (pos: null, problem: 'denied');
        }
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: kIsWeb
            ? WebSettings(
                accuracy: LocationAccuracy.high,
                maximumAge: Duration.zero,
                timeLimit: const Duration(seconds: 20),
              )
            : const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: Duration(seconds: 20),
              ),
      );
      return (
        pos: ComputerPosition(
          point: LatLng(p.latitude, p.longitude),
          source: LocationSource.device,
          at: p.timestamp.toUtc(),
          accuracyM: p.accuracy > 0 ? p.accuracy : null,
        ),
        problem: null,
      );
    } on PermissionDeniedException {
      return (pos: null, problem: 'denied');
    } on LocationServiceDisabledException {
      return (pos: null, problem: 'off');
    } on TimeoutException {
      return (pos: null, problem: 'timeout');
    } on Object catch (e) {
      final text = '$e';
      return (
        pos: null,
        problem: text.contains('Timeout')
            ? 'timeout'
            : text.contains('denied') || text.contains('ermission')
            ? 'denied'
            : 'unavailable',
      );
    }
  }

  /// Sets the location by hand, anywhere; it stays until [refresh].
  Future<void> place(LatLng p) async {
    final now = DateTime.now().toUtc();
    await ref
        .read(localSettingsRepositoryProvider)
        .write(
          _key,
          jsonEncode({
            'lat': p.latitude,
            'lon': p.longitude,
            'at': now.toIso8601String(),
          }),
        );
    state = AsyncData(
      ComputerPosition(point: p, source: LocationSource.hand, at: now),
    );
  }

  /// Forgets a point set by hand and reads the computer again.
  Future<void> refresh() async {
    await ref.read(localSettingsRepositoryProvider).write(_key, null);
    ref.invalidateSelf();
    await future;
  }
}

final computerPositionProvider =
    AsyncNotifierProvider<ComputerPositionNotifier, ComputerPosition?>(
      ComputerPositionNotifier.new,
    );

/// Location on a computer, as above, for every screen that asks.
class ComputerLocation implements LocationService, LiveLocation {
  ComputerLocation(this._ref);

  final Ref _ref;

  Future<ComputerPosition> _now() async {
    final p = await _ref.read(computerPositionProvider.future);
    if (p == null) {
      throw const LocationException(LocationProblem.unavailable);
    }
    return p;
  }

  GeoFix _fix(ComputerPosition p) => GeoFix(
    lat: p.point.latitude,
    lon: p.point.longitude,
    at: p.at,
    accuracyM: p.accuracyM,
    source: p.source,
  );

  @override
  Future<GeoPoint> currentFix() async => _fix(await _now()).point;

  @override
  Stream<GeoFix> watch() {
    final out = StreamController<GeoFix>();
    final sub = _ref.listen(computerPositionProvider, (_, next) {
      if (next.value case final p?) out.add(_fix(p));
    });
    _now().then((p) => out.add(_fix(p)), onError: out.addError);
    out.onCancel = sub.close;
    return out.stream;
  }

  @override
  Future<GeoFix?> detail({Duration wait = const Duration(seconds: 15)}) async {
    try {
      return _fix(await _now());
    } on Object {
      return null;
    }
  }
}
