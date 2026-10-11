import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

/// Signs every Collect request with the installation secret (ADR-009,
/// ADR-011): `X-Signature = HMAC-SHA256(secret, METHOD \n path \n
/// timestamp \n sha256(body) \n nonce)`. `path` is the API path without the
/// reverse-proxy prefix (Caddy strips `/api`), plus the query string. The
/// random `X-Nonce` lets identical requests repeat within one second.
///
/// [clockOffset] is server time minus device time, learned at activation and
/// from responses, so a wrong phone clock does not break signing (§5.2).
class InstallationSigner extends Interceptor {
  InstallationSigner({
    required this.installationId,
    required this.secret,
    this.proxyPrefix = '/api',
    Duration Function()? clockOffset,
    DateTime Function()? now,
  }) : _offset = clockOffset ?? (() => Duration.zero),
       _now = now ?? DateTime.now;

  final String installationId;
  final String secret;
  final String proxyPrefix;
  final Duration Function() _offset;
  final DateTime Function() _now;

  /// The headers for one request; public for tests and other HTTP stacks.
  /// Without a [nonce] the older four-line message is signed.
  Map<String, String> headersFor(
    String method,
    String path,
    List<int> body, {
    String? nonce,
  }) {
    final timestamp = (_now().add(_offset()).millisecondsSinceEpoch ~/ 1000)
        .toString();
    final message = [
      method.toUpperCase(),
      path,
      timestamp,
      sha256.convert(body).toString(),
      ?nonce,
    ].join('\n');
    final signature = Hmac(
      sha256,
      utf8.encode(secret),
    ).convert(utf8.encode(message)).toString();
    return {
      'X-Installation-Id': installationId,
      'X-Timestamp': timestamp,
      'X-Signature': signature,
      'X-Nonce': ?nonce,
    };
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    var path = uri.path;
    if (proxyPrefix.isNotEmpty && path.startsWith(proxyPrefix)) {
      path = path.substring(proxyPrefix.length);
    }
    if (uri.query.isNotEmpty) path = '$path?${uri.query}';
    final data = options.data;
    final body = switch (data) {
      null => const <int>[],
      final String s => utf8.encode(s),
      final List<int> bytes => bytes,
      _ => utf8.encode(jsonEncode(data)),
    };
    // Send exactly the bytes that were signed.
    if (data != null && data is! String && data is! List<int>) {
      options.data = utf8.decode(body);
      options.contentType ??= Headers.jsonContentType;
    }
    options.headers.addAll(
      headersFor(options.method, path, body, nonce: newNonce()),
    );
    handler.next(options);
  }

  static final _random = Random.secure();

  /// 16 random bytes as hex.
  static String newNonce() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
