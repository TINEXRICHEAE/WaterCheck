import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_console/app/auth_api.dart';
import 'package:watercheck_console/app/bootstrap.dart';
import 'package:watercheck_console/app/console_sync.dart';
import 'package:watercheck_console/app/session.dart';
import 'package:latlong2/latlong.dart';
import 'package:watercheck_console/features/map/device_location.dart';
import 'package:watercheck_console/features/map/map_tiles.dart';
import 'package:watercheck_console/main.dart';
import 'package:ui_kit/ui_kit.dart' as ui show legalVersion;

const _seed = '../../infra/seed';
const newPassword = 'BoreholeWater2026';

class FakeUser {
  FakeUser({
    required this.password,
    required this.role,
    this.mustChange = false,
    this.areas = const [],
  });

  var notify = (email: true, push: true, sms: true);
  var appearance = (theme: 'system', zone: 'Africa/Kampala');

  /// Privacy Policy and Terms version accepted (ADR-026): current unless a
  /// test says otherwise.
  int legalVersion = ui.legalVersion;

  String password;
  final String role;
  bool mustChange;
  final List<Area> areas;
}

/// An in-memory stand-in for the auth endpoints, in either token mode.
class FakeAuthApi implements ConsoleAuthApi {
  FakeAuthApi({this.cookieMode = false});

  @override
  final bool cookieMode;

  final users = <String, FakeUser>{
    'officer@example.org': FakeUser(
      password: 'TempPass-0001',
      role: 'stakeholder',
      mustChange: true,
      areas: const [
        Area(id: 'd1', level: 'district', name: 'Abim', code: 'ABIM'),
      ],
    ),
    'admin@example.org': FakeUser(password: newPassword, role: 'it_admin'),
  };

  bool offline = false;
  final helpRequests = <String>[];
  var logouts = 0;

  /// Refresh tokens still valid → user (the web cookie is the same idea).
  final _refresh = <String, String>{};
  final _access = <String, String>{};
  var _n = 0;
  String? cookie;

  void _online() {
    if (offline) throw const ApiFailure(ApiFailure.offline);
  }

  TokenResponse _issue(String username) {
    final r = 'refresh-${_n++}';
    final a = 'access-${_n++}';
    _refresh[r] = username;
    _access[a] = username;
    if (cookieMode) cookie = r;
    return TokenResponse(
      accessToken: a,
      refreshToken: cookieMode ? null : r,
      expiresIn: 900,
      mustChangePassword: users[username]!.mustChange,
    );
  }

  /// Pretends a stored session from an earlier run.
  String sessionFor(String username) {
    final t = _issue(username);
    return t.refreshToken ?? cookie!;
  }

  @override
  Future<TokenResponse> login(String username, String password) async {
    _online();
    final u = users[username];
    if (u == null || u.password != password) {
      throw const ApiFailure('invalid_credentials', status: 401);
    }
    return _issue(username);
  }

  @override
  Future<TokenResponse> refresh(String? refreshToken) async {
    _online();
    final token = cookieMode ? cookie : refreshToken;
    final user = _refresh.remove(token);
    if (user == null) throw const ApiFailure('invalid_token', status: 401);
    return _issue(user);
  }

  @override
  Future<TokenResponse> changePassword(
    String accessToken,
    String current,
    String replacement,
  ) async {
    _online();
    final name = _access[accessToken]!;
    final u = users[name]!;
    if (u.password != current) {
      throw const ApiFailure('invalid_credentials', status: 401);
    }
    if (replacement == current) {
      throw const ApiFailure('same_password', status: 422);
    }
    u
      ..password = replacement
      ..mustChange = false;
    return _issue(name);
  }

  @override
  Future<MeResponse> me(String accessToken) async {
    _online();
    final name = _access[accessToken];
    if (name == null) throw const ApiFailure('invalid_token', status: 401);
    final u = users[name]!;
    return MeResponse(
      id: 'u-$name',
      username: name,
      fullName: u.role == 'it_admin' ? 'Example Admin' : 'Example Officer',
      organisation: null,
      position: null,
      role: u.role,
      mustChangePassword: u.mustChange,
      responsibilities: const [],
      areas: u.areas,
      notifyEmail: u.notify.email,
      notifyPush: u.notify.push,
      notifySms: u.notify.sms,
      theme: u.appearance.theme,
      timeZone: u.appearance.zone,
      legalVersion: u.legalVersion,
    );
  }

  @override
  Future<void> logout(String? refreshToken) async {
    logouts++;
    _refresh.remove(cookieMode ? cookie : refreshToken);
    cookie = null;
  }

  @override
  Future<void> passwordHelp(String username) async {
    _online();
    helpRequests.add(username);
  }

  @override
  Future<void> setPreferences(
    String accessToken, {
    required bool email,
    required bool push,
    required bool sms,
  }) async {
    _online();
    users[_access[accessToken]!]!.notify = (email: email, push: push, sms: sms);
  }

  @override
  Future<void> setAppearance(
    String accessToken, {
    required String theme,
    required String timeZone,
  }) async {
    _online();
    users[_access[accessToken]!]!.appearance = (theme: theme, zone: timeZone);
  }
}

/// Serves pull pages per stream; records pushes.
class FakeSyncTransport implements SyncTransport {
  final serve = <String, List<IncomingChange>>{};
  final pulls = <String>[];
  var pushes = 0;
  final pushed = <OutgoingChange>[];
  bool offline = false;

  void _online() {
    if (offline) throw const SyncFailure(SyncFailureKind.offline, 'offline');
  }

  @override
  Future<List<ChangeOutcome>> push(
    String batchId,
    List<OutgoingChange> changes,
  ) async {
    _online();
    pushes++;
    pushed.addAll(changes);
    return [for (final _ in changes) const ChangeOutcome('applied')];
  }

  @override
  Future<PullPage> pull(
    String stream,
    String? cursor, {
    int limit = 500,
  }) async {
    _online();
    pulls.add(stream);
    final rows = serve.remove(stream) ?? const [];
    return PullPage(
      changes: rows,
      nextCursor: '1.${rows.length}',
      hasMore: false,
    );
  }
}

class FakeNotificationsApi implements NotificationsApi {
  final items = <NotificationOut>[];
  final read = <String>{};

  @override
  Future<Inbox> inbox() async => Inbox(
    unread: items.where((n) => !read.contains(n.id)).length,
    items: [
      for (final n in items)
        read.contains(n.id)
            ? NotificationOut(
                id: n.id,
                alertId: n.alertId,
                kind: n.kind,
                title: n.title,
                body: n.body,
                createdAt: n.createdAt,
                readAt: DateTime.utc(2026, 10, 10, 12),
              )
            : n,
    ],
  );

  @override
  Future<void> markRead(String id) async => read.add(id);

  @override
  Future<void> markAllRead() async => read.addAll(items.map((n) => n.id));
}

/// Everything a Console test may set up or inspect.
class ConsoleTestEnv {
  /// Extra provider overrides for one test (e.g. a fake admin server).
  final extraOverrides = <Override>[];

  /// Where the device is (null: location off).
  LatLng? location;

  ConsoleTestEnv({bool cookieMode = false})
    : api = FakeAuthApi(cookieMode: cookieMode);

  final FakeAuthApi api;
  final values = MemoryValues();
  final sync = FakeSyncTransport();
  final notifications = FakeNotificationsApi();

  SessionStore get store => SessionStore(values);
  AppLock get lock => AppLock(
    values,
    key: consoleLockKey,
    hasher: const PinHasher(iterations: 10),
  );

  /// A saved session with a PIN, as left by an earlier run (native).
  Future<void> saveSession(String username, String pin) async {
    final t = await api.refresh(api.sessionFor(username));
    await store.save(t.refreshToken!, await api.me(t.accessToken));
    await lock.setPin(pin);
  }
}

Future<AppDatabase> seededDb() async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  final profiles = Directory('$_seed/reference_profiles')
      .listSync()
      .whereType<File>()
      .map((f) => 'reference_profiles/${f.uri.pathSegments.last}')
      .toList();
  await SeedImporter(db).importBundle(
    await SeedBundle.load(
      read: (p) => File('$_seed/$p').readAsString(),
      referenceProfilePaths: profiles,
    ),
  );
  return db;
}

/// Lets real async work finish between frames. `pumpAndSettle` alone
/// never settles while a loading spinner is animating.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty && i > 3) {
      break;
    }
  }
  await tester.pump(const Duration(milliseconds: 400));
}

Future<AppDatabase> pumpConsole(
  WidgetTester tester, {
  required ConsoleTestEnv env,
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final boot = (await tester.runAsync(() async {
    final db = await seededDb();
    final restored = await restoreSession(
      api: env.api,
      store: env.store,
      lock: env.lock,
    );
    return ConsoleBoot(
      db: db,
      api: env.api,
      values: env.values,
      restored: restored,
    );
  }))!;
  await tester.pumpWidget(
    ConsoleRoot(
      boot: boot,
      overrides: [
        consoleLockProvider.overrideWithValue(env.lock),
        consoleSyncTransportProvider.overrideWithValue(env.sync),
        notificationsApiProvider.overrideWithValue(env.notifications),
        mapTilesProvider.overrideWith((ref) async => MapTiles.none),
        deviceLocationProvider.overrideWith(
          (ref) => Stream.value(env.location),
        ),
        ...env.extraOverrides,
      ],
    ),
  );
  await settle(tester);
  return boot.db;
}

Future<void> disposeConsole(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  final closing = db.close();
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(() => closing);
}

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.widgetWithText(OutlinedButton, d));
    await tester.pump();
  }
  await tester.tap(find.byIcon(Icons.check).last);
  await settle(tester);
}

Future<void> signIn(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.enterText(find.widgetWithText(TextField, 'Username'), username);
  await tester.enterText(find.widgetWithText(TextField, 'Password'), password);
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await settle(tester);
}
