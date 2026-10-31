import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:ui_kit/ui_kit.dart' show RequestActivityInterceptor;

/// What activation returns (F-AUTH-7).
class Activation {
  const Activation({required this.credentials, required this.clockOffset});

  final InstallationCredentials credentials;

  /// Server time minus device time at activation (SPEC §5.2).
  final Duration clockOffset;
}

enum InstallationStatus { active, revoked, offline, failed }

class StatusCheck {
  const StatusCheck(this.status, {this.clockOffset, this.shortCode});

  final InstallationStatus status;

  /// The installation's SMS short code, when the server sent it.
  final String? shortCode;

  /// A fresh offset from the response's `Date` header, if there was one.
  final Duration? clockOffset;
}

/// Reference documents the server publishes in seed format.
typedef PublishedReference = ({
  JsonMap? rules,
  JsonMap? lists,
  List<JsonMap> profiles,
});

/// The few calls Collect makes before the sync engine exists (P6).
abstract interface class CollectApi {
  /// Throws [ApiFailure] (e.g. `expired_code`, `offline`).
  Future<Activation> activate({
    required String apiUrl,
    required String code,
    required String platform,
    required String appVersion,
  });

  /// The device registers itself (ADR-024): no code; testers on it are
  /// assigned to areas later. Throws [ApiFailure] (`offline`,
  /// `too_many_registrations`).
  Future<Activation> register({
    required String apiUrl,
    required String platform,
    required String appVersion,
    String? deviceLabel,
  });

  /// A signed call that tells whether the installation is still allowed.
  Future<StatusCheck> check(InstallationCredentials c, Duration clockOffset);

  /// Throws [ApiFailure].
  Future<PublishedReference> reference(
    InstallationCredentials c,
    Duration clockOffset,
  );

  /// Custom limits need a stakeholder (O2): signs the stakeholder in, sends
  /// the limit set as them, then signs them out again. Needs a connection.
  /// Throws [ApiFailure] (`invalid_credentials`, `must_change_password`,
  /// `stakeholder_required`, `offline`...).
  Future<void> createLimitSetAsStakeholder({
    required String apiUrl,
    required String username,
    required String password,
    required Map<String, Object?> profile,
  });
}

class HttpCollectApi implements CollectApi {
  HttpCollectApi({Dio Function(String baseUrl)? dio, DateTime Function()? now})
    : _dioFor = dio ?? _defaultDio,
      _now = now ?? DateTime.now;

  final Dio Function(String baseUrl) _dioFor;
  final DateTime Function() _now;

  static Dio _defaultDio(String baseUrl) => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(RequestActivityInterceptor());

  Dio _signed(InstallationCredentials c, Duration offset) {
    var prefix = Uri.parse(c.apiUrl).path;
    if (prefix.endsWith('/')) prefix = prefix.substring(0, prefix.length - 1);
    return _dioFor(c.apiUrl)
      ..interceptors.add(
        InstallationSigner(
          installationId: c.installationId,
          secret: c.secret,
          proxyPrefix: prefix,
          clockOffset: () => offset,
          now: _now,
        ),
      );
  }

  @override
  Future<Activation> activate({
    required String apiUrl,
    required String code,
    required String platform,
    required String appVersion,
  }) async {
    try {
      final r = await WaterCheckApi(_dioFor(apiUrl)).installations.activate(
        body: ActivateRequest(
          code: code,
          platform: platform,
          appVersion: appVersion,
        ),
      );
      final now = _now();
      return Activation(
        credentials: InstallationCredentials(
          installationId: r.installationId,
          secret: r.secret,
          apiUrl: apiUrl,
          areaId: r.area.id,
          areaCode: r.area.code,
          areaName: r.area.name,
          activatedAt: now,
          shortCode: r.shortCode,
        ),
        clockOffset: r.serverTime.difference(now),
      );
    } catch (e) {
      throw ApiFailure.from(e);
    }
  }

  @override
  Future<Activation> register({
    required String apiUrl,
    required String platform,
    required String appVersion,
    String? deviceLabel,
  }) async {
    try {
      final r = await WaterCheckApi(_dioFor(apiUrl)).installations.register(
        body: RegisterRequest(
          platform: platform,
          appVersion: appVersion,
          deviceLabel: deviceLabel,
        ),
      );
      final now = _now();
      return Activation(
        credentials: InstallationCredentials(
          installationId: r.installationId,
          secret: r.secret,
          apiUrl: apiUrl,
          areaId: '',
          areaCode: '',
          areaName: '',
          activatedAt: now,
          shortCode: r.shortCode,
        ),
        clockOffset: r.serverTime.difference(now),
      );
    } catch (e) {
      throw ApiFailure.from(e);
    }
  }

  @override
  Future<StatusCheck> check(
    InstallationCredentials c,
    Duration clockOffset,
  ) async {
    Future<StatusCheck> once(Duration offset) async {
      try {
        final r = await _signed(c, offset).get<Object?>('/v1/installations/me');
        return StatusCheck(
          InstallationStatus.active,
          clockOffset: _offsetFrom(r.headers),
        );
      } on DioException catch (e) {
        final failure = ApiFailure.from(e);
        final response = e.response;
        return StatusCheck(
          switch (failure.code) {
            'installation_revoked' => InstallationStatus.revoked,
            ApiFailure.offline => InstallationStatus.offline,
            _ => InstallationStatus.failed,
          },
          clockOffset: response == null ? null : _offsetFrom(response.headers),
        );
      }
    }

    final first = await once(clockOffset);
    // A wrong phone clock makes the signature stale: retry once with the
    // offset learned from the server's Date header.
    final fresh = first.clockOffset;
    if (first.status == InstallationStatus.failed &&
        fresh != null &&
        (fresh - clockOffset).abs() > const Duration(seconds: 60)) {
      return once(fresh);
    }
    return first;
  }

  @override
  Future<PublishedReference> reference(
    InstallationCredentials c,
    Duration clockOffset,
  ) async {
    try {
      final api = WaterCheckApi(_signed(c, clockOffset)).reference;
      JsonMap map(Object? o) => (o! as Map).cast<String, Object?>();
      final rules = map(await api.config(key: 'rules'));
      final lists = map(await api.config(key: 'lists'));
      final profiles = [
        for (final p in (await api.referenceProfiles()) as List) map(p),
      ];
      return (rules: rules, lists: lists, profiles: profiles);
    } catch (e) {
      throw ApiFailure.from(e);
    }
  }

  Duration? _offsetFrom(Headers headers) {
    final date = headers.value('date');
    if (date == null) return null;
    return parseHttpDate(date)?.difference(_now());
  }

  @override
  Future<void> createLimitSetAsStakeholder({
    required String apiUrl,
    required String username,
    required String password,
    required Map<String, Object?> profile,
  }) async {
    final dio = _dioFor(apiUrl);
    try {
      final login = await dio.post<Map<String, dynamic>>(
        '/v1/auth/login',
        data: {'username': username.trim(), 'password': password},
      );
      final tokens = login.data!;
      final refresh = tokens['refresh_token'] as String?;
      try {
        if (tokens['must_change_password'] == true) {
          throw const ApiFailure('must_change_password', status: 403);
        }
        final pushed = await dio.post<Map<String, dynamic>>(
          '/v1/sync/push',
          data: {
            'batch_id': const IdGenerator().next(),
            'changes': [
              {
                'entity': 'reference_standard',
                'op': 'insert',
                'id': profile['id'],
                'data': {...profile, 'via': 'collect'},
              },
            ],
          },
          options: Options(
            headers: {'Authorization': 'Bearer ${tokens['access_token']}'},
          ),
        );
        final result = (pushed.data!['results'] as List).single as Map;
        if (result['status'] != 'applied' && result['status'] != 'duplicate') {
          throw ApiFailure('${result['reason'] ?? 'rejected'}', status: 422);
        }
      } finally {
        // The stakeholder's session ends with this one change.
        if (refresh != null) {
          unawaited(
            dio
                .post<void>('/v1/auth/logout', data: {'refresh_token': refresh})
                .then((_) {}, onError: (_) {}),
          );
        }
      }
    } catch (e) {
      throw ApiFailure.from(e);
    }
  }
}

const _months = {
  'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, //
  'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
};

/// Parses an RFC 7231 date such as `Sat, 10 Oct 2026 10:52:59 GMT`
/// (`dart:io`'s HttpDate is not available on the web).
DateTime? parseHttpDate(String value) {
  final m = RegExp(
    r'^\w{3}, (\d{2}) (\w{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
  ).firstMatch(value.trim());
  final month = m == null ? null : _months[m.group(2)];
  if (m == null || month == null) return null;
  return DateTime.utc(
    int.parse(m.group(3)!),
    month,
    int.parse(m.group(1)!),
    int.parse(m.group(4)!),
    int.parse(m.group(5)!),
    int.parse(m.group(6)!),
  );
}

/// Accepts a typed code (any case, with spaces or dashes) or the content of
/// an activation QR code: `watercheck://activate?code=…&server=…`.
({String code, String? server})? parseActivationInput(String raw) {
  final text = raw.trim();
  final uri = Uri.tryParse(text);
  if (uri != null && uri.scheme == 'watercheck') {
    final code = uri.queryParameters['code'];
    final c = code == null ? null : normaliseActivationCode(code);
    return c == null ? null : (code: c, server: uri.queryParameters['server']);
  }
  final c = normaliseActivationCode(text);
  return c == null ? null : (code: c, server: null);
}

/// `k7qm rt4w-9xhb` → `K7QM-RT4W-9XHB`; null if it cannot be a code.
String? normaliseActivationCode(String raw) {
  final chars = raw.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  if (chars.length != 12) return null;
  return '${chars.substring(0, 4)}-${chars.substring(4, 8)}-'
      '${chars.substring(8)}';
}
