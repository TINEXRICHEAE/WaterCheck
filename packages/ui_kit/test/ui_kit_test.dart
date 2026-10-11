import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _host(Widget child, {double width = 400}) => MaterialApp(
  theme: WaterCheckTheme.light(),
  localizationsDelegates: UiKitLocalizations.localizationsDelegates,
  supportedLocales: UiKitLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: Scaffold(body: child),
  ),
);

void main() {
  test('themes use padded tap targets and carry status colours', () {
    final light = WaterCheckTheme.light();
    expect(light.materialTapTargetSize, MaterialTapTargetSize.padded);
    expect(light.extension<StatusColors>(), StatusColors.light);
    final dark = WaterCheckTheme.dark();
    expect(dark.colorScheme.brightness, Brightness.dark);
    expect(dark.extension<StatusColors>(), StatusColors.dark);
    expect(
      StatusColors.light.lerp(StatusColors.dark, 1).safe,
      StatusColors.dark.safe,
    );
    expect(StatusColors.light.copyWith(safe: Colors.black).safe, Colors.black);
  });

  testWidgets('status is shown as text and icon, never colour alone', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            for (final s in SourceStatus.values) StatusBadge(s),
            const StatusBadge(SourceStatus.unsafe, large: true),
          ],
        ),
      ),
    );
    for (final label in [
      'SAFE',
      'INCONCLUSIVE',
      'NOT TESTED',
      'DUE',
      'OVERDUE',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('UNSAFE'), findsNWidgets(2));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.warning_rounded), findsNWidgets(2));
    expect(OverallStatus.unsafe.display, SourceStatus.unsafe);
    expect(OverallStatus.safe.display, SourceStatus.safe);
    expect(OverallStatus.inconclusive.display, SourceStatus.inconclusive);
  });

  testWidgets('sync indicator reports pending and refused items', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            SyncIndicator(pending: 0),
            SyncIndicator(pending: 3, lastSentLabel: 'yesterday'),
            SyncIndicator(pending: 1, rejected: 2),
            SyncIndicator(pending: 4, compact: true),
          ],
        ),
      ),
    );
    expect(find.text('Everything is sent'), findsOneWidget);
    expect(find.text('3 items waiting to send'), findsOneWidget);
    expect(find.textContaining('Last sent yesterday'), findsOneWidget);
    expect(find.text('2 items were refused'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('adaptive scaffold switches between bar and rail', (
    tester,
  ) async {
    Widget scaffold(double width) => _host(
      AdaptiveScaffold(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
          AdaptiveDestination(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'One',
          ),
          AdaptiveDestination(
            icon: Icons.list_outlined,
            selectedIcon: Icons.list,
            label: 'Two',
          ),
        ],
        body: const Text('body'),
      ),
      width: width,
    );
    await tester.pumpWidget(scaffold(400));
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.pumpWidget(scaffold(1200));
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('PlaceholderHome shows app name and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceholderHome(appName: 'Test App', subtitle: 'Sub'),
      ),
    );
    expect(find.text('Test App'), findsNWidgets(2));
    expect(find.text('Sub'), findsOneWidget);
  });
}
