import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';

import 'cookie_reader.dart'
    if (dart.library.js_interop) 'cookie_reader_web.dart';

/// The Console's sign-in calls (F-AUTH-1, F-AUTH-3). All failures are
/// [ApiFailure]s.
///
/// [cookieMode] (web): the refresh token lives in an httpOnly cookie that
/// scripts cannot read; refresh and logout echo the CSRF cookie in a header
/// (ADR-010). Otherwise (Windows, Android) the refresh token comes back in
/// the body and is kept in secure storage.
abstract interface class ConsoleAuthApi {
  bool get cookieMode;
  Future<TokenResponse> login(String username, String password);

  /// [refreshToken] is null in cookie mode.
  Future<TokenResponse> refresh(String? refreshToken);
  Future<TokenResponse> changePassword(
    String accessToken,
    String current,
    String replacement,
  );
  Future<MeResponse> me(String accessToken);
  Future<void> logout(String? refreshToken);
  Future<void> passwordHelp(String username);

  /// Which channels may reach this user (in-app is always on).
  Future<void> setPreferences(
    String accessToken, {
    required bool email,
    required bool push,
    required bool sms,
  });
}

class HttpConsoleAuthApi implements ConsoleAuthApi {
  HttpConsoleAuthApi({
    required this.baseUrl,
    required this.cookieMode,
    Dio Function(String baseUrl)? dio,
  }) : _dioFor = dio ?? _defaultDio;

  final String baseUrl;
  @override
  final bool cookieMode;
  final Dio Function(String baseUrl) _dioFor;

  static Dio _defaultDio(String baseUrl) => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  String? get _transport => cookieMode ? 'cookie' : null;

  AuthClient _client([String? accessToken]) {
    final dio = _dioFor(baseUrl);
    if (accessToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return WaterCheckApi(dio).auth;
  }

  Future<T> _call<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw ApiFailure.from(e);
    }
  }

  @override
  Future<TokenResponse> login(String username, String password) => _call(
    () => _client().login(
      body: LoginRequest(username: username, password: password),
      xTokenTransport: _transport,
    ),
  );

  @override
  Future<TokenResponse> refresh(String? refreshToken) => _call(
    () => refreshToken == null
        ? _client().refresh(xCsrfToken: readCookie('wc_csrf'))
        : _client().refresh(body: RefreshRequest(refreshToken: refreshToken)),
  );

  @override
  Future<TokenResponse> changePassword(
    String accessToken,
    String current,
    String replacement,
  ) => _call(
    () => _client(accessToken).changePassword(
      body: ChangePasswordRequest(
        currentPassword: current,
        newPassword: replacement,
      ),
      xTokenTransport: _transport,
    ),
  );

  @override
  Future<MeResponse> me(String accessToken) =>
      _call(() => _client(accessToken).me());

  @override
  Future<void> logout(String? refreshToken) => _call(
    () => refreshToken == null
        ? _client().logout(xCsrfToken: readCookie('wc_csrf'))
        : _client().logout(body: RefreshRequest(refreshToken: refreshToken)),
  );

  @override
  Future<void> passwordHelp(String username) => _call(
    () => _client().passwordHelp(body: PasswordHelpRequest(username: username)),
  );

  @override
  Future<void> setPreferences(
    String accessToken, {
    required bool email,
    required bool push,
    required bool sms,
  }) => _call(
    () => _client(accessToken).setPreferences(
      body: PreferencesIn(notifyEmail: email, notifyPush: push, notifySms: sms),
    ),
  );
}
