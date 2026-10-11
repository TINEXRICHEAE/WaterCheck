@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

/// P3 gate: golden images of the safe / unsafe / inconclusive result cards
/// in light and dark themes. Goldens are generated on Windows
/// (`flutter test --update-goldens --tags golden`); CI on other platforms
/// excludes the `golden` tag because font rendering differs by OS.
void main() {
  Widget cards(ThemeData theme) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    localizationsDelegates: UiKitLocalizations.localizationsDelegates,
    supportedLocales: UiKitLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: const ValueKey('cards'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in [
                  SourceStatus.safe,
                  SourceStatus.unsafe,
                  SourceStatus.inconclusive,
                ]) ...[StatusBadge(s, large: true), const SizedBox(height: 12)],
              ],
            ),
          ),
        ),
      ),
    ),
  );

  for (final (name, theme) in [
    ('light', WaterCheckTheme.light()),
    ('dark', WaterCheckTheme.dark()),
  ]) {
    testWidgets('result cards ($name)', (tester) async {
      tester.view.physicalSize = const Size(400, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(cards(theme));
      await expectLater(
        find.byKey(const ValueKey('cards')),
        matchesGoldenFile('goldens/result_cards_$name.png'),
      );
    });
  }
}
