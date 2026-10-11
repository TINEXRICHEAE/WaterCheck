import 'dart:io';

import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_console/app/auth_api.dart';
import 'package:watercheck_console/app/session.dart';

/// The Windows/Android sign-in path against a running dev stack, for a
/// stakeholder just created by the CLI (temporary password):
///   WC_LIVE_API=http://localhost/api WC_LIVE_USER=… WC_LIVE_PASSWORD=…
///   WC_LIVE_AREA=UG-ABIM
void main() {
  final live = Platform.environment['WC_LIVE_API'];

  test('live (native): forced change, PIN, restart, own area only', () async {
    final env = Platform.environment;
    final values = MemoryValues();
    final api = HttpConsoleAuthApi(baseUrl: live!, cookieMode: false);
    final lock = AppLock(
      values,
      key: consoleLockKey,
      hasher: const PinHasher(iterations: 10),
    );
    ProviderContainer start(RestoredSession restored) => ProviderContainer(
      overrides: [
        consoleAuthApiProvider.overrideWithValue(api),
        consoleValuesProvider.overrideWithValue(values),
        consoleLockProvider.overrideWithValue(lock),
        sessionProvider.overrideWith(() => SessionController(restored)),
      ],
    );

    var app = start(const RestoredSession(ConsoleSession.signedOut));
    final session = app.read(sessionProvider.notifier);
    await session.signIn(env['WC_LIVE_USER']!, env['WC_LIVE_PASSWORD']!);
    expect(app.read(sessionProvider).phase, SessionPhase.mustChangePassword);
    await session.changePassword('LiveConsole2026x');
    expect(app.read(sessionProvider).phase, SessionPhase.choosePin);
    await session.choosePin('1357');
    final me = app.read(sessionProvider).me!;
    expect(me.role, 'stakeholder');
    expect(me.areas.map((a) => a.code), [env['WC_LIVE_AREA'] ?? 'UG-ABIM']);
    app.dispose();

    // Restart: the saved session waits for the PIN, then reconnects.
    final restored = await restoreSession(
      api: api,
      store: SessionStore(values),
      lock: lock,
    );
    expect(restored.session.phase, SessionPhase.locked);
    app = start(restored);
    await app.read(sessionProvider.notifier).unlock('1357');
    expect(app.read(sessionProvider).phase, SessionPhase.signedIn);
    expect(app.read(sessionProvider).offline, isFalse);

    await app.read(sessionProvider.notifier).signOut();
    expect(await SessionStore(values).read(), isNull);
    app.dispose();
  }, skip: live == null ? 'set WC_LIVE_API to run against a dev stack' : false);
}
