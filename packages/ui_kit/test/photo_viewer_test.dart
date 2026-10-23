import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

/// A 1×1 transparent PNG.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Widget _host(List<ViewedPhoto> photos) => MaterialApp(
  localizationsDelegates: UiKitLocalizations.localizationsDelegates,
  supportedLocales: UiKitLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => showPhotoViewer(context, photos: photos),
        child: const Text('open'),
      ),
    ),
  ),
);

void main() {
  testWidgets('pictures open full screen and step with the keys', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        ViewedPhoto(load: () async => _png, caption: 'Source, 3 Oct'),
        ViewedPhoto(load: () async => null, caption: 'Test, 4 Oct'),
      ]),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Picture 1 of 2'), findsOneWidget);
    expect(find.text('Source, 3 Oct'), findsOneWidget);
    expect(find.byTooltip('Remove picture'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Picture 2 of 2'), findsOneWidget);
    expect(find.textContaining("can't be shown"), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('the author removes a picture after confirming', (tester) async {
    var removed = 0;
    await tester.pumpWidget(
      _host([
        ViewedPhoto(
          load: () async => _png,
          onRemove: () async {
            removed++;
            return true;
          },
        ),
      ]),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove picture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(removed, 0);

    await tester.tap(find.byTooltip('Remove picture'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove picture'));
    await tester.pumpAndSettle();
    expect(removed, 1);
    expect(find.text('open'), findsOneWidget, reason: 'the last one: closed');
  });
}
