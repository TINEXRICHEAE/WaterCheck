import 'dart:async';
import 'dart:convert';

import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart' show CollectorSnapshot;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../app/services.dart';
import '../activation/collect_api.dart' show parseHttpDate;
import '../activation/installation_service.dart'
    show installationServiceProvider;
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

/// Streams Collect pulls (ADR-019): reference data, and the whole district
/// of the phone's activation area and of each person using it. Sources
/// elsewhere are found online.
List<String> collectStreams(
  InstallationCredentials c, {
  Iterable<CollectorSnapshot> collectors = const [],
  List<AdminUnit> units = const [],
}) {
  final byId = {for (final u in units) u.id: u};
  String? districtNamed(String name) => units
      .where(
        (u) =>
            u.level == 'district' &&
            u.name.toLowerCase() == name.trim().toLowerCase(),
      )
      .firstOrNull
      ?.id;
  return [
    'reference',
    for (final area in {
      // A device that registered itself has no area (ADR-024).
      if (c.hasArea) districtOf(c.areaId, byId) ?? c.areaId,
      for (final p in collectors) ?districtNamed(p.district),
    })
      'area:$area',
  ];
}

/// Signed requests to the API outside sync (the online source search);
/// tests replace it.
final collectApiDioProvider = Provider<Dio?>((ref) {
  final c = ref.watch(credentialsProvider);
  if (c == null) return null;
  return collectSyncDio(c, clockOffset: () => ref.read(clockOffsetProvider));
});

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
    // The districts of the people using the phone, read at each sync (not
    // watched: a rebuild here would hold the database open).
    moreStreams: () async => [
      ...collectStreams(
        c,
        collectors: await ref
            .read(collectorProfileRepositoryProvider)
            .watchActive()
            .first,
        units: await ref.read(referenceDataRepositoryProvider).adminUnits(),
      ),
      // Districts added from an online search ("Get this district").
      for (final d
          in (await ref
                      .read(localSettingsRepositoryProvider)
                      .read('sync.extra_districts'))
                  ?.split(',') ??
              const <String>[])
        if (d.isNotEmpty) 'area:$d',
    ],
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
    if (ref.read(appGateProvider).revoked) return null;
    // Not registered yet (offline at first start): try now (ADR-024).
    if (ref.read(syncServiceProvider) == null &&
        !await ref.read(installationServiceProvider).ensureRegistered()) {
      return null;
    }
    final sync = ref.read(syncServiceProvider);
    if (sync == null) return null;
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
      await _dropSignedOut();
      if (ref.mounted) state = SyncUiState(last: report);
      return report;
    } catch (e) {
      if (ref.mounted) state = SyncUiState(last: state.last);
      rethrow;
    }
  }

  /// Testers signed out of this device from another one (ADR-024): the
  /// server refused their records; they leave this device.
  Future<void> _dropSignedOut() async {
    final db = ref.read(databaseProvider);
    final refused =
        await (db.select(db.outbox)..where(
              (o) =>
                  o.status.equals('rejected') &
                  o.lastError.equals('collector_signed_out'),
            ))
            .get();
    final keys = <String>{
      for (final o in refused)
        if ((jsonDecode(o.payload) as Map)['collector_key'] case final String k)
          k,
    };
    if (keys.isEmpty) return;
    final profiles = ref.read(collectorProfileRepositoryProvider);
    for (final k in keys) {
      await profiles.deactivate(k);
    }
    if (keys.contains(ref.read(appGateProvider).activeCollectorKey)) {
      await ref.read(appGateProvider.notifier).clearCollector();
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
