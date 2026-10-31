import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('the bar shows only for a request that takes a while', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RequestActivityBar(child: SizedBox())),
    );
    final slow = Completer<void>();
    unawaited(showingActivity(() => slow.future));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    slow.complete();
    await tester.pump();
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(requestsInFlight.value, 0);
  });

  testWidgets('a busy icon button spins and takes no second tap', (
    tester,
  ) async {
    final done = Completer<void>();
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusyIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              taps++;
              return done.future;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(taps, 1);
    done.complete();
    await tester.pump();
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
}
