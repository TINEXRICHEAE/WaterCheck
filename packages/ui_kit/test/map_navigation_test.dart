import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';
import 'package:ui_kit/ui_kit.dart';

class _Map extends StatefulWidget {
  const _Map({required this.showKeys});

  final bool showKeys;

  @override
  State<_Map> createState() => _MapState();
}

class _MapState extends State<_Map> with TickerProviderStateMixin {
  final map = MapController();
  late final motion = MapMotion(map, this);

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      FlutterMap(
        mapController: map,
        options: const MapOptions(
          initialCenter: LatLng(0.35, 32.58),
          initialZoom: 12,
        ),
        children: const [],
      ),
      Positioned(
        top: 8,
        right: 8,
        child: MapNavigationButtons(motion: motion, showKeys: widget.showKeys),
      ),
    ],
  );
}

Future<_MapState> _pump(WidgetTester tester, {bool showKeys = false}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: UiKitLocalizations.localizationsDelegates,
      supportedLocales: UiKitLocalizations.supportedLocales,
      home: Scaffold(body: _Map(showKeys: showKeys)),
    ),
  );
  await tester.pumpAndSettle();
  return tester.state<_MapState>(find.byType(_Map));
}

void main() {
  testWidgets('the pad moves the map each way; zoom buttons zoom', (
    tester,
  ) async {
    final map = await _pump(tester);
    LatLng centre() => map.map.camera.center;
    final start = centre();

    await tester.tap(find.byTooltip('Move up (↑ or W; hold to keep moving)'));
    await tester.pumpAndSettle();
    expect(centre().latitude, greaterThan(start.latitude));

    await tester.tap(
      find.byTooltip('Move right (→ or D; hold to keep moving)'),
    );
    await tester.pumpAndSettle();
    expect(centre().longitude, greaterThan(start.longitude));

    await tester.tap(find.byTooltip('Zoom in (R key)'));
    await tester.pumpAndSettle();
    expect(map.map.camera.zoom, 13);
    expect(find.text('↑ W'), findsNothing, reason: 'no keys on a phone');
  });

  testWidgets('on a computer each button shows its key', (tester) async {
    await _pump(tester, showKeys: true);
    for (final key in ['↑ W', '↓ S', '← A', '→ D', 'R', 'F']) {
      expect(find.text(key), findsOneWidget);
    }
  });
}
