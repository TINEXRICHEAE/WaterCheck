import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart' show legalVersion;
import 'package:watercheck_console/app/console_sync.dart'
    show consoleDioProvider;
import 'package:watercheck_console/app/router.dart';
import 'package:watercheck_console/app/session.dart';

import 'support/harness.dart';

void main() {
  group('session redirects', () {
    test('each phase has one screen', () {
      expect(sessionRedirect(ConsoleSession.signedOut, '/admin'), '/sign-in');
      expect(sessionRedirect(ConsoleSession.signedOut, '/sign-in'), isNull);
      expect(
        sessionRedirect(
          const ConsoleSession(SessionPhase.mustChangePassword),
          '/dashboard',
        ),
        '/change-password',
      );
      expect(
        sessionRedirect(const ConsoleSession(SessionPhase.locked), '/'),
        '/unlock',
      );
      expect(
        sessionRedirect(const ConsoleSession(SessionPhase.choosePin), '/'),
        '/pin',
      );
    });

    test('stakeholders cannot open the admin console', () {
      const stakeholder = ConsoleSession(SessionPhase.signedIn);
      expect(sessionRedirect(stakeholder, '/admin'), '/dashboard');
      expect(
        sessionRedirect(stakeholder, '/admin/reference-data'),
        '/dashboard',
      );
      expect(sessionRedirect(stakeholder, '/sources'), isNull);
      expect(sessionRedirect(stakeholder, '/sign-in'), '/dashboard');
    });

    test('passwords follow the server rule', () {
      expect(passwordAcceptable('short1'), isFalse);
      expect(passwordAcceptable('1234567890'), isFalse);
      expect(passwordAcceptable('onlyletters'), isFalse);
      expect(passwordAcceptable(newPassword), isTrue);
    });
  });

  group('restoring a session', () {
    test('native: a saved session waits for the PIN, offline', () async {
      final env = ConsoleTestEnv();
      await env.saveSession('admin@example.org', '2468');
      env.api.offline = true;
      final r = await restoreSession(
        api: env.api,
        store: env.store,
        lock: env.lock,
      );
      expect(r.session.phase, SessionPhase.locked);
      expect(r.session.me!.fullName, 'Example Admin');
    });

    test('native: a session without a PIN is dropped', () async {
      final env = ConsoleTestEnv();
      await env.saveSession('admin@example.org', '2468');
      await env.lock.disable();
      final r = await restoreSession(
        api: env.api,
        store: env.store,
        lock: env.lock,
      );
      expect(r.session.phase, SessionPhase.signedOut);
      expect(await env.store.read(), isNull);
    });

    test('web: the refresh cookie signs back in after a reload', () async {
      final env = ConsoleTestEnv(cookieMode: true);
      env.api.sessionFor('admin@example.org');
      final r = await restoreSession(
        api: env.api,
        store: env.store,
        lock: env.lock,
      );
      expect(r.session.phase, SessionPhase.signedIn);
      expect(r.tokens, isNotNull);
      env.api.cookie = null;
      final none = await restoreSession(
        api: env.api,
        store: env.store,
        lock: env.lock,
      );
      expect(none.session.phase, SessionPhase.signedOut);
    });
  });

  testWidgets('stakeholder: temporary password, PIN, own areas only', (
    tester,
  ) async {
    final env = ConsoleTestEnv();
    final db = await pumpConsole(tester, env: env);
    expect(find.text('Sign in to WaterCheck Console'), findsOneWidget);

    await signIn(tester, 'officer@example.org', 'wrong-password');
    expect(find.text('Wrong username or password.'), findsOneWidget);

    await signIn(tester, 'officer@example.org', 'TempPass-0001');
    expect(find.text('Choose your own password'), findsOneWidget);
    Future<void> choose(String a, String b) async {
      await tester.enterText(find.widgetWithText(TextField, 'New password'), a);
      await tester.enterText(
        find.widgetWithText(TextField, 'New password again'),
        b,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save password'));
      await settle(tester);
    }

    await choose('short', 'short');
    expect(
      find.text('Use at least 10 characters, mixing letters and numbers.'),
      findsWidgets,
    );
    await choose(newPassword, 'BoreholeWater2027');
    expect(find.text('The two passwords are not the same.'), findsOneWidget);
    await choose(newPassword, newPassword);
    expect(env.api.users['officer@example.org']!.password, newPassword);

    // Windows/Android: a PIN protects the data kept on the device.
    expect(find.text('Choose a PIN for this device'), findsOneWidget);
    await enterPin(tester, '1357');
    await enterPin(tester, '1357');
    expect(find.text('Your areas: Abim'), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
    expect((await tester.runAsync(env.store.read)), isNotNull);

    await tester.tap(find.byTooltip('Account'));
    await settle(tester);
    await tester.tap(find.text('Sign out'));
    await settle(tester);
    expect(find.text('Sign in to WaterCheck Console'), findsOneWidget);
    expect((await tester.runAsync(env.store.read)), isNull);
    expect(env.api.logouts, 1);
    await disposeConsole(tester, db);
  });

  testWidgets('a stakeholder may skip the PIN; an IT admin may not', (
    tester,
  ) async {
    final env = ConsoleTestEnv();
    env.api.users['officer@example.org']!.mustChange = false;
    env.api.users['officer@example.org']!.password = newPassword;
    var db = await pumpConsole(tester, env: env);
    await signIn(tester, 'officer@example.org', newPassword);
    expect(find.text('Choose a PIN for this device'), findsOneWidget);
    await tester.tap(find.text('Skip: no PIN on this device'));
    await settle(tester);
    expect(find.text('Your areas: Abim'), findsOneWidget);

    // Next start: straight in, no PIN.
    await disposeConsole(tester, db);
    db = await pumpConsole(tester, env: env);
    expect(find.text('Your areas: Abim'), findsOneWidget);

    // The profile turns it back on: a PIN is chosen.
    await tester.tap(find.byTooltip('Account'));
    await settle(tester);
    await tester.tap(find.text('Settings').last);
    await settle(tester);
    final lock = find.widgetWithText(
      SwitchListTile,
      'Ask for a PIN on this device',
    );
    await tester.scrollUntilVisible(
      lock,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -200));
    await settle(tester);
    expect(tester.widget<SwitchListTile>(lock).value, isFalse);
    await tester.tap(find.descendant(of: lock, matching: find.byType(Switch)));
    await settle(tester);
    await enterPin(tester, '1357');
    await enterPin(tester, '1357');
    expect(await tester.runAsync(env.store.noLock), isFalse);
    await disposeConsole(tester, db);

    // An IT admin is not offered the skip.
    final admin = ConsoleTestEnv();
    db = await pumpConsole(tester, env: admin);
    await signIn(tester, 'admin@example.org', newPassword);
    expect(find.text('Choose a PIN for this device'), findsOneWidget);
    expect(find.text('Skip: no PIN on this device'), findsNothing);
    await disposeConsole(tester, db);
  });

  testWidgets('the Privacy Policy and Terms are accepted after sign-in, '
      'and their version recorded (ADR-026)', (tester) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.users['admin@example.org']!.legalVersion = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = _LegalServer(
        () => env.api.users['admin@example.org']!.legalVersion = legalVersion,
      );
    env.extraOverrides.add(consoleDioProvider.overrideWithValue(dio));
    final db = await pumpConsole(tester, env: env);
    await signIn(tester, 'admin@example.org', newPassword);
    expect(find.text('Before you continue'), findsOneWidget);
    await tester.tap(find.text('Terms of Use'));
    await settle(tester);
    expect(find.text('WaterCheck Terms of Use'), findsOneWidget);
    await tester.pageBack();
    await settle(tester);
    await tester.tap(
      find.text('I agree to the Terms of Use and the Privacy Policy'),
    );
    await settle(tester);
    expect(find.text('Before you continue'), findsNothing);
    expect(find.text('IT admin: all areas'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('IT admin sees the admin console', (tester) async {
    final env = ConsoleTestEnv(cookieMode: true);
    final db = await pumpConsole(tester, env: env);
    await signIn(tester, 'admin@example.org', newPassword);
    // Web: no PIN step.
    expect(find.text('IT admin: all areas'), findsOneWidget);
    await tester.tap(find.text('Admin'));
    await settle(tester);
    await tester.scrollUntilVisible(find.text('Reference data'), 100);
    await tester.ensureVisible(find.text('Reference data'));
    await settle(tester);
    await tester.tap(find.text('Reference data'));
    await settle(tester);
    expect(find.text('Reference profiles (2)'), findsOneWidget);
    expect(find.text('Parameters (42)'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('phones use a bottom bar', (tester) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    final db = await pumpConsole(tester, env: env, size: const Size(400, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    await disposeConsole(tester, db);
  });

  testWidgets('forgot password asks the IT admin', (tester) async {
    final env = ConsoleTestEnv(cookieMode: true);
    final db = await pumpConsole(tester, env: env);
    await tester.tap(find.text('Forgot password?'));
    await settle(tester);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'officer@example.org',
    );
    await tester.tap(find.text('Send request'));
    await settle(tester);
    expect(env.api.helpRequests, ['officer@example.org']);
    expect(find.textContaining('Request sent'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('native offline: the PIN opens cached data', (tester) async {
    final env = ConsoleTestEnv();
    await tester.runAsync(() => env.saveSession('admin@example.org', '2468'));
    env.api.offline = true;
    final db = await pumpConsole(tester, env: env);
    expect(find.text('Signed in as Example Admin'), findsOneWidget);
    await enterPin(tester, '0000');
    expect(find.textContaining('Wrong PIN'), findsOneWidget);
    await enterPin(tester, '2468');
    expect(
      find.text('Offline: showing data saved on this device.'),
      findsOneWidget,
    );
    expect(find.text('IT admin: all areas'), findsOneWidget);

    env.api.offline = false;
    await tester.tap(find.text('Reconnect'));
    await settle(tester);
    expect(
      find.text('Offline: showing data saved on this device.'),
      findsNothing,
    );
    await disposeConsole(tester, db);
  });

  testWidgets('native: an ended session goes back to sign-in', (tester) async {
    final env = ConsoleTestEnv();
    await tester.runAsync(() => env.saveSession('admin@example.org', '2468'));
    // The IT admin reset the account: the saved refresh token is no good.
    final saved = (await tester.runAsync(env.store.read))!;
    await env.api.logout(saved.refreshToken);
    final db = await pumpConsole(tester, env: env);
    await enterPin(tester, '2468');
    expect(
      find.text('Your session has ended. Please sign in again.'),
      findsOneWidget,
    );
    await disposeConsole(tester, db);
  });

  testWidgets('idle: the web signs out, Windows/Android lock', (tester) async {
    final web = ConsoleTestEnv(cookieMode: true);
    web.api.sessionFor('admin@example.org');
    var db = await pumpConsole(tester, env: web);
    expect(find.text('IT admin: all areas'), findsOneWidget);
    await tester.pump(idleTimeout + const Duration(seconds: 1));
    await settle(tester);
    expect(
      find.text('You were signed out after 30 minutes without activity.'),
      findsOneWidget,
    );
    await disposeConsole(tester, db);

    final native = ConsoleTestEnv();
    db = await pumpConsole(tester, env: native);
    await signIn(tester, 'admin@example.org', newPassword);
    await enterPin(tester, '1357');
    await enterPin(tester, '1357');
    await tester.pump(idleTimeout + const Duration(seconds: 1));
    await settle(tester);
    expect(find.text('Signed in as Example Admin'), findsOneWidget);
    await enterPin(tester, '1357');
    expect(find.text('IT admin: all areas'), findsOneWidget);
    await disposeConsole(tester, db);
  });

  testWidgets('a test synced from Collect shows with its collector', (
    tester,
  ) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    const src = '01a1aaaa-0000-7000-8000-000000000001';
    const ses = '01a1aaaa-0000-7000-8000-000000000002';
    const res = '01a1aaaa-0000-7000-8000-000000000003';
    const profile = 'ba9093d7-4551-54b4-9da1-3c14a7041644';
    // Yesterday: recent, so the source is not also listed as overdue.
    final at = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 1))
        .toIso8601String();
    env.sync.serve['scope'] = [
      IncomingChange(
        entity: 'water_source',
        op: 'upsert',
        id: src,
        data: {
          'id': src,
          'village_id': 'ad625def-3111-5ddd-835f-b24118d37f01',
          'code': 'ABIM-ENT-001',
          'name': 'Main borehole',
          'source_type': 'borehole',
          'functional_status': 'functional',
          'is_active': true,
          'version': 1,
          'created_at_device': at,
          'updated_at_device': at,
        },
      ),
      IncomingChange(
        entity: 'test_session',
        op: 'upsert',
        id: ses,
        data: {
          'id': ses,
          'source_id': src,
          'reference_standard_id': profile,
          'calibrated': true,
          'tested_at_device': at,
          'clock_flags': <Object?>[],
          'collector_snapshot': {'full_name': 'Example Collector'},
        },
      ),
      IncomingChange(
        entity: 'test_result',
        op: 'upsert',
        id: res,
        data: {
          'id': res,
          'session_id': ses,
          'overall': 'safe',
          'standard_id': profile,
          'computed_by': 'device',
          'flags': <Object?>[],
          'created_at_device': at,
        },
      ),
      IncomingChange(
        entity: 'classification',
        op: 'upsert',
        id: '$res/$profile',
        data: {
          'result_id': res,
          'standard_id': profile,
          'computed_by': 'server',
          'overall': 'unsafe',
          'reading_results': {'tds': 'high'},
          'flags': <Object?>[],
          'computed_at': at,
        },
      ),
    ];
    final db = await pumpConsole(tester, env: env);
    expect(env.sync.pulls, ['reference', 'scope']);
    expect(find.text('Main borehole (ABIM-ENT-001)'), findsOneWidget);
    expect(find.textContaining('by Example Collector'), findsOneWidget);
    // The server's own classification is shown (ADR-005).
    expect(find.text('UNSAFE'), findsOneWidget);
    await disposeConsole(tester, db);
  });
}

/// Accepting the documents (ADR-026).
class _LegalServer implements HttpClientAdapter {
  _LegalServer(this.onAccept);

  final void Function() onAccept;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/v1/me/legal') onAccept();
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}
