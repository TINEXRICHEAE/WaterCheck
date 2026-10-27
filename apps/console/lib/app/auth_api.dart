import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart' show AppSide, legalVersions;

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
  Future<TokenResponse> login(
    String username,
    String password, {
    AppSide side = AppSide.water,
  });

  /// Open sign-up on a side, its documents ticked (ADR-031).
  Future<TokenResponse> signUp({
    required AppSide side,
    required String username,
    required String fullName,
    required String password,
    String? organisation,
    String? phone,
  });

  /// Opens (or signs in to) this person's linked account on [side].
  Future<TokenResponse> join(String accessToken, AppSide side, String password);

  /// Signs in to this person's linked account on [side].
  Future<TokenResponse> switchSide(String accessToken, AppSide side);

  /// Records that the side's current documents were accepted.
  Future<void> acceptLegal(String accessToken, AppSide side);

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

  /// Theme and time zone; they follow the user to any device.
  Future<void> setAppearance(
    String accessToken, {
    required String theme,
    required String timeZone,
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
  Future<TokenResponse> login(
    String username,
    String password, {
    AppSide side = AppSide.water,
  }) => _call(
    () => _client().login(
      body: LoginRequest(
        username: username,
        password: password,
        side: LoginRequestSide.values.byName(side.name),
      ),
      xTokenTransport: _transport,
    ),
  );

  @override
  Future<TokenResponse> signUp({
    required AppSide side,
    required String username,
    required String fullName,
    required String password,
    String? organisation,
    String? phone,
  }) => _call(
    () => _client().register(
      body: SignUpRequest(
        side: SignUpRequestSide.values.byName(side.name),
        username: username,
        fullName: fullName,
        password: password,
        acceptedLegal: legalVersions[side]!,
        organisation: organisation,
        phone: phone,
      ),
      xTokenTransport: _transport,
    ),
  );

  @override
  Future<TokenResponse> join(
    String accessToken,
    AppSide side,
    String password,
  ) => _call(
    () => _client(accessToken).joinSide(
      body: JoinRequest(
        side: JoinRequestSide.values.byName(side.name),
        password: password,
        acceptedLegal: legalVersions[side]!,
      ),
      xTokenTransport: _transport,
    ),
  );

  @override
  Future<TokenResponse> switchSide(String accessToken, AppSide side) => _call(
    () => _client(accessToken).switchSide(
      body: SwitchRequest(side: SwitchRequestSide.values.byName(side.name)),
      xTokenTransport: _transport,
    ),
  );

  @override
  Future<void> acceptLegal(String accessToken, AppSide side) => _call(() {
    final dio = _dioFor(baseUrl);
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
    return WaterCheckApi(dio).profile.acceptLegal(
      body: LegalIn(
        version: legalVersions[side]!,
        side: LegalInSide.values.byName(side.name),
      ),
    );
  });

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

  @override
  Future<void> setAppearance(
    String accessToken, {
    required String theme,
    required String timeZone,
  }) => _call(
    () => _client(accessToken).setAppearance(
      body: AppearanceIn(theme: theme, timeZone: timeZone),
    ),
  );
}
