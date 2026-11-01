import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watercheck_console/app/console_sync.dart';

class _Ok implements HttpClientAdapter {
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('a guest reaches public pages; everything else needs signing in '
      '(2026-11-01)', () async {
    final server = _Ok();
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = server;
    dio.interceptors.add(
      BearerInterceptor(({bool force = false}) async => null, dio),
    );
    await dio.get<Object>('/v1/public/links/abcDEF123');
    await expectLater(
      dio.get<Object>('/v1/research/projects'),
      throwsA(isA<DioException>()),
    );
    expect(server.paths, ['/v1/public/links/abcDEF123']);
  });
}
