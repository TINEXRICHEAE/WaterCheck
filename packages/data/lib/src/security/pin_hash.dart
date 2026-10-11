import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// PIN hashes for the app lock (F-AUTH-2): PBKDF2-HMAC-SHA256 with a random
/// salt, stored as `pbkdf2-sha256$<iterations>$<salt>$<hash>` (base64).
///
/// A 4–6 digit PIN is guessable offline whatever the hash, so the real
/// protection is that the hash lives in secure storage and that wrong
/// attempts are slowed down (see `AppLock`).
class PinHasher {
  const PinHasher({this.iterations = 20000});

  final int iterations;

  static final _pin = RegExp(r'^\d{4,8}$');

  /// A PIN is 4 to 8 digits.
  static bool isValid(String pin) => _pin.hasMatch(pin);

  Future<String> hash(String pin, {List<int>? salt}) async {
    final s =
        salt ?? List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final digest = await _derive(pin, s, iterations);
    return 'pbkdf2-sha256\$$iterations\$${base64.encode(s)}\$'
        '${base64.encode(digest)}';
  }

  Future<bool> verify(String pin, String encoded) async {
    final parts = encoded.split(r'$');
    if (parts.length != 4 || parts[0] != 'pbkdf2-sha256') return false;
    final rounds = int.tryParse(parts[1]);
    if (rounds == null || rounds < 1) return false;
    final expected = base64.decode(parts[3]);
    final actual = await _derive(pin, base64.decode(parts[2]), rounds);
    return constantTimeEquals(actual, expected);
  }

  static Future<List<int>> _derive(
    String pin,
    List<int> salt,
    int rounds,
  ) async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: rounds,
      bits: 256,
    ).deriveKey(secretKey: SecretKey(utf8.encode(pin)), nonce: salt);
    return key.extractBytes();
  }
}

bool constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
