import 'dart:async';
import 'dart:convert';

import 'package:data/data.dart' show DriftLocalSettingsRepository;
import 'package:domain/domain.dart' show LocationSource;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';

/// Where a computer is (2026-10-29), in this order: a point the person set
/// by hand (anywhere, until they ask for a fresh reading); the computer's
/// own location, read fresh, with its age and accuracy; only when it gives
/// none, a rough guess from the internet connection.
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
  final DateTime at;
  final double? accuracyM;

  /// The internet guess's area, when that is the source.
  final IpArea? area;

  /// Why the computer gave no location of its own, when it did not.
  final String? problem;
}

class ComputerPositionNotifier extends AsyncNotifier<ComputerPosition?> {
  static const _key = 'location.by_hand';

  DriftLocalSettingsRepository get _settings =>
      DriftLocalSettingsRepository(ref.read(databaseProvider));

  @override
  Future<ComputerPosition?> build() async {
    if (!deviceHasNoGps) return null;
    final saved = await _settings.read(_key);
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
    final area = await IpArea.ask(ref.read(consoleDioProvider));
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
    await _settings.write(
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
    await _settings.write(_key, null);
    ref.invalidateSelf();
    await future;
  }
}

final computerPositionProvider =
    AsyncNotifierProvider<ComputerPositionNotifier, ComputerPosition?>(
      ComputerPositionNotifier.new,
    );

/// Where this computer's location came from, folded to a pill until
/// opened.
class IpPlaceBar extends ConsumerWidget {
  const IpPlaceBar({super.key, required this.placing, required this.onPlacing});

  final bool placing;
  final ValueChanged<bool> onPlacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!deviceHasNoGps) return const SizedBox.shrink();
    final at = ref.watch(computerPositionProvider);
    final p = at.value;
    return ComputerLocationBar(
      source: p?.source.name,
      at: p?.at,
      accuracyM: p?.accuracyM,
      place: p?.area?.place,
      problem: p?.problem,
      loading: at.isLoading,
      placing: placing,
      onPlacing: onPlacing,
      onRefresh: () => ref.read(computerPositionProvider.notifier).refresh(),
    );
  }
}

/// The internet guess's area on the map, while that is the source.
Widget? ipAreaLayer(WidgetRef ref) =>
    switch (ref.watch(computerPositionProvider).value) {
      ComputerPosition(source: LocationSource.internet, :final area?) =>
        IpAreaLayer(area: area),
      _ => null,
    };

/// Sets the computer's location at [at], by hand; says so.
Future<void> placeHere(BuildContext context, WidgetRef ref, LatLng at) async {
  final ui = UiKitLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  await ref.read(computerPositionProvider.notifier).place(at);
  messenger.showSnackBar(SnackBar(content: Text(ui.locSetDone)));
}
