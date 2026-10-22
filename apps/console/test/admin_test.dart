import 'dart:convert';
import 'dart:typed_data';

import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_console/features/admin/admin_api.dart';

import 'support/harness.dart';

/// A scripted admin server: answers by method and path, records requests.
class _AdminServer implements HttpClientAdapter {
  final requests = <(String, String, Object?)>[];
  final users = <Map<String, Object?>>[];
  var revoked = false;
  var archived = false;

  Map<String, Object?> _area(String level, String name) => {
    'id': 'a-$level',
    'code': 'C-$level',
    'name': name,
    'level': level,
  };

  Object? _answer(String method, String path, Object? body) {
    switch ((method, path)) {
      case ('GET', '/v1/admin/users'):
        return users;
      case ('POST', '/v1/admin/users'):
        final b = body! as Map<String, Object?>;
        final user = {
          'id': 'u-${users.length}',
          'username': b['username'],
          'full_name': b['full_name'],
          'organisation': null,
          'position': null,
          'phone': null,
          'email': null,
          'role': b['role'],
          'is_active': true,
          'must_change_password': true,
          'locked': false,
          'last_sign_in_at': null,
          'created_at': '2026-10-12T08:00:00Z',
          'areas': [
            for (final _ in (b['area_ids'] as List? ?? const []))
              _area('district', 'Abim'),
          ],
          'responsibilities': b['responsibilities'] ?? <String>[],
        };
        users.add(user);
        return {'user': user, 'temporary_password': 'Temp-Pass-0042'};
      case ('GET', '/v1/admin/installations'):
        return [
          {
            'id': 'i-1',
            'area': _area('village', 'Entebbe'),
            'platform': 'android',
            'app_version': '1.0.0',
            'short_code': 'K7QM',
            'activated_at': '2026-10-10T08:00:00Z',
            'last_seen_at': '2026-10-12T07:00:00Z',
            'revoked_at': revoked ? '2026-10-12T08:00:00Z' : null,
            'collectors_seen': 2,
            'tests': 14,
            'label': null,
            'archived': archived,
          },
        ];
      case ('GET', '/v1/admin/activation-codes'):
        return <Object>[];
      case ('POST', '/v1/admin/installations/i-1/revoke'):
        revoked = true;
        return null;
      case ('POST', '/v1/admin/archive'):
        archived = true;
        return {
          'batch_id': 'b-1',
          'counts': {'installation': 1, 'collector': 2, 'test_session': 14},
        };
      case ('GET', '/v1/admin/archive'):
        return [
          if (archived)
            {
              'batch_id': 'b-1',
              'entity': 'installation',
              'record_id': 'i-1',
              'label': 'K7QM',
              'reason': 'test phone',
              'archived_by': 'Example Admin',
              'archived_at': '2026-10-22T08:00:00Z',
              'counts': {'installation': 1, 'test_session': 14},
            },
        ];
      case ('POST', '/v1/admin/archive/b-1/restore'):
        archived = false;
        return {'installation': 1, 'test_session': 14};
      case ('GET', final p) when p.endsWith('/chain'):
        return {
          'levels': [
            {
              'area': _area('village', 'Entebbe'),
              'people': [
                {
                  'id': 'u-9',
                  'full_name': 'Village VHT',
                  'responsibilities': <String>[],
                  'is_active': true,
                },
              ],
            },
            {'area': _area('district', 'Abim'), 'people': <Object>[]},
          ],
          'first_notice': _area('village', 'Entebbe'),
          'gaps': [_area('district', 'Abim')],
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

void main() {
  testWidgets('IT admin: create a person, see the password once; revoke a '
      'phone; the chain shows the gaps', (tester) async {
    final server = _AdminServer();
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = server;
    final env = ConsoleTestEnv(cookieMode: true)
      ..extraOverrides.add(
        adminApiProvider.overrideWithValue(WaterCheckApi(dio)),
      );
    env.api.sessionFor('admin@example.org');
    final db = await pumpConsole(tester, env: env);
    await tester.tap(find.text('Admin').last);
    await settle(tester);

    // People: create a district officer.
    await tester.tap(find.text('People'));
    await settle(tester);
    await tester.tap(find.text('New person'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Full name'),
      'District Officer',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Username (email or phone)'),
      'officer2@example.org',
    );
    await tester.tap(find.text('Add or change areas'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'Abim');
    await settle(tester);
    await tester.tap(find.textContaining('Abim (district').first);
    await tester.pump();
    await tester.tap(find.text('Use 1 areas'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await settle(tester);
    expect(find.text('Temp-Pass-0042'), findsOneWidget);
    final created = server.requests.firstWhere((r) => r.$1 == 'POST');
    expect((created.$3! as Map)['area_ids'], hasLength(1));
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect(find.text('District Officer'), findsOneWidget);
    expect(find.text('Not signed in yet'), findsOneWidget);

    // Phones: revoke one.
    await tester.tap(find.text('Admin').last);
    await settle(tester);
    await tester.tap(find.text('Collect phones'));
    await settle(tester);
    expect(find.textContaining('2 collectors, 14 tests'), findsOneWidget);
    await tester.tap(find.byTooltip('More actions'));
    await settle(tester);
    await tester.tap(find.text('Revoke').last);
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Revoke'));
    await settle(tester);
    expect(
      server.requests.any((r) => r.$2 == '/v1/admin/installations/i-1/revoke'),
      isTrue,
    );
    expect(find.textContaining('Revoked'), findsOneWidget);

    // Archive the phone (ADR-018): a reason, then everything it took.
    await tester.tap(find.byTooltip('More actions'));
    await settle(tester);
    await tester.tap(find.text('Archive…'));
    await settle(tester);
    expect(find.textContaining('The phone is revoked'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Reason'),
      'test phone',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await settle(tester);
    expect(
      find.textContaining('Archived: 1 phone, 2 collectors, 14 tests'),
      findsOneWidget,
    );
    final sent = server.requests.lastWhere((r) => r.$2 == '/v1/admin/archive');
    expect((sent.$3! as Map)['reason'], 'test phone');
    expect(find.textContaining('archived'), findsWidgets);

    // Admin › Archived lists it; Restore brings it back.
    await tester.tap(find.text('Admin').last);
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Archived'), 100);
    await tester.tap(find.text('Archived'));
    await settle(tester);
    expect(find.text('K7QM'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Restore'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    await settle(tester);
    expect(
      server.requests.any((r) => r.$2 == '/v1/admin/archive/b-1/restore'),
      isTrue,
    );
    expect(find.text('Nothing is archived.'), findsOneWidget);
    await disposeConsole(tester, db);
  });
}
