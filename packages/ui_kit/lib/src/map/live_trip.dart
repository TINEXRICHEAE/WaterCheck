import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/ui_kit_localizations.dart';
import 'map_route.dart';

/// Live navigation to a source or place (ADR-029): each fix moves the
/// trip on, the travelled path is kept, the route is fetched again when
/// the device leaves it, and arrival is noticed. No voice.
class LiveTrip extends ChangeNotifier {
  LiveTrip({
    required this.target,
    required this.targetName,
    required this.mode,
    required this.routeTo,
    this.onFix,
    this.offRouteMetres = 50,
    this.arriveMetres = 30,
    this.rerouteEvery = const Duration(seconds: 20),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LatLng target;
  final String targetName;
  final TravelMode mode;

  /// Fetches the road route; null when it cannot.
  final Future<MapRoute?> Function(LatLng from, LatLng to) routeTo;

  /// Called with every fix (Collect keeps them as the trip's track).
  final void Function(GeoFix fix)? onFix;
  final double offRouteMetres;
  final double arriveMetres;
  final Duration rerouteEvery;
  final DateTime Function() _clock;

  final List<GeoFix> track = [];
  MapRoute? route;
  bool arrived = false;
  bool routing = false;

  /// The map keeps the device in view until the person moves it.
  bool follow = true;
  DateTime? _routedAt;
  static const _distance = Distance();

  GeoFix? get last => track.isEmpty ? null : track.last;
  LatLng? get here => last == null ? null : LatLng(last!.lat, last!.lon);

  /// How far the device is from the route's line, in metres.
  double? get offRoute {
    final h = here, r = route;
    if (h == null || r == null || r.points.length < 2) return null;
    return _nearest(h, r.points).$1;
  }

  /// What is left to travel: along the route when there is one.
  double? get remainingMetres {
    final h = here;
    if (h == null) return null;
    final r = route;
    if (r == null || r.points.length < 2) return _distance(h, target);
    final (off, index, t) = _nearest(h, r.points);
    // From the nearest point on that segment to its end, then the rest.
    var left = off + (1 - t) * _distance(r.points[index], r.points[index + 1]);
    for (var i = index + 2; i < r.points.length; i++) {
      left += _distance(r.points[i - 1], r.points[i]);
    }
    return left;
  }

  /// Seconds still to go: the route's own pace, else a typical speed.
  double? get remainingSeconds {
    final left = remainingMetres;
    if (left == null) return null;
    final r = route;
    if (r != null && r.metres > 0) return r.seconds * left / r.metres;
    final pace = mode == TravelMode.vehicle ? 30 / 3.6 : 4.5 / 3.6;
    return left / pace;
  }

  /// Takes the next fix: keeps it, notices arrival, and fetches the route
  /// again when off it (not more often than [rerouteEvery]).
  Future<void> add(GeoFix fix) async {
    if (arrived) return;
    track.add(fix);
    onFix?.call(fix);
    final h = LatLng(fix.lat, fix.lon);
    if (_distance(h, target) <= arriveMetres) {
      arrived = true;
      notifyListeners();
      return;
    }
    notifyListeners();
    final off = offRoute;
    final due =
        _routedAt == null || _clock().difference(_routedAt!) >= rerouteEvery;
    if (!routing && due && (route == null || (off ?? 0) > offRouteMetres)) {
      routing = true;
      _routedAt = _clock();
      notifyListeners();
      final next = await routeTo(h, target);
      routing = false;
      if (next != null) route = next;
      notifyListeners();
    }
  }

  void setFollow(bool on) {
    follow = on;
    notifyListeners();
  }

  /// The distance from [p] to the nearest segment of [line], the index of
  /// that segment's start, and how far along it the nearest point lies
  /// (0–1). Flat-earth: fine over a few hundred metres.
  static (double, int, double) _nearest(LatLng p, List<LatLng> line) {
    final k = math.cos(p.latitude * math.pi / 180);
    (double, double) xy(LatLng q) => (
      (q.longitude - p.longitude) * k * 111320,
      (q.latitude - p.latitude) * 110540,
    );
    var best = double.infinity;
    var at = 0;
    var along = 0.0;
    for (var i = 0; i + 1 < line.length; i++) {
      final (ax, ay) = xy(line[i]);
      final (bx, by) = xy(line[i + 1]);
      final dx = bx - ax, dy = by - ay;
      final len = dx * dx + dy * dy;
      final t = len == 0 ? 0.0 : (-(ax * dx + ay * dy) / len).clamp(0.0, 1.0);
      final cx = ax + t * dx, cy = ay + t * dy;
      final d = math.sqrt(cx * cx + cy * cy);
      if (d < best) {
        best = d;
        at = i;
        along = t;
      }
    }
    return (best, at, along);
  }
}

/// "9 km/h", "1,143 m high", "±6 m", "heading 271° W", "08:30:05": what a
/// fix says, leaving out what the device did not give.
List<String> fixParts(UiKitLocalizations l10n, GeoFix f, {bool time = true}) {
  final n = NumberFormat.decimalPattern();
  return [
    if (f.speedMps case final s?)
      l10n.fixSpeed((s * 3.6).toStringAsFixed(s * 3.6 < 10 ? 1 : 0)),
    if (f.altitudeM case final a?) l10n.fixAltitude(n.format(a.round())),
    if (f.headingDeg case final h?)
      l10n.fixHeading('${h.round()}° ${compassPoint(h)}'),
    if (f.accuracyM case final a?) l10n.fixAccuracy(n.format(a.round())),
    if (time) DateFormat.Hms().format(f.at.toLocal()),
  ];
}

/// N, NE, E… for a heading in degrees.
String compassPoint(double degrees) => const [
  'N',
  'NE',
  'E',
  'SE',
  'S',
  'SW',
  'W',
  'NW',
][((degrees % 360) / 45).round() % 8];

/// Where and when a picture was taken (ADR-029), for under the picture.
String takenText(UiKitLocalizations l10n, GeoFix f) => [
  l10n.photoTaken(DateFormat.yMMMd().add_Hm().format(f.at.toLocal())),
  '${f.lat.toStringAsFixed(5)}, ${f.lon.toStringAsFixed(5)}',
  ...fixParts(l10n, f, time: false),
].join(' · ');

/// The small live panel: where to, the latest fix, distance and arrival
/// time; Stop; and a button to follow the device again.
class LiveTripPanel extends StatelessWidget {
  const LiveTripPanel({super.key, required this.trip, required this.onStop});

  final LiveTrip trip;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: trip,
    builder: (context, _) {
      final l10n = UiKitLocalizations.of(context);
      final text = Theme.of(context).textTheme;
      final scheme = Theme.of(context).colorScheme;
      final fix = trip.last;
      final left = trip.remainingMetres;
      final secs = trip.remainingSeconds;
      final status = trip.arrived
          ? l10n.tripArrived
          : fix == null
          ? l10n.tripWaiting
          : trip.routing
          ? l10n.tripRerouting
          : left == null
          ? ''
          : secs == null
          ? l10n.tripLeftNoTime(formatMetres(left))
          : l10n.tripLeft(
              formatMetres(left),
              DateFormat.Hm().format(
                DateTime.now().add(Duration(seconds: secs.round())),
              ),
              formatSeconds(secs),
            );
      return Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(14),
        color: scheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 4, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    trip.arrived ? Icons.flag : Icons.navigation,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.tripTo(trip.targetName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                  ),
                  if (!trip.follow)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.tripFollow,
                      icon: const Icon(Icons.my_location),
                      onPressed: () => trip.setFollow(true),
                    ),
                  TextButton(
                    onPressed: onStop,
                    child: Text(trip.arrived ? l10n.tripDone : l10n.tripStop),
                  ),
                ],
              ),
              if (status.isNotEmpty)
                Text(
                  status,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: trip.arrived ? scheme.primary : null,
                  ),
                ),
              if (fix != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Text(
                    fixParts(l10n, fix).join(' · '),
                    style: text.labelSmall,
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// The path travelled so far.
class TrackLayer extends StatelessWidget {
  const TrackLayer({super.key, required this.fixes});

  final List<GeoFix> fixes;

  @override
  Widget build(BuildContext context) => PolylineLayer(
    polylines: [
      if (fixes.length > 1)
        Polyline(
          points: [for (final f in fixes) LatLng(f.lat, f.lon)],
          color: Theme.of(context).colorScheme.primary,
          strokeWidth: 4,
          pattern: StrokePattern.dotted(spacingFactor: 1.6),
        ),
    ],
  );
}

/// The device's position, turned to its heading when it has one.
class HereMarker extends StatelessWidget {
  const HereMarker({super.key, this.headingDeg});

  final double? headingDeg;

  @override
  Widget build(BuildContext context) {
    final colour = Theme.of(context).colorScheme.primary;
    final dot = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colour,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: colour.withValues(alpha: 0.4), blurRadius: 8),
        ],
      ),
    );
    final h = headingDeg;
    if (h == null) return dot;
    return Transform.rotate(
      angle: h * math.pi / 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: dot),
          const Align(
            alignment: Alignment.topCenter,
            child: Icon(Icons.navigation, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
