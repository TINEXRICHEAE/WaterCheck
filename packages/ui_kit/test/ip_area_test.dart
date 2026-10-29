import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';

void main() {
  test('a point set by hand stays inside the rough area (2026-10-28)', () {
    const area = IpArea(centre: LatLng(0.3136, 32.5811), radiusM: 25000);
    const near = LatLng(0.35, 32.6);
    expect(area.holds(near), isTrue);
    expect(area.clamp(near), near);

    // Far away (Gulu): moved to the circle's edge, towards it.
    const far = LatLng(2.7746, 32.2990);
    expect(area.holds(far), isFalse);
    final kept = area.clamp(far);
    final d = const Distance()(area.centre, kept);
    expect(d, closeTo(25000, 50));
    expect(kept.latitude, greaterThan(area.centre.latitude));
  });
}
