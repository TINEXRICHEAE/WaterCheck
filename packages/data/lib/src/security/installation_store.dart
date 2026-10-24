import 'dart:convert';

import 'secure_values.dart';

/// What Collect keeps after activation (F-AUTH-7, ADR-009). The secret signs
/// every request and never leaves secure storage except inside signatures.
class InstallationCredentials {
  const InstallationCredentials({
    required this.installationId,
    required this.secret,
    required this.apiUrl,
    required this.areaId,
    required this.areaCode,
    required this.areaName,
    required this.activatedAt,
    this.shortCode,
  });

  final String installationId;
  final String secret;

  /// Base URL of the API, e.g. `https://watercheck.example.org/api`.
  final String apiUrl;

  /// Empty for a device that registered itself (ADR-024): testers, not
  /// devices, are assigned to areas.
  final String areaId;
  final String areaCode;
  final String areaName;

  bool get hasArea => areaId.isNotEmpty;
  final DateTime activatedAt;

  /// Short ID used in the SMS fallback (`I:7Q2K`, SPEC §8.5). Phones
  /// activated before P8 learn it at their next status check.
  final String? shortCode;

  InstallationCredentials withShortCode(String code) => InstallationCredentials(
    installationId: installationId,
    secret: secret,
    apiUrl: apiUrl,
    areaId: areaId,
    areaCode: areaCode,
    areaName: areaName,
    activatedAt: activatedAt,
    shortCode: code,
  );

  Map<String, Object?> toJson() => {
    'installation_id': installationId,
    'secret': secret,
    'api_url': apiUrl,
    'area_id': areaId,
    'area_code': areaCode,
    'area_name': areaName,
    'activated_at': activatedAt.toUtc().toIso8601String(),
    'short_code': ?shortCode,
  };

  static InstallationCredentials fromJson(Map<String, Object?> j) =>
      InstallationCredentials(
        installationId: j['installation_id']! as String,
        secret: j['secret']! as String,
        apiUrl: j['api_url']! as String,
        areaId: j['area_id']! as String,
        areaCode: j['area_code']! as String,
        areaName: j['area_name']! as String,
        activatedAt: DateTime.parse(j['activated_at']! as String),
        shortCode: j['short_code'] as String?,
      );
}

/// Installation credentials, clock offset and the revoked flag, all in
/// secure storage so they survive restarts but not a wipe.
class InstallationStore {
  InstallationStore(this._values);

  static const _credentials = 'watercheck.installation.v1';
  static const _offset = 'watercheck.installation.clock_offset_ms';
  static const _revoked = 'watercheck.installation.revoked';

  final SecureValues _values;

  Future<InstallationCredentials?> read() async {
    final raw = await _values.read(_credentials);
    if (raw == null) return null;
    return InstallationCredentials.fromJson((jsonDecode(raw) as Map).cast());
  }

  Future<void> save(InstallationCredentials c) =>
      _values.write(_credentials, jsonEncode(c));

  /// Server time minus device time (SPEC §5.2), used when signing.
  Future<Duration> clockOffset() async {
    final raw = await _values.read(_offset);
    return Duration(milliseconds: int.tryParse(raw ?? '') ?? 0);
  }

  Future<void> setClockOffset(Duration offset) =>
      _values.write(_offset, offset.inMilliseconds.toString());

  /// Set when the server reports this installation revoked; cleared by the
  /// wipe. Survives restarts so the app cannot be used offline afterwards.
  Future<bool> isRevoked() async => await _values.read(_revoked) == 'true';

  Future<void> markRevoked() => _values.write(_revoked, 'true');

  Future<void> clear() async {
    await _values.delete(_credentials);
    await _values.delete(_offset);
    await _values.delete(_revoked);
  }
}
