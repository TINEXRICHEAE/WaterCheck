import 'package:data/data.dart';

import 'gate.dart';

class BootState {
  const BootState({
    required this.db,
    required this.installationId,
    required this.gate,
    this.credentials,
    this.clockOffset = Duration.zero,
  });

  final AppDatabase db;

  /// The local ID, used only until activation.
  final String installationId;
  final AppGate gate;
  final InstallationCredentials? credentials;

  /// Server time minus device time, as last learned.
  final Duration clockOffset;
}

/// Opens the local database, imports the bundled seed and reads the local
/// settings and secure-storage state the router needs. Runs offline: no
/// network call (SPEC §A0.6).
Future<BootState> openLocalData({
  required SecureValues values,
  required DatabaseKeyStore keys,
}) async {
  final db = await openAppDatabase(keys: keys);
  await SeedImporter(db).importBundle(await SeedBundle.fromAssets());
  return loadBootState(
    db,
    installation: InstallationStore(values),
    lock: AppLock(values),
  );
}

Future<BootState> loadBootState(
  AppDatabase db, {
  required InstallationStore installation,
  required AppLock lock,
}) async {
  final settings = DriftLocalSettingsRepository(db);
  final consent = await settings.consentVersion();
  final credentials = await installation.read();
  if (credentials != null &&
      await settings.read(DriftLocalSettingsRepository.installationKey) !=
          credentials.installationId) {
    await settings.write(
      DriftLocalSettingsRepository.installationKey,
      credentials.installationId,
    );
  }
  final lockOn = (await lock.config()).enabled;
  return BootState(
    db: db,
    installationId: await settings.installationId(),
    credentials: credentials,
    clockOffset: await installation.clockOffset(),
    gate: AppGate(
      consented: consent != null && consent >= privacyNoticeVersion,
      activated: credentials != null,
      revoked: await installation.isRevoked(),
      lockDecided: lockOn || await settings.read(lockDeclinedSetting) != null,
      locked: lockOn,
      activeCollectorKey: await settings.read(activeCollectorSetting),
    ),
  );
}
