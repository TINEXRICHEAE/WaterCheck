import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../app/services.dart';
import '../activation/collect_api.dart' show parseHttpDate;
import '../photos/photo_service.dart';

/// Server time minus device time (SPEC §5.2), kept fresh from every
/// response's `Date` header so signatures stay valid on a wrong clock.
class ClockOffset extends Notifier<Duration> {
  ClockOffset(this._initial);

  final Duration _initial;

  @override
  Duration build() => _initial;

  void set(Duration offset) {
    if ((offset - state).abs() < const Duration(seconds: 2)) return;
    state = offset;
    unawaited(ref.read(installationStoreProvider).setClockOffset(offset));
  }
}

final clockOffsetProvider = NotifierProvider<ClockOffset, Duration>(
  () => ClockOffset(Duration.zero),
);

/// Learns the clock offset from responses.
class DateHeaderInterceptor extends Interceptor {
  DateHeaderInterceptor(this.onOffset);

  final void Function(Duration offset) onOffset;

  void _read(Headers headers) {
    final date = headers.value('date');
    final server = date == null ? null : parseHttpDate(date);
    if (server != null) onOffset(server.difference(DateTime.now()));
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _read(response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final r = err.response;
    if (r != null) _read(r.headers);
    handler.next(err);
  }
}

/// The signed, gzipping HTTP client for this installation (shared by the
/// app and the Android background worker).
Dio collectSyncDio(
  InstallationCredentials c, {
  required Duration Function() clockOffset,
  void Function(Duration offset)? onOffset,
}) {
  var prefix = Uri.parse(c.apiUrl).path;
  if (prefix.endsWith('/')) prefix = prefix.substring(0, prefix.length - 1);
  return Dio(
      BaseOptions(
        baseUrl: c.apiUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    )
    ..interceptors.addAll([
      InstallationSigner(
        installationId: c.installationId,
        secret: c.secret,
        proxyPrefix: prefix,
        clockOffset: clockOffset,
      ),
      // After the signer: the signature covers the uncompressed JSON.
      GzipRequestInterceptor(),
      if (onOffset != null) DateHeaderInterceptor(onOffset),
    ]);
}

/// Streams Collect pulls: reference data and its own village (SPEC §8.2).
List<String> collectStreams(InstallationCredentials c) => [
  'reference',
  'area:${c.areaId}',
];

/// How the app reaches `/v1/sync`; tests replace it.
final syncTransportProvider = Provider<SyncTransport?>((ref) {
  final c = ref.watch(credentialsProvider);
  if (c == null) return null;
  final offset = ref.read(clockOffsetProvider.notifier);
  return ApiSyncTransport(
    collectSyncDio(
      c,
      clockOffset: () => ref.read(clockOffsetProvider),
      onOffset: offset.set,
    ),
  );
});

/// How photos reach `/v1/attachments`; tests replace it.
final attachmentTransportProvider = Provider<AttachmentTransport?>((ref) {
  final c = ref.watch(credentialsProvider);
  if (c == null) return null;
  return ApiAttachmentTransport(
    collectSyncDio(
      c,
      clockOffset: () => ref.read(clockOffsetProvider),
      onOffset: ref.read(clockOffsetProvider.notifier).set,
    ),
  );
});

final attachmentUploaderProvider = Provider<AttachmentUploader?>((ref) {
  final transport = ref.watch(attachmentTransportProvider);
  if (transport == null) return null;
  return AttachmentUploader(
    ref.watch(databaseProvider),
    ref.watch(photoFilesProvider),
    transport,
    networkAllowed: ref.watch(photoNetworkAllowedProvider),
  );
});

final syncServiceProvider = Provider<SyncService?>((ref) {
  final c = ref.watch(credentialsProvider);
  final transport = ref.watch(syncTransportProvider);
  if (c == null || transport == null) return null;
  return SyncService(
    ref.watch(databaseProvider),
    transport,
    streams: collectStreams(c),
  );
});

class SyncUiState {
  const SyncUiState({this.running = false, this.last});

  final bool running;
  final SyncReport? last;
}

/// Runs syncs for the UI and handles what the app must react to: a
/// revoked installation (F-AUTH-4).
class SyncController extends Notifier<SyncUiState> {
  @override
  SyncUiState build() => const SyncUiState();

  Future<SyncReport?> run({bool force = false}) async {
    final sync = ref.read(syncServiceProvider);
    if (sync == null || ref.read(appGateProvider).revoked) return null;
    state = SyncUiState(running: true, last: state.last);
    try {
      final report = await sync.run(force: force);
      if (report.failure?.code == 'installation_revoked') {
        await ref.read(installationStoreProvider).markRevoked();
        ref.read(appGateProvider.notifier).revoked();
      } else if (report.ok) {
        // Photos after their metadata, and only on an allowed network
        // (SPEC §8.3). Readings never wait for photos.
        await ref.read(attachmentUploaderProvider)?.run();
      }
      if (ref.mounted) state = SyncUiState(last: report);
      return report;
    } catch (e) {
      if (ref.mounted) state = SyncUiState(last: state.last);
      rethrow;
    }
  }

  /// The connection came back: try now rather than at the backoff time.
  Future<void> connected() async {
    await ref.read(syncServiceProvider)?.resetBackoff();
    await run();
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncUiState>(
  SyncController.new,
);

/// `true` whenever some network is available.
final connectivityProvider = Provider<Stream<bool>>(
  (ref) => const Stream.empty(),
);

final pushStateProvider = StreamProvider<SyncStateRow?>(
  (ref) => ref.watch(outboxRepositoryProvider).watchPushState(),
);

final rejectedProvider = StreamProvider<List<OutboxRow>>(
  (ref) => ref.watch(outboxRepositoryProvider).watchRejected(),
);
