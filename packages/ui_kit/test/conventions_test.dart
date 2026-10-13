import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: UiKitLocalizations.localizationsDelegates,
  supportedLocales: UiKitLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('time zone', () {
    tearDown(() => WcTime.zone = TimeZoneChoice.fallback);

    test('stored values parse; anything unknown is Kampala', () {
      expect(TimeZoneChoice.parse(null), TimeZoneChoice.kampala);
      expect(TimeZoneChoice.parse(''), TimeZoneChoice.kampala);
      expect(TimeZoneChoice.parse('Mars/Base'), TimeZoneChoice.kampala);
      expect(TimeZoneChoice.parse('auto'), TimeZoneChoice.auto);
      expect(TimeZoneChoice.parse('Africa/Nairobi'), TimeZoneChoice.nairobi);
      expect(TimeZoneChoice.parse('UTC'), TimeZoneChoice.utc);
      for (final z in TimeZoneChoice.values) {
        expect(TimeZoneChoice.parse(z.stored), z);
      }
    });

    test('East Africa Time is UTC+3 both ways', () {
      WcTime.zone = TimeZoneChoice.kampala;
      final utc = DateTime.utc(2026, 10, 13, 22, 30);
      final wall = WcTime.local(utc);
      expect(
        (wall.year, wall.month, wall.day, wall.hour, wall.minute),
        (2026, 10, 14, 1, 30),
      );
      expect(WcTime.toUtc(wall), utc);
      WcTime.zone = TimeZoneChoice.utc;
      expect(WcTime.local(utc).hour, 22);
    });

    test('themes parse, defaulting to the device', () {
      expect(ThemeChoice.parse('dark').mode, ThemeMode.dark);
      expect(ThemeChoice.parse(null).mode, ThemeMode.system);
    });
  });

  test('errors are classified without showing them', () {
    expect(
      errorKindOf('SocketException: Failed host lookup'),
      ErrorKind.offline,
    );
    expect(
      errorKindOf('DioException [bad response]: status code of 503'),
      ErrorKind.server,
    );
    expect(errorKindOf('... status code of 403 ...'), ErrorKind.forbidden);
    expect(errorKindOf('Connection timed out'), ErrorKind.timeout);
    expect(errorKindOf(StateError('x')), ErrorKind.unknown);
  });

  testWidgets('an error page says what to do and never the exception', (
    tester,
  ) async {
    var retried = 0;
    await tester.pumpWidget(
      _host(
        ErrorView(
          error: Exception('secret stack detail'),
          onRetry: () => retried++,
        ),
      ),
    );
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);
  });

  testWidgets('a busy button shows a spinner and ignores a second tap', (
    tester,
  ) async {
    final done = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      _host(
        BusyButton(
          onPressed: () {
            calls++;
            return done.future;
          },
          child: const Text('Save'),
        ),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Save'));
    expect(calls, 1);
    done.complete();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a search box clears with one tap', (tester) async {
    var value = 'bore';
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => SearchField(
            value: value,
            label: 'Search',
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(value, '');
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  testWidgets('the logo is labelled for screen readers', (tester) async {
    await tester.pumpWidget(_host(const AppLogo()));
    expect(find.bySemanticsLabel('WaterCheck logo'), findsOneWidget);
  });
}
