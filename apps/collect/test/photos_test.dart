import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'support/harness.dart';

const _village = 'ad625def-3111-5ddd-835f-b24118d37f01';

Uint8List cameraPhoto() {
  final image = img.Image(width: 640, height: 480);
  for (final p in image) {
    p
      ..r = (p.x * 3) % 256
      ..g = (p.y * 5) % 256
      ..b = 120;
  }
  return img.encodeJpg(image, quality: 90);
}

Future<String> addSource(AppDatabase db) async {
  final collector = (await DriftCollectorProfileRepository(
    db,
  ).watchActive().first).first;
  final source = await DriftSourceRepository(db).create(
    const NewSource(
      villageId: _village,
      code: 'ABIM-ENT-001',
      sourceType: 'borehole',
      name: 'Main borehole',
    ),
    SubmissionOrigin.collect(
      installationId: '0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f00001',
      collector: collector,
    ),
  );
  return source.id;
}

Future<void> openSource(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Main borehole'));
  expect(find.text('Photos of this source'), findsOneWidget);
}

void main() {
  testWidgets(
    'Wi-Fi only: records sync on mobile data, the photo waits, then uploads',
    (tester) async {
      final svc = TestServices()
        ..onWifi = false
        ..picker.next = cameraPhoto();
      final db = await pumpCollect(tester, services: svc, prepare: addSource);
      await openSource(tester);
      await tapAndSettle(tester, find.text('Choose photo'));
      expect(find.textContaining('Photo saved'), findsOneWidget);
      expect(find.bySemanticsLabel('Waiting to upload'), findsOneWidget);
      final stored = svc.photos.files.values.single;
      expect(stored.length, lessThanOrEqualTo(maxPhotoBytes));

      // On mobile data: the source and the photo's record are sent...
      await tester.pageBack();
      await settle(tester);
      await tapAndSettle(tester, find.text('Sync'));
      await tapAndSettle(tester, find.text('Sync now'));
      expect(
        svc.server.pushed.map((c) => c['entity']),
        containsAll(['water_source', 'attachment']),
      );
      // ...but the photo itself waits for Wi-Fi.
      expect(svc.server.uploaded, isEmpty);
      expect(find.text('1 photo waiting to upload'), findsOneWidget);

      svc.onWifi = true;
      await tapAndSettle(tester, find.text('Sync now'));
      final sent = svc.server.uploaded.values.single;
      expect(sha256.convert(sent), sha256.convert(stored));
      expect(find.text('1 photo waiting to upload'), findsNothing);
      await disposeApp(tester, db);
    },
  );

  testWidgets('mobile data allowed in Settings: the photo uploads at once', (
    tester,
  ) async {
    final svc = TestServices()
      ..onWifi = false
      ..picker.next = cameraPhoto();
    final db = await pumpCollect(tester, services: svc, prepare: addSource);
    await tapAndSettle(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('Upload photos on mobile data'));
    await tapAndSettle(tester, find.text('Home'));
    await openSource(tester);
    await tapAndSettle(tester, find.text('Choose photo'));
    await tester.pageBack();
    await settle(tester);
    await tapAndSettle(tester, find.text('Sync'));
    await tapAndSettle(tester, find.text('Sync now'));
    expect(svc.server.uploaded, hasLength(1));
    await disposeApp(tester, db);
  });

  testWidgets(
    'chaos #7: low storage blocks photos with a message, field work goes on',
    (tester) async {
      final svc = TestServices()
        ..freeSpace.free = 50 * 1024 * 1024
        ..picker.next = cameraPhoto();
      final db = await pumpCollect(tester, services: svc, prepare: addSource);
      await openSource(tester);
      await tapAndSettle(tester, find.text('Choose photo'));
      expect(find.textContaining('almost full'), findsOneWidget);
      expect(svc.picker.picks, 0, reason: 'the camera is not even opened');
      expect(svc.photos.files, isEmpty);
      // The guard only touches photos: testing stays available, and the
      // source's records are queued as usual.
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Test a source'),
            )
            .onPressed,
        isNotNull,
      );
      await disposeApp(tester, db);
    },
  );

  testWidgets('a file that is not a photo is refused', (tester) async {
    final svc = TestServices()
      ..picker.next = Uint8List.fromList(List.filled(100, 7));
    final db = await pumpCollect(tester, services: svc, prepare: addSource);
    await openSource(tester);
    await tapAndSettle(tester, find.text('Choose photo'));
    expect(find.textContaining('not a photo'), findsOneWidget);
    expect(svc.photos.files, isEmpty);
    await disposeApp(tester, db);
  });
}
