import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';
import 'package:ui_kit/ui_kit.dart';

/// A straight road north along 32.5° E, about 1.1 km long.
const _road = [LatLng(0.300, 32.5), LatLng(0.305, 32.5), LatLng(0.310, 32.5)];
const _target = LatLng(0.310, 32.5);

void main() {
  var now = DateTime.utc(2026, 10, 25, 8);
  GeoFix at(double lat, double lon, {double? speed}) =>
      GeoFix(lat: lat, lon: lon, at: now, speedMps: speed, altitudeM: 1150);

  late List<LatLng> asked;
  late List<GeoFix> kept;
  LiveTrip trip() {
    asked = [];
    kept = [];
    return LiveTrip(
      target: _target,
      targetName: 'Kabojja',
      mode: TravelMode.vehicle,
      clock: () => now,
      onFix: kept.add,
      routeTo: (from, to) async {
        asked.add(from);
        return const MapRoute(points: _road, metres: 1110, seconds: 180);
      },
    );
  }

  test('follows the route, keeps every fix, and arrives', () async {
    final t = trip();
    await t.add(at(0.300, 32.5));
    expect(asked, hasLength(1), reason: 'the first fix fetches the route');
    expect(t.remainingMetres, closeTo(1105, 15));
    expect(t.remainingSeconds, closeTo(180, 5));
    now = now.add(const Duration(minutes: 1));
    await t.add(at(0.305, 32.5001));
    expect(asked, hasLength(1), reason: 'on the route: no new request');
    expect(t.remainingMetres, closeTo(555, 15));
    await t.add(at(0.3099, 32.5));
    expect(t.arrived, isTrue);
    expect(kept, hasLength(3));
    await t.add(at(0.31, 32.5));
    expect(kept, hasLength(3), reason: 'nothing after arrival');
  });

  test(
    'leaving the route fetches it again, not more than every 20 s',
    () async {
      final t = trip();
      await t.add(at(0.300, 32.5));
      // 0.001° east is about 110 m off the road.
      now = now.add(const Duration(seconds: 5));
      await t.add(at(0.302, 32.501));
      expect(t.offRoute, greaterThan(50));
      expect(asked, hasLength(1), reason: 'too soon after the last request');
      now = now.add(const Duration(seconds: 30));
      await t.add(at(0.302, 32.501));
      expect(asked, hasLength(2));
      expect(asked.last.longitude, 32.501);
    },
  );

  testWidgets('the panel shows speed, altitude and what is left', (
    tester,
  ) async {
    final t = trip();
    await t.add(at(0.300, 32.5, speed: 5));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: UiKitLocalizations.localizationsDelegates,
        supportedLocales: UiKitLocalizations.supportedLocales,
        home: Scaffold(
          body: LiveTripPanel(trip: t, onStop: () {}),
        ),
      ),
    );
    expect(find.text('To Kabojja'), findsOneWidget);
    expect(find.textContaining('18 km/h'), findsOneWidget);
    expect(find.textContaining('1,150 m high'), findsOneWidget);
    expect(find.textContaining('1.1 km left'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
  });
}
