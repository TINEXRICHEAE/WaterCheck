import 'package:dio/dio.dart';

/// Why a call failed, reduced to what screens need: the server's error code
/// (`detail`, e.g. `expired_code`, `installation_revoked`) or [offline].
class ApiFailure implements Exception {
  const ApiFailure(this.code, {this.status});

  /// No answer from the server (no network, DNS, timeout, refused).
  static const offline = 'offline';

  /// The server answered with something we could not read.
  static const unexpected = 'unexpected';

  final String code;
  final int? status;

  bool get isOffline => code == offline;

  static ApiFailure from(Object error) {
    if (error is ApiFailure) return error;
    if (error is! DioException) return const ApiFailure(unexpected);
    final response = error.response;
    if (response == null) {
      return switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.unknown => const ApiFailure(offline),
        _ => const ApiFailure(unexpected),
      };
    }
    final data = response.data;
    final detail = data is Map ? data['detail'] : null;
    return ApiFailure(
      detail is String ? detail : 'http_${response.statusCode}',
      status: response.statusCode,
    );
  }

  @override
  String toString() => 'ApiFailure($code${status == null ? '' : ', $status'})';
}
