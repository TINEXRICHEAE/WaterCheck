import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/map_kit.dart';

void main() {
  test('routing sits next to the API', () {
    expect(
      routingBase('https://api.example.org/api'),
      'https://api.example.org/route',
    );
    expect(routingBase('http://localhost/api/'), 'http://localhost/route');
  });

  test('Valhalla lines decode (polyline, 6 decimals)', () {
    // Encoded with 6 decimals: (38.5, -120.2), (40.7, -120.95).
    final points = decodePolyline6('_izlhA~rlgdF_{geC~ywl@');
    expect(points, hasLength(2));
    expect(points.first.latitude, closeTo(38.5, 1e-6));
    expect(points.first.longitude, closeTo(-120.2, 1e-6));
    expect(points.last.latitude, closeTo(40.7, 1e-6));
    expect(points.last.longitude, closeTo(-120.95, 1e-6));
  });

  test('steps south and west decode as negative (web-safe)', () {
    // Kampala, then a step 0.001 south and west.
    final points = decodePolyline6(
      _encode([(0.3136, 32.5811), (0.3126, 32.5801)]),
    );
    expect(points.last.latitude, closeTo(0.3126, 1e-6));
    expect(points.last.longitude, closeTo(32.5801, 1e-6));
  });

  test('distances and times read naturally', () {
    expect(formatMetres(850), '850 m');
    expect(formatMetres(3240), '3.2 km');
    expect(formatSeconds(30), '1 min');
    expect(formatSeconds(3900), '1 h 05 min');
  });
}

/// Google polyline encoding, 6 decimals (test helper).
String _encode(List<(double, double)> points) {
  final out = StringBuffer();
  var lastLat = 0, lastLon = 0;
  void put(int v) {
    var x = v < 0 ? ~(v << 1) : v << 1;
    while (x >= 0x20) {
      out.writeCharCode((0x20 | (x & 0x1f)) + 63);
      x >>= 5;
    }
    out.writeCharCode(x + 63);
  }

  for (final (lat, lon) in points) {
    final la = (lat * 1e6).round(), lo = (lon * 1e6).round();
    put(la - lastLat);
    put(lo - lastLon);
    lastLat = la;
    lastLon = lo;
  }
  return out.toString();
}
