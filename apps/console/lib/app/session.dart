import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart' show ThemeChoice, TimeZoneChoice;

import 'auth_api.dart';

enum SessionPhase {
  signedOut,

  /// Signed in with a temporary password that must be changed first.
  mustChangePassword,

  /// Windows/Android after the first sign-in: choose a PIN for offline use.
  choosePin,

  /// Windows/Android: a saved session waits for the PIN (F-AUTH-2).
  locked,
  signedIn,
}

/// Why the user is back at the sign-in screen, if not by choice.
enum SignedOutReason { none, idle, expired }

class ConsoleSession {
  const ConsoleSession(
    this.phase, {
    this.me,
    this.offline = false,
    this.reason = SignedOutReason.none,
  });

  static const signedOut = ConsoleSession(SessionPhase.signedOut);

  final SessionPhase phase;
  final MeResponse? me;

  /// Showing data cached on this device; the server could not be reached.
  final bool offline;
  final SignedOutReason reason;

  bool get isAdmin => me?.role == 'it_admin';
}

/// A saved session on Windows/Android: the refresh token and the profile,
/// in secure storage (Windows DPAPI / Android Keystore). Never on the web.
class SessionStore {
  SessionStore(this._values);

  static const _key = 'watercheck.console.session.v1';
  final SecureValues _values;

  Future<({String refreshToken, MeResponse me})?> read() async {
    final raw = await _values.read(_key);
    if (raw == null) return null;
    final j = (jsonDecode(raw) as Map).cast<String, Object?>();
    return (
      refreshToken: j['refresh_token']! as String,
      me: MeResponse.fromJson((j['me']! as Map).cast()),
    );
  }

  Future<void> save(String refreshToken, MeResponse me) => _values.write(
    _key,
    jsonEncode({'refresh_token': refreshToken, 'me': me.toJson()}),
  );

  Future<void> clear() => _values.delete(_key);
}

/// Access token kept in memory only.
class _Tokens {
  String? access;
  DateTime? expires;
  String? refresh;
  String? temporaryPassword;

  void accept(TokenResponse t, DateTime now) {
    access = t.accessToken;
    expires = now.add(Duration(seconds: t.expiresIn));
    if (t.refreshToken != null) refresh = t.refreshToken;
  }

  void clear() {
    access = null;
    expires = null;
    refresh = null;
    temporaryPassword = null;
  }
}

/// Startup result: the session plus any tokens obtained while restoring.
class RestoredSession {
  const RestoredSession(this.session, {this.tokens});

  final ConsoleSession session;
  final TokenResponse? tokens;
}

/// Restores the session at startup (before the first frame).
/// Web: tries the refresh cookie. Windows/Android: a saved session goes to
/// the PIN screen without any network call, so offline use works.
Future<RestoredSession> restoreSession({
  required ConsoleAuthApi api,
  required SessionStore store,
  required AppLock lock,
}) async {
  if (api.cookieMode) {
    try {
      final t = await api.refresh(null).timeout(const Duration(seconds: 10));
      // A temporary password cannot be finished after a reload.
      if (t.mustChangePassword) {
        return const RestoredSession(ConsoleSession.signedOut);
      }
      final me = await api.me(t.accessToken);
      return RestoredSession(
        ConsoleSession(SessionPhase.signedIn, me: me),
        tokens: t,
      );
    } catch (_) {
      return const RestoredSession(ConsoleSession.signedOut);
    }
  }
  final saved = await store.read();
  if (saved != null && (await lock.config()).enabled) {
    return RestoredSession(ConsoleSession(SessionPhase.locked, me: saved.me));
  }
  // A half-finished first sign-in (no PIN chosen) is not kept.
  await store.clear();
  return const RestoredSession(ConsoleSession.signedOut);
}

class SessionController extends Notifier<ConsoleSession> {
  SessionController(this._restored, {this.clock = systemClock});

  final RestoredSession _restored;
  final Clock clock;
  final _tokens = _Tokens();

  ConsoleAuthApi get _api => ref.read(consoleAuthApiProvider);
  SessionStore get _store => ref.read(sessionStoreProvider);
  AppLock get _lock => ref.read(consoleLockProvider);

  /// The PIN and saved session apply to Windows and Android only.
  bool get _native => !_api.cookieMode;

  @override
  ConsoleSession build() {
    final t = _restored.tokens;
    if (t != null) _tokens.accept(t, clock());
    return _restored.session;
  }

  /// Throws [ApiFailure].
  Future<void> signIn(String username, String password) async {
    final t = await _api.login(username.trim(), password);
    _tokens.accept(t, clock());
    if (t.mustChangePassword) {
      _tokens.temporaryPassword = password;
      state = const ConsoleSession(SessionPhase.mustChangePassword);
      return;
    }
    await _finishSignIn();
  }

  /// Replaces the temporary password. Throws [ApiFailure].
  Future<void> changePassword(String replacement) async {
    final t = await _api.changePassword(
      _tokens.access!,
      _tokens.temporaryPassword!,
      replacement,
    );
    _tokens
      ..temporaryPassword = null
      ..accept(t, clock());
    await _finishSignIn();
  }

  Future<void> _finishSignIn() async {
    final me = await _api.me(_tokens.access!);
    if (!_native) {
      state = ConsoleSession(SessionPhase.signedIn, me: me);
      return;
    }
    await _store.save(_tokens.refresh!, me);
    state = ConsoleSession(
      (await _lock.config()).enabled
          ? SessionPhase.signedIn
          : SessionPhase.choosePin,
      me: me,
    );
  }

  Future<void> choosePin(String pin) async {
    await _lock.setPin(pin);
    state = ConsoleSession(SessionPhase.signedIn, me: state.me);
  }

  /// Windows/Android: checks the PIN, then reconnects if it can.
  Future<UnlockResult> unlock(String pin) async {
    final result = await _lock.unlock(pin);
    if (result is Unlocked) await _resume();
    return result;
  }

  Future<void> _resume() async {
    final expires = _tokens.expires;
    if (_tokens.access != null &&
        expires != null &&
        clock().isBefore(expires)) {
      state = ConsoleSession(SessionPhase.signedIn, me: state.me);
      return;
    }
    final saved = await _store.read();
    if (saved == null) {
      state = ConsoleSession.signedOut;
      return;
    }
    try {
      final t = await _api.refresh(saved.refreshToken);
      _tokens.accept(t, clock());
      final me = await _api.me(t.accessToken);
      await _store.save(_tokens.refresh!, me);
      state = ConsoleSession(SessionPhase.signedIn, me: me);
    } on ApiFailure catch (e) {
      if (e.isOffline || (e.status ?? 0) >= 500) {
        // Offline read of cached data (F-AUTH-2).
        _tokens.refresh = saved.refreshToken;
        state = ConsoleSession(
          SessionPhase.signedIn,
          me: saved.me,
          offline: true,
        );
      } else {
        // Revoked, expired or reused: sign in again.
        await _forget();
        state = const ConsoleSession(
          SessionPhase.signedOut,
          reason: SignedOutReason.expired,
        );
      }
    }
  }

  /// Retries the server after an offline unlock.
  Future<void> reconnect() async {
    _tokens.access = null;
    await _resume();
  }

  /// Saves notification channels, then reloads the profile.
  /// Throws [ApiFailure].
  Future<void> setPreferences({
    required bool email,
    required bool push,
    required bool sms,
  }) async {
    final access = await accessToken();
    if (access == null) throw const ApiFailure(ApiFailure.offline);
    await _api.setPreferences(access, email: email, push: push, sms: sms);
    final me = await _api.me(access);
    if (_native) await _store.save(_tokens.refresh!, me);
    state = ConsoleSession(state.phase, me: me, offline: state.offline);
  }

  /// Theme and time zone: applied and kept on this device at once, then
  /// saved to the account. Throws [ApiFailure] when the account could not
  /// be updated (the choice still applies here).
  Future<void> setAppearance(ThemeChoice theme, TimeZoneChoice zone) async {
    final current = state.me;
    if (current == null) return;
    // Through JSON text: toJson() leaves nested objects (areas) as is.
    final me = MeResponse.fromJson({
      ...(jsonDecode(jsonEncode(current)) as Map<String, Object?>),
      'theme': theme.name,
      'time_zone': zone.stored,
    });
    state = ConsoleSession(state.phase, me: me, offline: state.offline);
    if (_native && _tokens.refresh != null) {
      await _store.save(_tokens.refresh!, me);
    }
    final access = await accessToken();
    if (access == null) throw const ApiFailure(ApiFailure.offline);
    await _api.setAppearance(access, theme: theme.name, timeZone: zone.stored);
  }

  Future<String?>? _refreshing;

  /// A valid access token for API calls (sync), refreshed when it is about
  /// to expire, or null when signed out or offline. [force] refreshes even
  /// a token that looks valid (the server answered 401).
  Future<String?> accessToken({bool force = false}) async {
    if (state.phase != SessionPhase.signedIn) return null;
    final access = _tokens.access;
    final expires = _tokens.expires;
    if (!force &&
        access != null &&
        expires != null &&
        clock().isBefore(expires.subtract(const Duration(seconds: 60)))) {
      return access;
    }
    return _refreshing ??= _refreshAccess().whenComplete(
      () => _refreshing = null,
    );
  }

  Future<String?> _refreshAccess() async {
    final refresh = _native ? _tokens.refresh : null;
    if (_native && refresh == null) return null;
    try {
      final t = await _api.refresh(refresh);
      _tokens.accept(t, clock());
      if (_native) await _store.save(_tokens.refresh!, state.me!);
      if (state.offline) {
        state = ConsoleSession(SessionPhase.signedIn, me: state.me);
      }
      return t.accessToken;
    } on ApiFailure catch (e) {
      if (e.isOffline || (e.status ?? 0) >= 500) return null;
      await _forget();
      state = const ConsoleSession(
        SessionPhase.signedOut,
        reason: SignedOutReason.expired,
      );
      return null;
    }
  }

  Future<void> signOut({SignedOutReason reason = SignedOutReason.none}) async {
    final refresh = _tokens.refresh;
    unawaited(_api.logout(_native ? refresh : null).catchError((Object _) {}));
    await _forget();
    state = ConsoleSession(SessionPhase.signedOut, reason: reason);
  }

  Future<void> _forget() async {
    _tokens.clear();
    if (_native) {
      await _store.clear();
      await _lock.disable();
    }
  }

  /// No activity for the idle timeout (F-AUTH-3): the web signs out;
  /// Windows/Android lock and keep the cached data behind the PIN.
  Future<void> idle() async {
    if (state.phase != SessionPhase.signedIn) return;
    if (_native) {
      _tokens
        ..access = null
        ..expires = null;
      state = ConsoleSession(SessionPhase.locked, me: state.me);
    } else {
      await signOut(reason: SignedOutReason.idle);
    }
  }

  /// "Forgot password": asks the IT admin. Throws [ApiFailure] if offline.
  Future<void> requestPasswordHelp(String username) =>
      _api.passwordHelp(username.trim());
}

const consoleLockKey = 'watercheck.console.lock.v1';

final consoleAuthApiProvider = Provider<ConsoleAuthApi>(
  (ref) =>
      throw UnimplementedError('consoleAuthApiProvider must be overridden'),
);

final consoleValuesProvider = Provider<SecureValues>(
  (ref) => SecureStorageValues(),
);

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SessionStore(ref.watch(consoleValuesProvider)),
);

final consoleLockProvider = Provider<AppLock>(
  (ref) => AppLock(ref.watch(consoleValuesProvider), key: consoleLockKey),
);

final sessionProvider = NotifierProvider<SessionController, ConsoleSession>(
  () => SessionController(const RestoredSession(ConsoleSession.signedOut)),
);

/// Client-side copy of the server's rule (at least 10 characters, not only
/// digits and not only letters), so mistakes show before a round trip.
bool passwordAcceptable(String p) =>
    p.length >= 10 &&
    !RegExp(r'^\d+$').hasMatch(p) &&
    !RegExp(r'^\p{L}+$', unicode: true).hasMatch(p);

/// Idle timeout (F-AUTH-3): 30 minutes unless the build sets
/// `--dart-define=WC_IDLE_MINUTES=…`.
const idleTimeout = Duration(
  minutes: int.fromEnvironment('WC_IDLE_MINUTES', defaultValue: 30),
);
