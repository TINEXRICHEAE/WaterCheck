import 'dart:convert';
import 'dart:typed_data';

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_console/features/admin/admin_api.dart';

import 'support/harness.dart';

/// A scripted server for the IT admin's settings: records what is sent.
class _ConfigServer implements HttpClientAdapter {
  final requests = <(String, String, Object?)>[];
  var security = <String, Object?>{
    'max_failed_logins': 5,
    'lockout_minutes': 15,
    'password_min_length': 10,
    'console_idle_minutes': 30,
  };

  Object? _answer(String method, String path, Object? body) {
    switch ((method, path)) {
      case ('GET', '/v1/admin/health'):
        return {
          'database': true,
          'worker_last_job_at': '2026-10-12T07:00:00Z',
          'jobs_queued': 2,
          'jobs_overdue': 0,
          'jobs_failed_24h': 0,
          'notifications_failed_24h': 1,
          'phones_active_7d': 3,
          'phones_total': 4,
          'app_versions': {'1.0.0': 4},
          'records_received_24h': 17,
          'sync_conflicts_open': 0,
          'photos': 5,
          'photo_bytes': 3145728,
          'last_backup_at': null,
        };
      case ('GET', '/v1/admin/audit'):
        return [
          {
            'id': 1,
            'at': '2026-10-12T08:00:00Z',
            'actor_id': 'u-1',
            'actor_name': 'Lead Officer',
            'installation_id': null,
            'platform': 'console',
            'action': 'reference_profile.created',
            'entity': 'reference_standard',
            'entity_id': 'p-1',
            'after': {'reason': 'Lab check'},
          },
        ];
      case ('GET', '/v1/admin/security'):
        return security;
      case ('PUT', '/v1/admin/security'):
        security = (body! as Map).cast();
        return security;
      case ('GET', '/v1/admin/routing'):
        return {
          'responsibilities': [
            {'code': 'health_inspector', 'name': 'Health Inspector'},
          ],
          'triggers': ['ecoli', 'unsafe'],
          'rules': [
            {
              'trigger_rule': 'ecoli',
              'responsibility_code': 'health_inspector',
            },
          ],
        };
      case ('PUT', '/v1/admin/routing'):
        return null;
      case ('GET', '/v1/admin/parameters/pending'):
        return [
          {
            'code': 'custom:1',
            'name': 'Silica',
            'category_code': 'chemical',
            'default_unit': 'mg/L',
            'value_type': 'numeric',
            'collector_name': 'Field Collector',
            'readings': 2,
          },
        ];
      case ('POST', '/v1/admin/parameters/custom:1/review'):
        return null;
      case ('GET', '/v1/admin/response-cards'):
        return [
          {
            'id': 'c-1',
            'trigger_rule': 'unsafe',
            'audience': 'collector',
            'version': 1,
            'content': {
              'title': 'Readings outside the safe limits',
              'actions': ['Test again.'],
              'report_to': ['Health Inspector'],
              'report_note': null,
            },
          },
        ];
      case ('PUT', '/v1/admin/response-cards/c-1'):
        return {
          'id': 'c-1',
          'trigger_rule': 'unsafe',
          'audience': 'collector',
          'version': 2,
          'content': body,
        };
    }
    throw StateError('unexpected $method $path');
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = options.data;
    final decoded = body is String && body.isNotEmpty ? jsonDecode(body) : body;
    final json = decoded is Map ? decoded.cast<String, Object?>() : decoded;
    requests.add((options.method, options.path, json));
    final answer = _answer(options.method, options.path, json);
    return ResponseBody.fromString(
      answer == null ? '' : jsonEncode(answer),
      answer == null ? 204 : 200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _open(WidgetTester tester, String entry) async {
  await tester.tap(find.text('Admin').last);
  await settle(tester);
  await tester.scrollUntilVisible(find.text(entry), 100);
  await tester.tap(find.text(entry));
  await settle(tester);
}

void main() {
  testWidgets('IT admin settings: health and audit; security in range; '
      'routing; parameter review; response card versions', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final server = _ConfigServer();
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = server;
    final env = ConsoleTestEnv(cookieMode: true)
      ..extraOverrides.add(
        adminApiProvider.overrideWithValue(WaterCheckApi(dio)),
      );
    env.api.sessionFor('admin@example.org');
    final db = await pumpConsole(tester, env: env);

    // System: health and the audit log.
    await _open(tester, 'System');
    expect(find.text('3 of 4'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);
    expect(find.textContaining('Not set up yet'), findsOneWidget);
    expect(find.textContaining('Lead Officer'), findsOneWidget);

    // Security: out of range blocks saving; in range is sent.
    await _open(tester, 'Sign-in security');
    final failed = find.byKey(const ValueKey('security-max_failed_logins'));
    await tester.enterText(failed, '1');
    await tester.pump();
    expect(find.text('Outside the allowed range'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'))
          .onPressed,
      isNull,
    );
    await tester.enterText(failed, '4');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);
    expect(server.security['max_failed_logins'], 4);

    // Routing: add "unsafe" for the health inspector.
    await _open(tester, 'Alert routing');
    await tester.tap(
      find.byKey(const ValueKey('route-unsafe-health_inspector')),
    );
    await tester.pump();
    await tester.tap(find.text('Save routing'));
    await settle(tester);
    final routing = server.requests.lastWhere(
      (r) => r.$1 == 'PUT' && r.$2 == '/v1/admin/routing',
    );
    expect(((routing.$3! as Map)['rules'] as List), hasLength(2));

    // A parameter added in the field: approved.
    await _open(tester, 'New parameters');
    expect(find.textContaining('Field Collector'), findsOneWidget);
    await tester.tap(find.text('Approve'));
    await settle(tester);
    final review = server.requests.lastWhere((r) => r.$2.endsWith('/review'));
    expect('${(review.$3! as Map)['action']}', 'approve');

    // A response card: a new version with new steps.
    await _open(tester, 'Response cards');
    await tester.tap(find.byTooltip('Edit card'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'What to do'),
      'Test again.\nBoil the water.',
    );
    await tester.tap(find.text('Save new version'));
    await settle(tester);
    final card = server.requests.lastWhere((r) => r.$1 == 'PUT');
    expect((card.$3! as Map)['actions'], ['Test again.', 'Boil the water.']);
    expect((card.$3! as Map)['report_to'], ['Health Inspector']);
    await disposeConsole(tester, db);
  });
}
