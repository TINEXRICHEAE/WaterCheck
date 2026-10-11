import 'dart:convert';
import 'dart:math';

import '../repositories/support.dart';
import 'pin_hash.dart';
import 'secure_values.dart';

/// The app-lock settings as stored.
class LockConfig {
  const LockConfig({
    this.pinHash,
    this.biometric = false,
    this.failures = 0,
    this.lockedUntil,
  });

  final String? pinHash;
  final bool biometric;
  final int failures;
  final DateTime? lockedUntil;

  bool get enabled => pinHash != null;

  Map<String, Object?> toJson() => {
    'pin_hash': pinHash,
    'biometric': biometric,
    'failures': failures,
    'locked_until': lockedUntil?.toUtc().toIso8601String(),
  };

  static LockConfig fromJson(Map<String, Object?> json) => LockConfig(
    pinHash: json['pin_hash'] as String?,
    biometric: json['biometric'] as bool? ?? false,
    failures: json['failures'] as int? ?? 0,
    lockedUntil: switch (json['locked_until']) {
      final String s => DateTime.parse(s),
      _ => null,
    },
  );
}

sealed class UnlockResult {
  const UnlockResult();
}

class Unlocked extends UnlockResult {
  const Unlocked();
}

class WrongPin extends UnlockResult {
  const WrongPin({required this.triesBeforeWait});

  /// Wrong attempts left before a wait is imposed (0 = a wait now applies).
  final int triesBeforeWait;
}

class MustWait extends UnlockResult {
  const MustWait(this.remaining);

  final Duration remaining;
}

/// PIN (and optional biometric) app lock for shared phones and for offline
/// Console on Windows/Android (F-AUTH-2). After [freeTries] wrong PINs each
/// further mistake imposes a doubling wait (30 s up to 15 min).
class AppLock {
  AppLock(
    this._values, {
    this.hasher = const PinHasher(),
    this.clock = systemClock,
    this.key = 'watercheck.lock.v1',
  });

  static const freeTries = 5;
  static const firstWait = Duration(seconds: 30);
  static const maxWait = Duration(minutes: 15);

  final SecureValues _values;
  final PinHasher hasher;
  final Clock clock;
  final String key;

  Future<LockConfig> config() async {
    final raw = await _values.read(key);
    if (raw == null) return const LockConfig();
    return LockConfig.fromJson((jsonDecode(raw) as Map).cast());
  }

  Future<void> _save(LockConfig c) => _values.write(key, jsonEncode(c));

  Future<void> setPin(String pin) async {
    if (!PinHasher.isValid(pin)) {
      throw ArgumentError.value('****', 'pin', 'must be 4 to 8 digits');
    }
    final old = await config();
    await _save(
      LockConfig(pinHash: await hasher.hash(pin), biometric: old.biometric),
    );
  }

  Future<void> setBiometric(bool on) async {
    final c = await config();
    await _save(
      LockConfig(
        pinHash: c.pinHash,
        biometric: on,
        failures: c.failures,
        lockedUntil: c.lockedUntil,
      ),
    );
  }

  /// Turns the lock off (the caller has just verified the PIN).
  Future<void> disable() => _values.delete(key);

  Future<UnlockResult> unlock(String pin) async {
    final c = await config();
    final hash = c.pinHash;
    if (hash == null) return const Unlocked();
    final now = clock();
    final until = c.lockedUntil;
    if (until != null && now.isBefore(until)) {
      return MustWait(until.difference(now));
    }
    if (await hasher.verify(pin, hash)) {
      await _save(LockConfig(pinHash: hash, biometric: c.biometric));
      return const Unlocked();
    }
    final failures = c.failures + 1;
    final over = failures - freeTries;
    final wait = over < 0
        ? null
        : Duration(
            seconds: min(
              firstWait.inSeconds * pow(2, over).toInt(),
              maxWait.inSeconds,
            ),
          );
    await _save(
      LockConfig(
        pinHash: hash,
        biometric: c.biometric,
        failures: failures,
        lockedUntil: wait == null ? null : now.add(wait),
      ),
    );
    return wait == null
        ? WrongPin(triesBeforeWait: freeTries - failures)
        : MustWait(wait);
  }

  /// A successful biometric check counts as an unlock.
  Future<void> unlockedByBiometric() async {
    final c = await config();
    if (c.failures == 0 && c.lockedUntil == null) return;
    await _save(LockConfig(pinHash: c.pinHash, biometric: c.biometric));
  }
}
