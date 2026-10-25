import 'dart:io';

import 'dart:async';

import 'package:data/data.dart';
import 'package:domain/domain.dart' show GeoFix;
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/app/bootstrap.dart';
import 'package:watercheck_collect/app/gate.dart';
import 'package:watercheck_collect/app/services.dart';
import 'package:api_client/api_client.dart' show InstallationSigner;
import 'package:watercheck_collect/features/activation/collect_api.dart';
import 'package:watercheck_collect/features/location/location_service.dart';
import 'package:watercheck_collect/features/photos/free_space.dart';
import 'package:watercheck_collect/features/photos/photo_service.dart';
import 'package:watercheck_collect/features/sync/collect_sync.dart';
import 'package:watercheck_collect/main.dart';

import 'fake_server.dart';

class FakeBiometrics implements Biometrics {
  bool isAvailable = false;
  bool succeeds = true;
  int prompts = 0;

  @override
  Future<bool> available() async => isAvailable;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return succeeds;
  }
}

class FakeFileSaver implements FileSaver {
  final saved = <String, Uint8List>{};
  bool cancel = false;

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    if (cancel) return false;
    saved[fileName] = bytes;
    return true;
  }
}

class FakePhotoPicker implements PhotoPicker {
  Uint8List? next;
  var picks = 0;

  @override
  Future<Uint8List?> pick(PhotoFrom from) async {
    picks++;
    return next;
  }
}

/// Fixes a test sends while travelling, and the fix a picture gets.
class FakeLiveLocation implements LiveLocation {
  final fixes = StreamController<GeoFix>.broadcast();
  GeoFix? detailed;

  @override
  Stream<GeoFix> watch() => fixes.stream;

  @override
  Future<GeoFix?> detail({Duration wait = const Duration(seconds: 15)}) async =>
      detailed;
}

class FakeFreeSpace implements FreeSpace {
  int? free = 2 * 1024 * 1024 * 1024;

  @override
  Future<int?> bytes() async => free;
}

/// Everything outside the database a test may want to inspect or change.
class TestServices {
  final values = MemoryValues();
  final keys = InMemoryKeyStore();
  final server = FakeServer();
  final biometrics = FakeBiometrics();
  final saver = FakeFileSaver();
  final photos = MemoryPhotoFiles();
  final picker = FakePhotoPicker();
  final freeSpace = FakeFreeSpace();
  final live = FakeLiveLocation();
  var onWifi = true;
  var restarts = 0;
  var deletes = 0;

  InstallationStore get installation => InstallationStore(values);
  AppLock get lock => AppLock(values, hasher: const PinHasher(iterations: 10));

  /// Credentials as if this phone had been activated by [server].
  Future<void> activate() => installation.save(
    InstallationCredentials(
      installationId: FakeServer.installationId,
      secret: FakeServer.secret,
      apiUrl: 'http://fake.test/api',
      areaId: 'ad625def-3111-5ddd-835f-b24118d37f01',
      areaCode: 'ABIM-ENT',
      areaName: 'Entebbe',
      activatedAt: DateTime.utc(2026, 10, 10),
      shortCode: '7Q2K',
    ),
  );

  List<Override> get overrides => [
    secureValuesProvider.overrideWithValue(values),
    databaseKeyStoreProvider.overrideWithValue(keys),
    appLockProvider.overrideWithValue(lock),
    collectApiProvider.overrideWithValue(HttpCollectApi(dio: server.dioFor)),
    biometricsProvider.overrideWithValue(biometrics),
    fileSaverProvider.overrideWithValue(saver),
    deleteDatabaseProvider.overrideWithValue(() async => deletes++),
    restartAppProvider.overrideWithValue(() async => restarts++),
    photoFilesProvider.overrideWithValue(photos),
    photoPickerProvider.overrideWithValue(picker),
    photoCompressorProvider.overrideWithValue(
      (b, taken) async => compressPhoto(b, taken: taken),
    ),
    liveLocationProvider.overrideWithValue(live),
    freeSpaceProvider.overrideWithValue(freeSpace),
    onWifiProvider.overrideWithValue(() async => onWifi),
    deletePhotosProvider.overrideWithValue(() async {}),
    attachmentTransportProvider.overrideWith((ref) {
      final c = ref.watch(credentialsProvider);
      if (c == null) return null;
      return ApiAttachmentTransport(
        server.dioFor(c.apiUrl)
          ..interceptors.add(
            InstallationSigner(
              installationId: c.installationId,
              secret: c.secret,
            ),
          ),
      );
    }),
    collectApiDioProvider.overrideWith((ref) {
      final c = ref.watch(credentialsProvider);
      if (c == null) return null;
      return server.dioFor(c.apiUrl)
        ..interceptors.add(
          InstallationSigner(
            installationId: c.installationId,
            secret: c.secret,
          ),
        );
    }),
    syncTransportProvider.overrideWith((ref) {
      final c = ref.watch(credentialsProvider);
      if (c == null) return null;
      return ApiSyncTransport(
        server.dioFor(c.apiUrl)
          ..interceptors.add(
            InstallationSigner(
              installationId: c.installationId,
              secret: c.secret,
            ),
          ),
      );
    }),
  ];
}

const _seed = '../../infra/seed';

/// A seeded in-memory database. With [onboarded] the privacy notice is
/// accepted and one collector profile exists and is selected.
Future<AppDatabase> seededDb({bool onboarded = true}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  final profiles = Directory('$_seed/reference_profiles')
      .listSync()
      .whereType<File>()
      .map((f) => 'reference_profiles/${f.uri.pathSegments.last}')
      .toList();
  await SeedImporter(db).importBundle(
    await SeedBundle.load(
      read: (p) => File('$_seed/$p').readAsString(),
      referenceProfilePaths: profiles,
    ),
  );
  if (onboarded) {
    final settings = DriftLocalSettingsRepository(db);
    await settings.recordConsent(privacyNoticeVersion);
    final profile = await DriftCollectorProfileRepository(db).save(
      const CollectorProfileInput(
        fullName: 'Example Collector',
        phone: '+256772123456',
        collectorType: 'vht',
        village: 'Entebbe',
        parish: 'TODO-verify parish',
        subcounty: 'TODO-verify sub-county',
        district: 'Abim',
      ),
    );
    await settings.write(activeCollectorSetting, profile.collectorKey);
  }
  return db;
}

/// Lets real database work finish between frames. `pumpAndSettle` alone
/// never settles while a loading spinner is animating.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty && i > 3) {
      break;
    }
  }
  await tester.pump(const Duration(milliseconds: 400));
}

/// Pumps Collect. By default the phone is activated, the lock was turned
/// off and (with [onboarded]) a collector is chosen; [activated] false starts
/// at activation and [pin] turns the app lock on.
Future<AppDatabase> pumpCollect(
  WidgetTester tester, {
  bool onboarded = true,
  bool activated = true,
  String? pin,
  TestServices? services,
  Size size = const Size(420, 900),
  List<Override> overrides = const [],
  Future<void> Function(AppDatabase db)? prepare,
}) async {
  final svc = services ?? TestServices();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final boot = (await tester.runAsync(() async {
    final db = await seededDb(onboarded: onboarded);
    if (activated) {
      await svc.activate();
      if (pin == null) {
        await DriftLocalSettingsRepository(db)
            .write(lockDeclinedSetting, 'true');
      }
    }
    if (pin != null) await svc.lock.setPin(pin);
    await prepare?.call(db);
    return loadBootState(db, installation: svc.installation, lock: svc.lock);
  }))!;
  await tester.pumpWidget(
    CollectRoot(boot: boot, overrides: [...svc.overrides, ...overrides]),
  );
  await settle(tester);
  return boot.db;
}

Future<void> disposeApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  // Drift's stream timers live on the test's fake clock: advance it so the
  // close can finish, then wait for it in real time.
  final closing = db.close();
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(() => closing);
}

/// Taps [finder] after scrolling it into view (building it first if a lazy
/// list has not yet), then settles.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // The page's vertical list, not a text field's own (sideways) scroller.
    final scrollable = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    if (scrollable.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: scrollable.last,
        maxScrolls: 30,
      );
    }
  }
  await tester.ensureVisible(finder);
  // Let the scroll finish: a list ignores taps while it moves (a focused
  // text field keeps scrolling itself into view).
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.tap(finder);
  await settle(tester);
}
