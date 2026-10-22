import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/dashboard/dashboard_state.dart';
import 'perf.dart';
import 'providers.dart';
import 'request_activity.dart';
import 'session.dart';

/// Adds the signed-in user's access token, refreshing it when needed, and
/// retries once after a 401 with a fresh token.
class BearerInterceptor extends QueuedInterceptor {
  BearerInterceptor(this._token, this._dio);

  final Future<String?> Function({bool force}) _token;
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _token();
    if (token == null) {
      handler.reject(
        DioException.connectionError(
          requestOptions: options,
          reason: 'not signed in or offline',
        ),
      );
      return;
    }
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || options.extra['retried'] == true) {
      handler.next(err);
      return;
    }
    final token = await _token(force: true);
    if (token == null) {
      handler.next(err);
      return;
    }
    try {
      final retry = await _dio.fetch<dynamic>(
        options
          ..extra['retried'] = true
          ..headers['Authorization'] = 'Bearer $token',
      );
      handler.resolve(retry);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}

/// The signed-in user's HTTP client (bearer token, refreshed as needed).
final consoleDioProvider = Provider<Dio>((ref) {
  final session = ref.read(sessionProvider.notifier);
  final dio = Dio(
    BaseOptions(
      baseUrl: defaultApiUrl(),
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
  dio.interceptors.addAll([
    BearerInterceptor(session.accessToken, dio),
    GzipRequestInterceptor(),
    RequestActivityInterceptor(),
  ]);
  return dio;
});

/// Console pulls reference data and everything in the user's scope, and
/// pushes queued stakeholder actions (SPEC §8, P6).
final consoleSyncTransportProvider = Provider<SyncTransport>(
  (ref) => ApiSyncTransport(ref.watch(consoleDioProvider)),
);

final consoleSyncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    ref.watch(databaseProvider),
    ref.watch(consoleSyncTransportProvider),
    streams: const ['reference', 'scope'],
  ),
);

class ConsoleSyncState {
  const ConsoleSyncState({this.running = false, this.last});

  final bool running;
  final SyncReport? last;
}

class ConsoleSyncController extends Notifier<ConsoleSyncState> {
  @override
  ConsoleSyncState build() => const ConsoleSyncState();

  Future<SyncReport?> run({bool force = false}) async {
    if (ref.read(sessionProvider).phase != SessionPhase.signedIn) return null;
    state = ConsoleSyncState(running: true, last: state.last);
    final report = await ref.read(consoleSyncServiceProvider).run(force: force);
    perfMark('sync', {'pulled': report.pulled, 'ok': report.ok});
    if (ref.mounted) {
      state = ConsoleSyncState(last: report);
      // New alerts may have brought notifications.
      if (report.ok) ref.invalidate(inboxProvider);
    }
    return report;
  }
}

final consoleSyncProvider =
    NotifierProvider<ConsoleSyncController, ConsoleSyncState>(
      ConsoleSyncController.new,
    );

/// Latest test results in the local cache, newest first (dashboard).
final recentSubmissionsProvider = StreamProvider<List<RecentSubmission>>(
  (ref) => ActivityQueries(ref.watch(databaseProvider)).watchRecent(),
);

/// The user's in-app notifications (F-ALR-4), read from the API.
abstract interface class NotificationsApi {
  Future<Inbox> inbox();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

class HttpNotificationsApi implements NotificationsApi {
  HttpNotificationsApi(this._dio);

  final Dio _dio;

  @override
  Future<Inbox> inbox() => WaterCheckApi(_dio).notifications.inbox();

  @override
  Future<void> markRead(String id) =>
      WaterCheckApi(_dio).notifications.markRead(notificationId: id);

  @override
  Future<void> markAllRead() => WaterCheckApi(_dio).notifications.markAllRead();
}

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => HttpNotificationsApi(ref.watch(consoleDioProvider)),
);

/// Empty while signed out or offline; refreshed after each sync.
final inboxProvider = FutureProvider<Inbox?>((ref) async {
  if (ref.watch(sessionProvider).phase != SessionPhase.signedIn) return null;
  ref.watch(dataVersionProvider);
  try {
    return await ref.watch(notificationsApiProvider).inbox();
  } catch (_) {
    return null;
  }
});

final alertRepositoryProvider = Provider<AlertRepository>(
  (ref) => DriftAlertRepository(ref.watch(databaseProvider)),
);

final testingRepositoryProvider = Provider<TestingRepository>(
  (ref) => DriftTestingRepository(ref.watch(databaseProvider)),
);
