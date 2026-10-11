import 'dart:convert';

import 'package:dio/dio.dart';

import 'gzip_io.dart' if (dart.library.js_interop) 'gzip_web.dart';

/// Gzips request bodies above [minBytes] (SPEC §8.1: small batches over 2G).
/// Add it **after** [InstallationSigner]: the signature covers the plain
/// JSON and the server decompresses before checking it (ADR-011).
class GzipRequestInterceptor extends Interceptor {
  GzipRequestInterceptor({this.minBytes = 1024});

  final int minBytes;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final data = options.data;
    // Photos and other binary bodies are already compressed.
    if (options.contentType == 'application/octet-stream') {
      handler.next(options);
      return;
    }
    final bytes = switch (data) {
      final String s => utf8.encode(s),
      final List<int> b => b,
      null => null,
      _ => utf8.encode(jsonEncode(data)),
    };
    if (bytes != null && bytes.length >= minBytes) {
      final packed = gzipBytes(bytes);
      if (packed != null) {
        options
          ..data = Stream.value(packed)
          ..headers[Headers.contentLengthHeader] = packed.length
          ..headers['Content-Encoding'] = 'gzip'
          ..contentType ??= Headers.jsonContentType;
      }
    }
    handler.next(options);
  }
}
