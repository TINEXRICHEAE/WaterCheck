import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/features/activation/collect_api.dart';

/// Runs only against a running dev stack, as an IT admin:
///   WC_LIVE_API=http://localhost/api WC_LIVE_USER=… WC_LIVE_PASSWORD=…
void main() {
  final live = Platform.environment['WC_LIVE_API'];

  test('live: activate, check, download reference data, revoke', () async {
    final admin = Dio(BaseOptions(baseUrl: live!));
    final tokens = await WaterCheckApi(admin).auth.login(
      body: LoginRequest(
        username: Platform.environment['WC_LIVE_USER']!,
        password: Platform.environment['WC_LIVE_PASSWORD']!,
      ),
    );
    admin.options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    final code = await WaterCheckApi(admin).installations.newActivationCode(
      body: const NewCodeRequest(areaCode: 'ABIM-ENT', maxInstallations: 1),
    );

    final api = HttpCollectApi();
    final a = await api.activate(
      apiUrl: live,
      code: code.code.toLowerCase().replaceAll('-', ' '),
      platform: 'test',
      appVersion: '0.1.0',
    );
    expect(a.credentials.areaCode, 'ABIM-ENT');
    expect(a.clockOffset.abs(), lessThan(const Duration(minutes: 1)));

    // The code allowed one installation only.
    await expectLater(
      api.activate(
        apiUrl: live,
        code: code.code,
        platform: 'test',
        appVersion: '0.1.0',
      ),
      throwsA(isA<ApiFailure>().having((f) => f.code, 'code', 'code_used_up')),
    );

    // A phone clock two hours fast is corrected from the Date header.
    final status = await api.check(a.credentials, const Duration(hours: -2));
    expect(status.status, InstallationStatus.active);
    expect(status.clockOffset!.abs(), lessThan(const Duration(minutes: 1)));

    final published = await api.reference(a.credentials, a.clockOffset);
    expect(published.rules!['version'], isA<int>());
    expect(published.profiles, hasLength(2));

    await WaterCheckApi(admin).installations
        .revokeInstallation(installationId: a.credentials.installationId);
    final after = await api.check(a.credentials, a.clockOffset);
    expect(after.status, InstallationStatus.revoked);
  }, skip: live == null ? 'set WC_LIVE_API to run against a dev stack' : false);
}
