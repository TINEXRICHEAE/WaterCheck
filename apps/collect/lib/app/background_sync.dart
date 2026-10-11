import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../features/photos/photo_service.dart' show photosOnMobileDataSetting;
import '../features/sync/collect_sync.dart';

const _task = 'watercheck-sync';

/// Android: a periodic background sync while the app is closed (SPEC §8.6).
/// WorkManager runs it at most every 15 minutes, only with a network, and
/// respects Doze and battery saver. The sync lock keeps it from overlapping
/// with a sync in the open app.
Future<void> scheduleBackgroundSync() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  await Workmanager().initialize(backgroundSyncDispatcher);
  await Workmanager().registerPeriodicTask(
    _task,
    _task,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await runBackgroundSync();
      return true;
    } catch (e) {
      debugPrint('Background sync failed: $e');
      return false;
    }
  });
}

/// One sync from a background isolate: the same database, credentials and
/// service as the app.
Future<SyncReport?> runBackgroundSync() async {
  final store = InstallationStore(SecureStorageValues());
  final credentials = await store.read();
  if (credentials == null || await store.isRevoked()) return null;
  final db = await openAppDatabase(keys: SecureStorageKeyStore());
  try {
    var offset = await store.clockOffset();
    final dio = collectSyncDio(
      credentials,
      clockOffset: () => offset,
      onOffset: (o) => offset = o,
    );
    final sync = SyncService(
      db,
      ApiSyncTransport(dio),
      streams: collectStreams(credentials),
    );
    final report = await sync.run();
    if (report.failure?.code == 'installation_revoked') {
      // The app shows the export-then-wipe screen next time it opens.
      await store.markRevoked();
    } else if (report.ok) {
      final settings = DriftLocalSettingsRepository(db);
      await AttachmentUploader(
        db,
        DevicePhotoFiles(),
        ApiAttachmentTransport(dio),
        networkAllowed: () async {
          final kinds = await Connectivity().checkConnectivity();
          return kinds.contains(ConnectivityResult.wifi) ||
              kinds.contains(ConnectivityResult.ethernet) ||
              await settings.read(photosOnMobileDataSetting) == 'true';
        },
      ).run();
    }
    await store.setClockOffset(offset);
    return report;
  } finally {
    await db.close();
  }
}
