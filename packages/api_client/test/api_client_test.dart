import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  // Known vectors shared with backend/tests/test_signing.py.
  test('signing matches the server algorithm', () {
    final signer = InstallationSigner(
      installationId: 'inst',
      secret: 'secret',
      now: () => DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );
    final get = signer.headersFor('get', '/v1/installations/me', const []);
    expect(get['X-Timestamp'], '1700000000');
    expect(
      get['X-Signature'],
      '5bc7f73b822f76fa98f4aedce19b03ffadc8f6b0ba723eb2ec20f3927c257502',
    );
    final post = signer.headersFor(
      'POST',
      '/v1/sync/push',
      '{"a":1}'.codeUnits,
    );
    expect(
      post['X-Signature'],
      'a845dcb8bfb592410e47b4209d1cb111bf700b6a7ec4bca7f08aa961b3cc8031',
    );
    expect(get['X-Installation-Id'], 'inst');
    expect(get.containsKey('X-Nonce'), isFalse);
    // With a query string and a nonce (ADR-011).
    final pull = signer.headersFor(
      'GET',
      '/v1/sync/pull?stream=scope&limit=500',
      const [],
      nonce: '0123456789abcdef',
    );
    expect(
      pull['X-Signature'],
      '0fbf51d3814aa5ff2a58826da1cc8fd1c79239172e3cbf58648be47d6304978b',
    );
    expect(pull['X-Nonce'], '0123456789abcdef');
  });

  test('the interceptor signs the query string with a fresh nonce', () {
    final signer = InstallationSigner(installationId: 'inst', secret: 's');
    final seen = <Map<String, dynamic>>[];
    for (var i = 0; i < 2; i++) {
      final options = RequestOptions(
        baseUrl: 'http://x/api',
        path: '/v1/sync/pull',
        queryParameters: {'stream': 'scope', 'limit': 500},
      );
      signer.onRequest(options, _Capture((o) => seen.add(o.headers)));
    }
    expect(seen[0]['X-Nonce'], isNot(seen[1]['X-Nonce']));
    expect(seen[0]['X-Signature'], isNot(seen[1]['X-Signature']));
    final ts = seen[0]['X-Timestamp'] as String;
    final expected = signer.headersFor(
      'GET',
      '/v1/sync/pull?stream=scope&limit=500',
      const [],
      nonce: seen[0]['X-Nonce'] as String,
    );
    if (expected['X-Timestamp'] == ts) {
      expect(seen[0]['X-Signature'], expected['X-Signature']);
    }
  });

  test('clock offset corrects the timestamp', () {
    final signer = InstallationSigner(
      installationId: 'inst',
      secret: 'secret',
      now: () => DateTime.fromMillisecondsSinceEpoch(1700000000000),
      clockOffset: () => const Duration(hours: -1),
    );
    expect(
      signer.headersFor('GET', '/x', const [])['X-Timestamp'],
      '1699996400',
    );
  });

  test('failures carry the server code, or offline', () {
    final options = RequestOptions(path: '/v1/installations/activate');
    final expired = ApiFailure.from(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 410,
          data: {'detail': 'expired_code'},
        ),
      ),
    );
    expect(expired.code, 'expired_code');
    expect(expired.status, 410);
    final offline = ApiFailure.from(
      DioException.connectionError(requestOptions: options, reason: 'no route'),
    );
    expect(offline.isOffline, isTrue);
    expect(ApiFailure.from(StateError('x')).code, ApiFailure.unexpected);
  });

  // Runs only against a running dev stack:
  //   WC_LIVE_API=http://localhost/api WC_LIVE_USER=... WC_LIVE_PASSWORD=...
  final live = Platform.environment['WC_LIVE_API'];
  test('live smoke test: sign in, activate, signed request', () async {
    final dio = Dio(BaseOptions(baseUrl: live!));
    final api = WaterCheckApi(dio);
    final tokens = await api.auth.login(
      body: LoginRequest(
        username: Platform.environment['WC_LIVE_USER']!,
        password: Platform.environment['WC_LIVE_PASSWORD']!,
      ),
    );
    expect(tokens.mustChangePassword, isFalse);
    dio.options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    final me = await api.auth.me();
    expect(me.role, 'it_admin');
    final code = await api.installations.newActivationCode(
      body: const NewCodeRequest(areaCode: 'ABIM-ENT', maxInstallations: 1),
    );
    final activation = await Dio(BaseOptions(baseUrl: live))
        .post<Map<String, dynamic>>(
          '/v1/installations/activate',
          data: {'code': code.code, 'platform': 'dart-smoke'},
        );
    final phone = Dio(BaseOptions(baseUrl: live))
      ..interceptors.add(
        InstallationSigner(
          installationId: activation.data!['installation_id'] as String,
          secret: activation.data!['secret'] as String,
        ),
      );
    final inst = await WaterCheckApi(phone).installations.installationMe();
    expect(inst.area?.code, 'ABIM-ENT');
    final catalogue = await WaterCheckApi(phone).reference.catalogue();
    expect(catalogue.parameters, hasLength(42));
  }, skip: live == null ? 'set WC_LIVE_API to run against a dev stack' : false);
}

class _Capture extends RequestInterceptorHandler {
  _Capture(this.onNext);

  final void Function(RequestOptions) onNext;

  @override
  void next(RequestOptions requestOptions) => onNext(requestOptions);
}
