import 'dart:convert';

import 'package:data/data.dart';
import 'package:data/src/db/database.dart'
    show AlertsCompanion, ConfigDocumentsCompanion, OutboxCompanion;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/app/router.dart';
import 'package:watercheck_collect/features/alerts/sms_fallback.dart';

import 'support/harness.dart';

const _village = 'ad625def-3111-5ddd-835f-b24118d37f01';
const _alertId = '01a1aaaa-0000-7000-8000-0000000000a1';
final _opened = DateTime.utc(2026, 10, 10, 6);

class FakeComposer implements SmsComposer {
  final sent = <(String, String)>[];

  @override
  Future<bool> open(String number, String body) async {
    sent.add((number, body));
    return true;
  }
}

Future<void> _stuckAlert(
  AppDatabase db, {
  String gateway = '+256700999000',
}) async {
  final collector = (await DriftCollectorProfileRepository(
    db,
  ).watchActive().first).first;
  final source = await DriftSourceRepository(db).create(
    const NewSource(
      villageId: _village,
      code: 'ABIM-ENT-003',
      sourceType: 'borehole',
    ),
    SubmissionOrigin.collect(
      installationId: '0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f00001',
      collector: collector,
    ),
  );
  await db
      .into(db.alerts)
      .insert(
        AlertsCompanion.insert(
          id: _alertId,
          sourceId: source.id,
          triggerRule: 'unsafe',
          openedAt: _opened,
        ),
      );
  await db
      .into(db.outbox)
      .insert(
        OutboxCompanion.insert(
          entity: 'alert',
          entityId: _alertId,
          op: 'insert',
          payload: '{}',
          createdAt: _opened,
        ),
      );
  await db
      .into(db.configDocuments)
      .insertOnConflictUpdate(
        ConfigDocumentsCompanion.insert(
          key: 'notifications',
          version: 1,
          document: jsonEncode({
            'version': 1,
            'sms_fallback': {'after_hours': 6, 'gateway_number': gateway},
          }),
        ),
      );
}

Future<void> _openAlert(WidgetTester tester) async {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(Scaffold).first),
  );
  container.read(routerProvider).go('/alerts/$_alertId');
  await settle(tester);
}

void main() {
  test('the SMS code and format match the server (shared vector)', () {
    expect(
      smsCode(
        'test-only-secret',
        'WC1 I:7Q2K ALERT ABIM-ENT-003 20261104T0912Z PH7.1 TDS1820 EC2600 UNSAFE',
      ),
      '1714FE',
    );
    final sms = composeAlertSms(
      shortCode: '7Q2K',
      secret: 'test-only-secret',
      sourceCode: 'abim-ent-003',
      testedAt: DateTime.utc(2026, 11, 4, 9, 12),
      triggerRule: 'unsafe',
      readings: [
        ReadingInput(
          parameterCode: 'ph',
          unit: 'pH',
          value: Decimal.parse('7.1'),
        ),
        ReadingInput(
          parameterCode: 'tds',
          unit: 'mg/L',
          value: Decimal.parse('1820'),
        ),
        ReadingInput(
          parameterCode: 'ec',
          unit: 'µS/cm',
          value: Decimal.parse('2600'),
        ),
        const ReadingInput(parameterCode: 'ecoli', unit: null, detected: true),
      ],
    );
    expect(
      sms,
      'WC1 I:7Q2K ALERT ABIM-ENT-003 20261104T0912Z PH7.1 TDS1820 EC2600 UNSAFE #1714FE',
    );
    expect(sms.length, lessThanOrEqualTo(160));
  });

  testWidgets('an alert stuck offline for 7 hours offers an SMS', (
    tester,
  ) async {
    final svc = TestServices()..server.offline = true;
    final composer = FakeComposer();
    final db = await pumpCollect(
      tester,
      services: svc,
      prepare: _stuckAlert,
      overrides: [
        smsComposerProvider.overrideWithValue(composer),
        clockProvider.overrideWithValue(
          () => _opened.add(const Duration(hours: 7)),
        ),
      ],
    );
    await _openAlert(tester);
    expect(
      find.text('This alert has not been sent for 7 hours'),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('Send by SMS'));
    final (number, body) = composer.sent.single;
    expect(number, '+256700999000');
    expect(body, startsWith('WC1 I:7Q2K ALERT ABIM-ENT-003 20261010T0600Z'));
    expect(body, matches(RegExp(r' UNSAFE #[0-9A-F]{6}$')));
    await disposeApp(tester, db);
  });

  testWidgets('no SMS offer without a gateway number', (tester) async {
    final svc = TestServices()..server.offline = true;
    final db = await pumpCollect(
      tester,
      services: svc,
      prepare: (db) => _stuckAlert(db, gateway: ''),
      overrides: [
        clockProvider.overrideWithValue(
          () => _opened.add(const Duration(hours: 9)),
        ),
      ],
    );
    await _openAlert(tester);
    expect(find.text('Send by SMS'), findsNothing);
    await disposeApp(tester, db);
  });
}
