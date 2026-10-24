import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart' show legalVersion;

import 'providers.dart';

/// The version of the Privacy Policy and Terms of Use people accept (SPEC
/// §9.3): the documents' own version, so a change asks everyone again.
const privacyNoticeVersion = legalVersion;

/// What the router needs to decide where a user may go.
class AppGate {
  const AppGate({
    required this.consented,
    required this.activeCollectorKey,
    this.activated = true,
    this.revoked = false,
    this.lockDecided = true,
    this.locked = false,
  });

  final bool consented;

  /// Activated once online with an IT admin's code (F-AUTH-7).
  final bool activated;

  /// The server said this installation is revoked: export, then wipe.
  final bool revoked;

  /// The app lock was set up or deliberately turned off (it is on by
  /// default, so a new installation is asked to choose a PIN).
  final bool lockDecided;

  /// The app lock is showing.
  final bool locked;

  /// The collector testing right now ("Who is testing?"), if chosen.
  final String? activeCollectorKey;

  AppGate copyWith({
    bool? consented,
    bool? activated,
    bool? revoked,
    bool? lockDecided,
    bool? locked,
    String? activeCollectorKey,
    bool clearCollector = false,
  }) => AppGate(
    consented: consented ?? this.consented,
    activated: activated ?? this.activated,
    revoked: revoked ?? this.revoked,
    lockDecided: lockDecided ?? this.lockDecided,
    locked: locked ?? this.locked,
    activeCollectorKey: clearCollector
        ? null
        : activeCollectorKey ?? this.activeCollectorKey,
  );
}

/// Loaded at startup (see `bootstrap.dart`) and kept in step with storage.
class AppGateNotifier extends Notifier<AppGate> {
  AppGateNotifier(this._initial);

  final AppGate _initial;

  @override
  AppGate build() => _initial;

  Future<void> giveConsent() async {
    await ref
        .read(localSettingsRepositoryProvider)
        .recordConsent(privacyNoticeVersion);
    state = state.copyWith(consented: true);
  }

  void activated() => state = state.copyWith(activated: true);

  void revoked() => state = state.copyWith(revoked: true);

  /// The PIN was set (or the lock deliberately turned off).
  Future<void> lockDecided({required bool declined}) async {
    await ref
        .read(localSettingsRepositoryProvider)
        .write(lockDeclinedSetting, declined ? 'true' : null);
    state = state.copyWith(lockDecided: true);
  }

  void lock() => state = state.copyWith(locked: true);

  void unlock() => state = state.copyWith(locked: false);

  Future<void> selectCollector(String collectorKey) async {
    await ref
        .read(localSettingsRepositoryProvider)
        .write(activeCollectorSetting, collectorKey);
    state = state.copyWith(activeCollectorKey: collectorKey);
  }

  Future<void> clearCollector() async {
    await ref
        .read(localSettingsRepositoryProvider)
        .write(activeCollectorSetting, null);
    state = state.copyWith(clearCollector: true);
  }
}

const activeCollectorSetting = 'collect.active_collector';
const lockDeclinedSetting = 'collect.lock_declined';

final appGateProvider = NotifierProvider<AppGateNotifier, AppGate>(
  () => throw UnimplementedError('appGateProvider must be overridden'),
);

/// This installation's credentials once activated; null before.
class CredentialsNotifier extends Notifier<InstallationCredentials?> {
  CredentialsNotifier(this._initial);

  final InstallationCredentials? _initial;

  @override
  InstallationCredentials? build() => _initial;

  void set(InstallationCredentials? c) => state = c;
}

final credentialsProvider =
    NotifierProvider<CredentialsNotifier, InstallationCredentials?>(
      () => CredentialsNotifier(null),
    );
