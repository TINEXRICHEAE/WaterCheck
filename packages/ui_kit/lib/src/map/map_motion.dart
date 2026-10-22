import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Moves a map smoothly to a place or around a set of places, so a search
/// visibly flies there (2026-10-22).
class MapMotion {
  MapMotion(this.controller, TickerProvider vsync)
    : _anim = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 700),
      );

  final MapController controller;
  final AnimationController _anim;

  void dispose() => _anim.dispose();

  /// Flies to [to] at [zoom].
  Future<void> moveTo(LatLng to, double zoom) async {
    final MapCamera from;
    try {
      from = controller.camera;
    } catch (_) {
      return; // The map is not on screen yet.
    }
    final lat = Tween(begin: from.center.latitude, end: to.latitude);
    final lon = Tween(begin: from.center.longitude, end: to.longitude);
    // Across the country: out a little, then in, which is easier to follow.
    // Nearby: straight there.
    final km = const Distance().as(LengthUnit.Kilometer, from.center, to);
    final far = km > 20
        ? math.min(math.min(from.zoom, zoom) - 1, 8.0)
        : math.min(from.zoom, zoom);
    final z = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: from.zoom, end: math.max(far, 5.0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: math.max(far, 5.0), end: zoom),
        weight: 1,
      ),
    ]);
    final curve = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    void step() => controller.move(
      LatLng(lat.evaluate(curve), lon.evaluate(curve)),
      z.evaluate(curve),
    );
    _anim.addListener(step);
    try {
      await _anim.forward(from: 0);
    } finally {
      _anim.removeListener(step);
    }
  }

  /// Flies so that all [points] are in view.
  Future<void> fit(
    List<LatLng> points, {
    EdgeInsets padding = const EdgeInsets.all(48),
    double maxZoom = 15,
  }) async {
    if (points.isEmpty) return;
    if (points.length == 1) return moveTo(points.single, maxZoom);
    final MapCamera camera;
    try {
      camera = controller.camera;
    } catch (_) {
      return;
    }
    final target = CameraFit.coordinates(
      coordinates: points,
      padding: padding,
      maxZoom: maxZoom,
    ).fit(camera);
    return moveTo(target.center, target.zoom);
  }
}
