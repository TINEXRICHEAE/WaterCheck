import 'package:data/data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../features/activation/collect_api.dart';

/// Platform services, replaced by fakes in tests.
abstract interface class Biometrics {
  Future<bool> available();
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometrics implements Biometrics {
  final _auth = LocalAuthentication();

  @override
  Future<bool> available() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }
}

abstract interface class FileSaver {
  /// Lets the user choose where to save; false if they cancelled.
  Future<bool> save(String fileName, Uint8List bytes);
}

class PickerFileSaver implements FileSaver {
  @override
  Future<bool> save(String fileName, Uint8List bytes) async =>
      await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/json',
      ) !=
      null;
}

/// Secrets: installation credentials and the app-lock PIN hash.
final secureValuesProvider = Provider<SecureValues>(
  (ref) => SecureStorageValues(),
);

final databaseKeyStoreProvider = Provider<DatabaseKeyStore>(
  (ref) => kIsWeb ? InMemoryKeyStore() : SecureStorageKeyStore(),
);

final installationStoreProvider = Provider<InstallationStore>(
  (ref) => InstallationStore(ref.watch(secureValuesProvider)),
);

final appLockProvider = Provider<AppLock>(
  (ref) => AppLock(ref.watch(secureValuesProvider)),
);

final collectApiProvider = Provider<CollectApi>((ref) => HttpCollectApi());

final biometricsProvider = Provider<Biometrics>((ref) => LocalAuthBiometrics());

final fileSaverProvider = Provider<FileSaver>((ref) => PickerFileSaver());

/// Deletes the database file during a wipe.
final deleteDatabaseProvider = Provider<Future<void> Function()>(
  (ref) => deleteAppDatabase,
);

/// Deletes stored photos during a wipe.
final deletePhotosProvider = Provider<Future<void> Function()>(
  (ref) => deleteAllPhotos,
);

/// Starts the app again from scratch (after a wipe). Set in `main.dart`.
final restartAppProvider = Provider<Future<void> Function()>(
  (ref) => () async {},
);

/// How long Collect may stay in the background before it locks again.
const lockAfterBackground = Duration(minutes: 5);

/// How often the installation's status is checked at most (F-AUTH-4).
const statusCheckInterval = Duration(minutes: 5);
