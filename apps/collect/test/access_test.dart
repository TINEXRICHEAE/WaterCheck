import 'dart:convert';

import 'package:data/data.dart';
import 'package:data/src/db/database.dart' show OutboxCompanion;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_collect/app/gate.dart';
import 'package:watercheck_collect/app/router.dart';
import 'package:watercheck_collect/features/activation/collect_api.dart';

import 'support/fake_server.dart';
import 'support/harness.dart';

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.widgetWithText(OutlinedButton, d));
    await tester.pump();
  }
  await tester.tap(find.byIcon(Icons.check).last);
  await settle(tester);
}

Future<void> addUnsentRecord(AppDatabase db) => db
    .into(db.outbox)
    .insert(
      OutboxCompanion.insert(
        entity: 'water_source',
        entityId: 'b4c9a1e2-0000-4000-8000-000000000001',
        op: 'insert',
        payload: '{"code":"ABIM-ENT-001"}',
        createdAt: DateTime.utc(2026, 10, 10),
      ),
    );

void main() {
  group('gate order', () {
    const ready = AppGate(consented: true, activeCollectorKey: 'k');

    test('activation comes after consent and before everything else', () {
      const g = AppGate(
        consented: true,
        activeCollectorKey: 'k',
        activated: false,
      );
      expect(gateRedirect(g, '/'), '/activate');
      expect(gateRedirect(g, '/activate/scan'), isNull);
      expect(gateRedirect(g, '/reset'), '/activate');
      expect(
        gateRedirect(ready.copyWith(consented: false), '/activate'),
        '/welcome',
      );
    });

    test('a revoked phone can only export and wipe', () {
      final g = ready.copyWith(revoked: true, locked: true);
      expect(gateRedirect(g, '/'), '/reset');
      expect(gateRedirect(g, '/lock'), '/reset');
      expect(gateRedirect(g, '/reset'), isNull);
    });

    test('the lock hides everything except reset', () {
      final g = ready.copyWith(locked: true);
      expect(gateRedirect(g, '/'), '/lock');
      expect(gateRedirect(g, '/settings'), '/lock');
      expect(gateRedirect(g, '/reset'), isNull);
      expect(gateRedirect(ready, '/lock'), '/');
    });

    test('a new installation is asked to choose a PIN', () {
      final g = ready.copyWith(lockDecided: false);
      expect(gateRedirect(g, '/'), '/lock/setup');
      expect(gateRedirect(ready, '/lock/setup'), '/');
      expect(gateRedirect(ready, '/activate'), '/');
    });
  });

  group('codes and dates', () {
    test('typed and scanned activation codes', () {
      expect(parseActivationInput(' k7qm rt4w 9xhb ')!.code, 'K7QM-RT4W-9XHB');
      final qr = parseActivationInput(
        'watercheck://activate?code=K7QMRT4W9XHB&server=https://wc.example.org/api',
      )!;
      expect(qr.code, 'K7QM-RT4W-9XHB');
      expect(qr.server, 'https://wc.example.org/api');
      expect(parseActivationInput('K7QM-RT4W'), isNull);
      expect(parseActivationInput('watercheck://activate'), isNull);
    });

    test('HTTP dates', () {
      expect(
        parseHttpDate('Sat, 10 Oct 2026 10:52:59 GMT'),
        DateTime.utc(2026, 10, 10, 10, 52, 59),
      );
      expect(parseHttpDate('yesterday'), isNull);
    });
  });

  testWidgets('first run: refused codes, then activation and a PIN', (
    tester,
  ) async {
    final svc = TestServices()
      ..server.codes['EXPD-EXPD-EXPD'] = 'expired_code'
      ..server.codes['USED-USED-USED'] = 'code_used_up'
      // The phone clock is two hours slow; the server's time wins.
      ..server.serverTime = DateTime.now().toUtc().add(
        const Duration(hours: 2),
      );
    final db = await pumpCollect(tester, activated: false, services: svc);
    expect(find.text('Activate this phone'), findsOneWidget);

    Future<void> tryCode(String code) async {
      await tester.enterText(find.byType(TextField).first, code);
      await tapAndSettle(tester, find.text('Activate'));
    }

    await tryCode('K7QM');
    expect(find.textContaining('12 letters and numbers'), findsOneWidget);
    await tryCode('AAAA-BBBB-CCCC');
    expect(find.textContaining('not recognised'), findsOneWidget);
    await tryCode('expd-expd-expd');
    expect(find.textContaining('has expired'), findsOneWidget);
    await tryCode('USED USED USED');
    expect(find.textContaining('as many phones as allowed'), findsOneWidget);
    svc.server.offline = true;
    await tryCode('K7QM-RT4W-9XHB');
    expect(find.textContaining('Could not reach the server'), findsOneWidget);

    svc.server.offline = false;
    await tryCode('K7QM-RT4W-9XHB');
    expect(find.text('Choose a PIN to protect WaterCheck'), findsOneWidget);
    final creds = (await tester.runAsync(svc.installation.read))!;
    expect(creds.installationId, FakeServer.installationId);
    expect(creds.areaName, 'Entebbe');
    final offset = (await tester.runAsync(svc.installation.clockOffset))!;
    expect(offset.inMinutes, closeTo(120, 1));
    // The newer published rules were imported.
    final rules = await tester.runAsync(
      () => (db.select(
        db.configDocuments,
      )..where((t) => t.key.equals('rules'))).getSingle(),
    );
    expect(rules!.version, svc.server.rulesVersion);

    await enterPin(tester, '1357');
    await enterPin(tester, '1357');
    expect(find.text('Who is testing?'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect((await tester.runAsync(svc.lock.config))!.enabled, isTrue);
    await disposeApp(tester, db);
  });

  testWidgets('the lock can be turned off at setup', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(
      tester,
      services: svc,
      prepare: (db) =>
          DriftLocalSettingsRepository(db).write(lockDeclinedSetting, null),
    );
    expect(find.text('Choose a PIN to protect WaterCheck'), findsOneWidget);
    await tapAndSettle(tester, find.text('Turn off app lock'));
    await tapAndSettle(tester, find.text('Turn off app lock').last);
    expect(find.byType(NavigationBar), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('offline restart: unlock with the PIN, no sign-in', (
    tester,
  ) async {
    final svc = TestServices()..server.offline = true;
    final db = await pumpCollect(tester, services: svc, pin: '2468');
    expect(find.text('WaterCheck is locked.'), findsOneWidget);
    await enterPin(tester, '1111');
    expect(find.textContaining('Wrong PIN'), findsOneWidget);
    await enterPin(tester, '2468');
    expect(find.byType(NavigationBar), findsOneWidget);
    // Field work opens with no network and no account.
    await tapAndSettle(tester, find.text('Test a source'));
    expect(find.text('Which source are you testing?'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('fingerprint unlock when enabled', (tester) async {
    final svc = TestServices()..biometrics.isAvailable = true;
    final db = await pumpCollect(
      tester,
      services: svc,
      pin: '2468',
      prepare: (_) => svc.lock.setBiometric(true),
    );
    expect(svc.biometrics.prompts, 1);
    expect(find.byType(NavigationBar), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('revoked: unsent records are exported, then the phone is wiped', (
    tester,
  ) async {
    final svc = TestServices()..server.revoked.add(FakeServer.installationId);
    await pumpCollect(
      tester,
      services: svc,
      pin: '2468',
      prepare: addUnsentRecord,
    );
    // The status check on start found the revocation; no PIN is needed.
    expect(find.text('This phone has been switched off'), findsOneWidget);
    expect(find.text('1 record not sent'), findsOneWidget);
    expect((await tester.runAsync(svc.installation.isRevoked))!, isTrue);

    await tapAndSettle(tester, find.text('Save unsent records to a file'));
    expect(svc.saver.saved, hasLength(1));
    final name = svc.saver.saved.keys.single;
    expect(name, startsWith('watercheck-unsent-ABIM-ENT-'));
    final content = (await tester.runAsync(
      () => ExportFile.decrypt(
        utf8.decode(svc.saver.saved[name]!),
        FakeServer.secret,
      ),
    ))!;
    final items = content['items']! as List;
    expect((items.single as Map)['payload'], {'code': 'ABIM-ENT-001'});

    await tapAndSettle(tester, find.text('Erase this phone'));
    expect(
      find.text(
        'All WaterCheck data on this phone will be erased. This cannot be undone.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Erase this phone'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    expect(svc.restarts, 1);
    expect(svc.deletes, 1);
    expect((await tester.runAsync(svc.installation.read)), isNull);
    expect((await tester.runAsync(svc.lock.config))!.enabled, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('erasing without saving warns that records will be lost', (
    tester,
  ) async {
    // Offline, so the unsent record is still unsent.
    final svc = TestServices()..server.offline = true;
    final db = await pumpCollect(
      tester,
      services: svc,
      pin: '2468',
      prepare: addUnsentRecord,
    );
    await tapAndSettle(tester, find.text('Forgot PIN?'));
    await tapAndSettle(tester, find.text('Reset the app'));
    expect(find.text('Reset this phone'), findsOneWidget);
    await tapAndSettle(tester, find.text('Erase this phone'));
    expect(find.textContaining('will be lost'), findsOneWidget);
    await tapAndSettle(tester, find.text('Cancel').last);
    // Cancel goes back to the lock: reset does not bypass it.
    await tapAndSettle(tester, find.text('Cancel'));
    expect(find.text('WaterCheck is locked.'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('settings: turning the lock off needs the PIN', (tester) async {
    final svc = TestServices();
    final db = await pumpCollect(tester, services: svc, pin: '2468');
    await enterPin(tester, '2468');
    await tapAndSettle(tester, find.text('Settings'));
    expect(find.text('Activated for Entebbe'), findsOneWidget);
    await tapAndSettle(tester, find.text('App lock'));
    await tapAndSettle(tester, find.text('Turn off app lock'));
    expect(find.text('Enter your current PIN'), findsOneWidget);
    await enterPin(tester, '2468');
    expect((await tester.runAsync(svc.lock.config))!.enabled, isFalse);
    expect(find.text('Change PIN'), findsNothing);
    await disposeApp(tester, db);
  });
}
