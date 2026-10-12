import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A fake WaterCheck API behind Dio, so tests exercise the real client,
/// signing and error handling without a network (P5 gate: "with the fake
/// server").
class FakeServer implements HttpClientAdapter {
  FakeServer({DateTime? serverTime})
    : serverTime = serverTime ?? DateTime.utc(2026, 10, 10, 9);

  DateTime serverTime;

  /// Activation codes the server knows: code → outcome (`ok`,
  /// `expired_code`, `code_used_up`).
  final codes = <String, String>{'K7QM-RT4W-9XHB': 'ok'};

  /// Revoked installations.
  final revoked = <String>{};

  /// When true, every call fails as if there were no network.
  bool offline = false;

  /// Published rules version (seed is 2): a newer one is imported.
  int rulesVersion = 3;

  final requests = <RequestOptions>[];

  /// Records received through `/v1/sync/push`, by entity.
  final pushed = <Map<String, Object?>>[];

  /// Record IDs the server refuses, with the reason.
  final reject = <String, String>{};

  /// Photo bytes received per attachment, and the ones completed.
  final uploads = <String, BytesBuilder>{};
  final uploaded = <String, Uint8List>{};

  /// Rows served on the next pull of each stream.
  final serve = <String, List<Map<String, Object?>>>{};

  static const installationId = '0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f00001';
  static const secret = 'fake-server-test-secret';

  Dio dioFor(String baseUrl) =>
      Dio(BaseOptions(baseUrl: baseUrl))..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline (fake)',
      );
    }
    final path = options.uri.path.replaceFirst('/api', '');
    final signed = options.headers['X-Signature'] != null;
    final id = options.headers['X-Installation-Id'] as String?;
    final bearer = options.headers['Authorization'] as String?;
    return switch ((options.method, path)) {
      ('POST', '/v1/installations/activate') => _activate(options),
      ('POST', '/v1/auth/login') => _login(options),
      ('POST', '/v1/auth/logout') => ResponseBody.fromString('', 204),
      // A stakeholder's own push (custom limits, O2): bearer, not signed.
      ('POST', '/v1/sync/push') when bearer == 'Bearer stakeholder-token' =>
        _push(options, asStakeholder: true),
      _ when !signed => _json(401, {'detail': 'unsigned_request'}),
      _ when revoked.contains(id) => _json(403, {
        'detail': 'installation_revoked',
      }),
      ('GET', '/v1/installations/me') => _json(200, {
        'installation_id': id,
        'area': _area,
        'short_code': '7Q2K',
      }),
      ('GET', '/v1/reference/config/rules') => _json(
        200,
        _seed('rules.json')..['version'] = rulesVersion,
      ),
      ('GET', '/v1/reference/config/lists') => _json(200, _seed('lists.json')),
      ('GET', '/v1/reference/profiles') => _json(200, <Object?>[]),
      ('POST', '/v1/sync/push') => _push(options),
      (_, final p) when p.startsWith('/v1/attachments/') => _attachment(
        options,
        p,
      ),
      ('GET', '/v1/sync/pull') => _pull(options),
      _ => _json(404, {'detail': 'not_found'}),
    };
  }

  static const _area = {
    'id': 'ad625def-3111-5ddd-835f-b24118d37f01',
    'code': 'ABIM-ENT',
    'name': 'Entebbe',
    'level': 'village',
  };

  ResponseBody _activate(RequestOptions options) {
    final data = options.data;
    final body = (data is String ? jsonDecode(data) : data) as Map;
    final outcome = codes[body['code']];
    if (outcome == null) return _json(404, {'detail': 'invalid_code'});
    if (outcome != 'ok') {
      return _json(outcome == 'expired_code' ? 410 : 409, {'detail': outcome});
    }
    return _json(200, {
      'installation_id': installationId,
      'secret': secret,
      'area': _area,
      'server_time': serverTime.toIso8601String(),
      'short_code': '7Q2K',
    });
  }

  /// The stakeholder who may approve custom limits on a phone (O2).
  static const stakeholder = ('officer@example.org', 'BoreholeWater2026');

  /// Changes pushed by a signed-in stakeholder rather than the phone.
  final pushedByStakeholder = <Map<String, Object?>>[];

  ResponseBody _login(RequestOptions options) {
    final body = (options.data as Map).cast<String, Object?>();
    if ((body['username'], body['password']) != stakeholder) {
      return _json(401, {'detail': 'invalid_credentials'});
    }
    return _json(200, {
      'access_token': 'stakeholder-token',
      'refresh_token': 'stakeholder-refresh',
      'token_type': 'bearer',
      'expires_in': 900,
      'must_change_password': false,
    });
  }

  ResponseBody _push(RequestOptions options, {bool asStakeholder = false}) {
    final data = options.data;
    final raw = switch (data) {
      final String s => s,
      final List<int> b => utf8.decode(b),
      _ => jsonEncode(data),
    };
    final body = (jsonDecode(raw) as Map).cast<String, Object?>();
    final changes = (body['changes']! as List).cast<Map<String, Object?>>();
    (asStakeholder ? pushedByStakeholder : pushed).addAll(changes);
    return _json(200, {
      'batch_id': body['batch_id'],
      'server_time': serverTime.toIso8601String(),
      'results': [
        for (final c in changes)
          {
            'id': c['id'],
            'entity': c['entity'],
            'status': reject.containsKey(c['id']) ? 'rejected' : 'applied',
            'server_version': null,
            'reason': reject[c['id']],
          },
      ],
    });
  }

  ResponseBody _attachment(RequestOptions options, String path) {
    final parts = path.split('/'); // ['', 'v1', 'attachments', id, action]
    final id = parts[3];
    final meta = pushed.lastWhere(
      (c) => c['entity'] == 'attachment' && c['id'] == id,
      orElse: () => {},
    );
    if (meta.isEmpty) return _json(404, {'detail': 'not_found'});
    final size = ((meta['data']! as Map)['bytes']! as num).toInt();
    final have = uploads.putIfAbsent(id, BytesBuilder.new);
    Map<String, Object?> state([String? status]) => {
      'received_bytes': have.length,
      'bytes': size,
      'status': status ?? (uploaded.containsKey(id) ? 'uploaded' : 'pending'),
      'reason': null,
    };
    switch ((options.method, parts[4])) {
      case ('GET', 'upload'):
        return _json(200, state());
      case ('PUT', 'upload'):
        final offset = int.parse(options.uri.queryParameters['offset']!);
        if (offset != have.length) {
          return _json(409, {
            'detail': 'offset_mismatch',
            'received_bytes': have.length,
          });
        }
        have.add(options.data as List<int>);
        return _json(200, state());
      case ('POST', 'complete'):
        uploaded[id] = have.toBytes();
        return _json(200, state('uploaded'));
    }
    return _json(404, {'detail': 'not_found'});
  }

  ResponseBody _pull(RequestOptions options) {
    final stream = options.uri.queryParameters['stream']!;
    final rows = serve.remove(stream) ?? const [];
    return _json(200, {
      'changes': [
        for (final (i, r) in rows.indexed)
          {
            'entity': r['_entity'],
            'op': 'upsert',
            'id': r['id'] ?? r['code'],
            'server_seq': i + 1,
            'data': {...r}..remove('_entity'),
          },
      ],
      'next_cursor': '1.${rows.length}',
      'has_more': false,
      'server_time': serverTime.toIso8601String(),
    });
  }

  Map<String, Object?> _seed(String name) =>
      (jsonDecode(File('../../infra/seed/$name').readAsStringSync()) as Map)
          .cast();

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      'date': [HttpDate.format(serverTime)],
    },
  );

  @override
  void close({bool force = false}) {}
}
