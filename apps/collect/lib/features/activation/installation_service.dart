import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../app/services.dart';
import '../settings/settings_screen.dart' show appVersion;
import '../sync/collect_sync.dart' show clockOffsetProvider;
import 'collect_api.dart';

/// Activation, status checks, and export-then-wipe (F-AUTH-4, F-AUTH-7).
class InstallationService {
  InstallationService(this._ref, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Ref _ref;
  final DateTime Function() _now;
  DateTime? _lastCheck;

  /// Throws [ApiFailure] when activation is refused or the server is
  /// unreachable. Reference data is downloaded too, but failing that is not
  /// fatal: the bundled seed is enough to work offline.
  Future<void> activate({required String apiUrl, required String code}) async {
    final api = _ref.read(collectApiProvider);
    final activation = await api.activate(
      apiUrl: apiUrl,
      code: code,
      platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
      appVersion: appVersion,
    );
    await _keep(api, activation);
  }

  Future<void>? _registering;

  /// Registers this device once (ADR-024): no code is needed to work and
  /// sync. Offline it returns false and is tried again later; everything
  /// is kept on the device meanwhile.
  Future<bool> ensureRegistered() async {
    if (_ref.read(credentialsProvider) != null) return true;
    final running = _registering ??= () async {
      final api = _ref.read(collectApiProvider);
      final activation = await api.register(
        apiUrl: defaultApiUrl(),
        platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
        appVersion: appVersion,
      );
      await _keep(api, activation);
    }();
    try {
      await running;
      return true;
    } on ApiFailure catch (e) {
      debugPrint('Registration not possible now: $e');
      return false;
    } finally {
      _registering = null;
    }
  }

  Future<void> _keep(CollectApi api, Activation activation) async {
    final c = activation.credentials;
    final store = _ref.read(installationStoreProvider);
    await store.save(c);
    await store.setClockOffset(activation.clockOffset);
    _ref.read(clockOffsetProvider.notifier).set(activation.clockOffset);
    await _ref
        .read(localSettingsRepositoryProvider)
        .write(DriftLocalSettingsRepository.installationKey, c.installationId);
    try {
      final published = await api.reference(c, activation.clockOffset);
      await SeedImporter(_ref.read(databaseProvider)).importPublished(
        rules: published.rules,
        lists: published.lists,
        profiles: published.profiles,
      );
    } on ApiFailure catch (e) {
      debugPrint('Reference download skipped: $e');
    }
    _lastCheck = _now();
    _ref.read(credentialsProvider.notifier).set(c);
    _ref.read(appGateProvider.notifier).activated();
  }

  /// Asks the server whether this installation may still send data, at most
  /// every [statusCheckInterval] unless [force]d. Offline is not an error:
  /// the app keeps working and asks again later.
  Future<InstallationStatus?> checkStatus({bool force = false}) async {
    final c = _ref.read(credentialsProvider);
    if (c == null || _ref.read(appGateProvider).revoked) return null;
    final now = _now();
    final last = _lastCheck;
    if (!force && last != null && now.difference(last) < statusCheckInterval) {
      return null;
    }
    _lastCheck = now;
    final store = _ref.read(installationStoreProvider);
    final result = await _ref
        .read(collectApiProvider)
        .check(c, _ref.read(clockOffsetProvider));
    final offset = result.clockOffset;
    if (offset != null) _ref.read(clockOffsetProvider.notifier).set(offset);
    final short = result.shortCode;
    if (short != null && short != c.shortCode) {
      final updated = c.withShortCode(short);
      await store.save(updated);
      _ref.read(credentialsProvider.notifier).set(updated);
    }
    if (result.status == InstallationStatus.revoked) {
      await store.markRevoked();
      _ref.read(appGateProvider.notifier).revoked();
    }
    return result.status;
  }

  Future<int> unsyncedCount() async =>
      (await _ref.read(outboxRepositoryProvider).unsynced()).length;

  /// Encrypts everything not yet sent (F-SYN-5) and lets the user choose
  /// where to save it. False if they cancelled.
  Future<bool> exportUnsynced() async {
    final c = _ref.read(credentialsProvider);
    if (c == null) throw StateError('Not activated');
    final now = _now();
    final file = await ExportFile.encrypt(
      installationId: c.installationId,
      secret: c.secret,
      createdAt: now,
      content: unsyncedExportContent(
        installationId: c.installationId,
        schemaVersion: localSchemaVersion,
        exportedAt: now,
        rows: await _ref.read(outboxRepositoryProvider).unsynced(),
      ),
    );
    final stamp = DateFormat('yyyyMMdd-HHmm').format(now);
    return _ref
        .read(fileSaverProvider)
        .save(
          'watercheck-unsent-${c.areaCode}-$stamp.json',
          Uint8List.fromList(utf8.encode(file)),
        );
  }

  /// Erases every trace of this installation from the device and starts
  /// again at activation: credentials, PIN, the database and its key.
  Future<void> wipe() async {
    await _ref.read(installationStoreProvider).clear();
    await _ref.read(appLockProvider).disable();
    final db = _ref.read(databaseProvider);
    final keys = _ref.read(databaseKeyStoreProvider);
    final restart = _ref.read(restartAppProvider);
    final delete = _ref.read(deleteDatabaseProvider);
    final deletePhotos = _ref.read(deletePhotosProvider);
    await db.close();
    await delete();
    await deletePhotos();
    await keys.delete();
    await restart();
  }
}

final installationServiceProvider = Provider<InstallationService>(
  InstallationService.new,
);
