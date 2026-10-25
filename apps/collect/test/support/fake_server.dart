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

  /// The collector a recovery code brings back (`/v1/collectors/recover`);
  /// the code `ABCDE23456` works once.
  final recoverable = <String, Object?>{
    'key': '0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f0c0de',
    'full_name': 'Baluku Joseph',
    'phone': '+256772123456',
    'collector_type': 'vht',
    'village': 'Kitanaba',
    'parish': 'Nawangoma',
    'subcounty': 'Butagaya',
    'district': 'Jinja',
    'profile_version': 2,
  };
  final _recoverable = <String, bool>{'ABCDE23456': true};

  /// Sources the online search finds (`/v1/sources/search`).
  final searchHits = <Map<String, Object?>>[];

  /// Places the online search finds (`/v1/places/search`, ADR-028).
  final placeHits = <Map<String, Object?>>[];

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
      // A device registers itself (ADR-024).
      ('POST', '/v1/installations/register') => () {
        registrations++;
        return _json(201, {
          'installation_id': installationId,
          'secret': secret,
          'server_time': serverTime.toIso8601String(),
          'short_code': '7Q2K',
        });
      }(),
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
      ('POST', '/v1/collectors/recover') =>
        _recoverable.remove(
                  _body(
                    options,
                  )['code'].toString().replaceAll('-', '').toUpperCase(),
                ) ==
                null
            ? _json(404, {'detail': 'invalid_code'})
            : _json(200, {
                'collector_key': recoverable['key'],
                'snapshot': recoverable,
              }),
      // A tester's area and devices (ADR-024).
      (_, final p) when p.startsWith('/v1/collectors/') => _tester(options, p),
      ('GET', '/v1/sources/search') => _json(200, [
        for (final h in searchHits)
          if ('${h['code']} ${h['name']} ${h['village']}'
              .toLowerCase()
              .contains(options.uri.queryParameters['q']!.toLowerCase()))
            h,
      ]),
      ('GET', '/v1/places/search') => _json(200, [
        for (final h in placeHits)
          if ('${h['name']}'.toLowerCase().contains(
            options.uri.queryParameters['q']!.toLowerCase(),
          ))
            h,
      ]),
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

  /// Devices that registered themselves (ADR-024).
  var registrations = 0;

  /// Assignment codes that work, and the areas assigned with them.
  final assignmentCodes = {'ASGN-ASGN-ASGN': 'Abim'};
  final assigned = <String>[];

  /// The other device using the tester's profile, and the confirmation.
  var otherSignedOut = false;
  String? confirmedPhone;
  var signedOutHere = false;
  var closed = false;
  static const confirmCode = '482915';

  ResponseBody _tester(RequestOptions options, String path) {
    final parts = path.split('/'); // ['', 'v1', 'collectors', key, ...]
    final rest = parts.skip(4).join('/');
    Map<String, Object?> assignment(String area) => {
      'id': 'as-$area',
      'collector_key': parts[3],
      'area_id': 'area-$area',
      'area': area,
      'level': 'district',
      'assigned_at': '2026-10-24T08:00:00Z',
      'by_code': true,
    };
    return switch ((options.method, rest)) {
      ('GET', 'assignments') => _json(200, [
        for (final a in assigned) assignment(a),
      ]),
      ('POST', 'assign') => () {
        final area = assignmentCodes[_body(options)['code']];
        if (area == null) return _json(404, {'detail': 'invalid_code'});
        if (!assigned.contains(area)) assigned.add(area);
        return _json(200, [for (final a in assigned) assignment(a)]);
      }(),
      // Profile (ADR-025): contacts with a code, leaving this device.
      ('POST', 'contacts') => _json(201, {
        'id': 'c-1',
        'channel': _body(options)['channel'],
        'value': _body(options)['value'],
        'expires_at': '2026-10-25T08:00:00Z',
      }),
      ('POST', 'contacts/c-1/confirm') =>
        _body(options)['code'] == confirmCode
            ? () {
                confirmedPhone = '+256772123456';
                return ResponseBody.fromString('', 204);
              }()
            : _json(400, {'detail': 'wrong_code'}),
      ('GET', 'contacts/status') => _json(200, {
        'phone': confirmedPhone,
        'email': null,
      }),
      ('POST', 'sign-out-here') => () {
        signedOutHere = true;
        return ResponseBody.fromString('', 204);
      }(),
      ('POST', 'close') => () {
        closed = true;
        return ResponseBody.fromString('', 204);
      }(),
      ('POST', 'recovery-code/own') => _json(201, {
        'code': 'K7QMR-T4W9X',
        'full_name': 'Example Collector',
      }),
      ('GET', 'devices') => _json(200, [
        for (final (id, label, mine, out) in [
          (installationId, 'This phone', true, false),
          ('other-device', 'Old phone', false, otherSignedOut),
        ])
          {
            'installation_id': id,
            'platform': 'android',
            'label': label,
            'short_code': null,
            'signed_in_via': mine ? 'created' : 'own_code',
            'first_seen_at': '2026-10-20T08:00:00Z',
            'last_seen_at': '2026-10-23T08:00:00Z',
            'signed_out_at': out ? '2026-10-24T08:00:00Z' : null,
            'this_device': mine,
          },
      ]),
      ('POST', 'devices/sign-out') => _json(201, {
        'request_id': 'req-1',
        'expires_at': '2026-10-25T08:00:00Z',
      }),
      ('POST', 'devices/sign-out/req-1/confirm') =>
        _body(options)['code'] == confirmCode
            ? () {
                otherSignedOut = true;
                return _json(200, {'signed_out': 1});
              }()
            : _json(400, {'detail': 'wrong_code'}),
      _ => _json(404, {'detail': 'not_found'}),
    };
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

  /// The JSON body, whether the signer left it as text, bytes or a map.
  Map<String, Object?> _body(RequestOptions options) {
    final data = options.data;
    final raw = switch (data) {
      final String s => s,
      final List<int> b => utf8.decode(b),
      _ => jsonEncode(data),
    };
    return (jsonDecode(raw) as Map).cast<String, Object?>();
  }

  ResponseBody _push(RequestOptions options, {bool asStakeholder = false}) {
    final body = _body(options);
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
