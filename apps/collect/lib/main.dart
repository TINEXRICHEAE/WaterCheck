import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:ui_kit/ui_kit.dart' show SearchHistory;

import 'app/app.dart';
import 'app/background_sync.dart';
import 'app/bootstrap.dart';
import 'app/gate.dart';
import 'app/providers.dart';
import 'app/services.dart';
import 'app/startup_error.dart';
import 'features/sync/collect_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await start();
}

Future<void> start() async {
  final values = SecureStorageValues();
  final keys = kIsWeb ? InMemoryKeyStore() : SecureStorageKeyStore();
  try {
    final boot = await openLocalData(values: values, keys: keys);
    final settings = DriftLocalSettingsRepository(boot.db);
    SearchHistory.use(read: settings.read, write: settings.write);
    runApp(
      CollectRoot(
        // A new key forces a fresh widget tree after a wipe and restart.
        key: UniqueKey(),
        boot: boot,
        overrides: [
          secureValuesProvider.overrideWithValue(values),
          databaseKeyStoreProvider.overrideWithValue(keys),
          restartAppProvider.overrideWithValue(start),
          connectivityProvider.overrideWithValue(
            Connectivity().onConnectivityChanged.map(
              (r) => r.any((c) => c != ConnectivityResult.none),
            ),
          ),
        ],
      ),
    );
    unawaited(
      scheduleBackgroundSync().catchError(
        (Object e) => debugPrint('Background sync not scheduled: $e'),
      ),
    );
  } catch (error, stack) {
    debugPrint('Startup failed: $error\n$stack');
    runApp(StartupErrorApp(onRetry: start));
  }
}

/// The app with its startup state injected (also used by widget tests).
class CollectRoot extends StatelessWidget {
  const CollectRoot({super.key, required this.boot, this.overrides = const []});

  final BootState boot;

  /// Extra provider overrides (tests use fakes such as a fixed GPS fix).
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(boot.db),
      localInstallationIdProvider.overrideWithValue(boot.installationId),
      appGateProvider.overrideWith(() => AppGateNotifier(boot.gate)),
      credentialsProvider.overrideWith(
        () => CredentialsNotifier(boot.credentials),
      ),
      clockOffsetProvider.overrideWith(() => ClockOffset(boot.clockOffset)),
      ...overrides,
    ],
    child: const CollectApp(),
  );
}
