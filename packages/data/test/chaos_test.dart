@TestOn('vm')
@Timeout(Duration(minutes: 10))
library;

import 'dart:io';
import 'dart:math';

import 'package:api_client/api_client.dart';
import 'package:crypto/crypto.dart';
import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'support/fixtures.dart';

/// Chaos tests §12.3 #1–#5 and the 2G throughput target (P6 gate) against a
/// running dev stack, through Toxiproxy (`docker compose --profile chaos
/// up -d`). As an IT admin:
///   WC_CHAOS=1 WC_LIVE_USER=… WC_LIVE_PASSWORD=… flutter test test/chaos_test.dart
final _env = Platform.environment;
const _api = 'http://localhost/api';
const _proxied = 'http://localhost:18080/api';
const _toxiproxy = 'http://localhost:8474';

/// Toxiproxy's control API.
class Toxi {
  final _dio = Dio(BaseOptions(baseUrl: _toxiproxy));

  Future<void> reset() async {
    await _dio.post<void>('/reset');
    try {
      await _dio.get<void>('/proxies/wc');
    } on DioException {
      await _dio.post<void>(
        '/proxies',
        data: {'name': 'wc', 'listen': '0.0.0.0:18080', 'upstream': 'caddy:80'},
      );
    }
  }

  Future<void> add(
    String name,
    String type,
    Map<String, Object> attributes, {
    String stream = 'downstream',
  }) => _dio.post<void>(
    '/proxies/wc/toxics',
    data: {
      'name': name,
      'type': type,
      'stream': stream,
      'toxicity': 1.0,
      'attributes': attributes,
    },
  );

  Future<void> remove(String name) =>
      _dio.delete<void>('/proxies/wc/toxics/$name');
}

class Admin {
  final dio = Dio(BaseOptions(baseUrl: _api));

  Future<void> signIn() async {
    final t = await WaterCheckApi(dio).auth.login(
      body: LoginRequest(
        username: _env['WC_LIVE_USER']!,
        password: _env['WC_LIVE_PASSWORD']!,
      ),
    );
    dio.options.headers['Authorization'] = 'Bearer ${t.accessToken}';
  }

  Future<String> code() async =>
      (await WaterCheckApi(dio).installations.newActivationCode(
        body: const NewCodeRequest(areaCode: 'ABIM-ENT', maxInstallations: 1),
      )).code;
}

/// A Collect phone: its own database, credentials and sync service.
class Device {
  Device._(this.db, this.credentials, this.villageId, this.sync, this.now);

  final AppDatabase db;
  final ActivateResponse credentials;
  final String villageId;
  final SyncService sync;
  DateTime Function() now;

  late final origin = SubmissionOrigin.collect(
    installationId: credentials.installationId,
    collector: CollectorSnapshot(
      collectorKey: IdGenerator().next(),
      profileVersion: 1,
      fullName: 'Chaos Collector',
      phone: '+256700000000',
      collectorType: 'vht',
      village: 'Entebbe',
      parish: 'P',
      subcounty: 'S',
      district: 'Abim',
    ),
  );

  static Future<Device> activate(
    Admin admin, {
    Duration receiveTimeout = const Duration(seconds: 30),
  }) async {
    final a = await WaterCheckApi(Dio(BaseOptions(baseUrl: _api))).installations
        .activate(body: ActivateRequest(code: await admin.code()));
    final db = memoryDb();
    await SeedImporter(db).importBundle(await seedFromInfra());
    final dio =
        Dio(
            BaseOptions(
              baseUrl: _proxied,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: receiveTimeout,
            ),
          )
          ..interceptors.addAll([
            InstallationSigner(
              installationId: a.installationId,
              secret: a.secret,
            ),
            GzipRequestInterceptor(),
          ]);
    var clock = DateTime.now;
    final device = Device._(
      db,
      a,
      a.area.id,
      SyncService(
        db,
        ApiSyncTransport(dio),
        streams: ['reference', 'area:${a.area.id}'],
        clock: () => clock(),
      ),
      DateTime.now,
    );
    device.now = DateTime.now;
    clock = () => device.now();
    return device;
  }

  DriftSourceRepository get sources =>
      DriftSourceRepository(db, clock: () => now());
  DriftTestingRepository get testing =>
      DriftTestingRepository(db, clock: () => now());

  /// One visit: a new source, then a test with the core readings
  /// (source + session + result + 4 readings, + an alert when unsafe).
  Future<void> visit(String code, {String tds = '560'}) async {
    final source = await sources.create(
      NewSource(villageId: villageId, code: code, sourceType: 'borehole'),
      origin,
    );
    final reference = DriftReferenceDataRepository(db, clock: () => now());
    final profile = (await reference.referenceProfiles()).firstWhere(
      (p) => p.code == 'US201-2008-ClassII',
    );
    final readings = [
      ReadingInput(
        parameterCode: 'temp',
        unit: '°C',
        value: Decimal.parse('25'),
      ),
      ReadingInput(
        parameterCode: 'ph',
        unit: 'pH',
        value: Decimal.parse('7.1'),
      ),
      ReadingInput(
        parameterCode: 'ec',
        unit: 'µS/cm',
        value: Decimal.parse('800'),
      ),
      ReadingInput(
        parameterCode: 'tds',
        unit: 'mg/L',
        value: Decimal.parse(tds),
      ),
    ];
    final classifier = Classifier(
      catalogue: await reference.catalogue(),
      rules: await reference.rules(),
    );
    await testing.submit(
      TestSubmission(
        sourceId: source.id,
        profile: profile,
        calibrated: true,
        readings: readings,
        classification: classifier.classify(
          readings: readings,
          profile: profile,
        ),
      ),
      origin,
    );
  }

  Future<Map<String, int>> counts() async => {
    'water_source': (await db.select(db.waterSources).get()).length,
    'test_session': (await db.select(db.testSessions).get()).length,
    'test_result': (await db.select(db.testResults).get()).length,
    'reading': (await db.select(db.readings).get()).length,
    'alert': (await db.select(db.alerts).get()).length,
  };

  Future<Map<String, int>> outboxStatus() async {
    final out = <String, int>{};
    for (final r in await db.select(db.outbox).get()) {
      out[r.status] = (out[r.status] ?? 0) + 1;
    }
    return out;
  }
}

void main() {
  final enabled = _env['WC_CHAOS'] != null;
  final toxi = Toxi();
  final admin = Admin();
  final unique = Random().nextInt(1 << 30).toRadixString(36).toUpperCase();

  setUpAll(() async {
    if (!enabled) return;
    await toxi.reset();
    await admin.signIn();
  });
  setUp(() async {
    if (enabled) await toxi.reset();
  });

  test('#1 a week offline syncs completely, with no duplicates', () async {
    final phone = await Device.activate(admin);
    final start = DateTime.now().subtract(const Duration(days: 7));
    for (var day = 0; day < 7; day++) {
      phone.now = () => start.add(Duration(days: day, hours: 9));
      for (var v = 0; v < 4; v++) {
        await phone.visit('W$unique-$day$v', tds: v == 0 ? '1500' : '560');
      }
    }
    phone.now = DateTime.now;
    final made = await phone.counts();
    final report = await phone.sync.run();
    expect(report.ok, isTrue, reason: '$report');
    expect(report.rejected, 0);
    expect(await phone.outboxStatus(), {'sent': report.sent});

    // Another phone in the village receives exactly the same records.
    final other = await Device.activate(admin);
    expect((await other.sync.run()).ok, isTrue);
    final mine = await phone.counts();
    final theirs = await other.counts();
    for (final e in made.keys) {
      expect(theirs[e]! >= made[e]!, isTrue, reason: e);
      expect(mine[e], theirs[e], reason: '$e: no duplicates');
    }
    await phone.db.close();
    await other.db.close();
  }, skip: enabled ? false : 'set WC_CHAOS to run against the dev stack');

  test(
    '#2 a sync cut off mid-way resumes with no loss or duplication',
    () async {
      final phone = await Device.activate(admin);
      await phone.sync.run(); // reference data first
      for (var v = 0; v < 5; v++) {
        await phone.visit('K$unique-$v');
      }
      // The server applies the batch but the answer never arrives.
      await toxi.add('cut', 'limit_data', {'bytes': 64});
      final cut = await phone.sync.run(force: true);
      expect(cut.failure, isNotNull);
      expect(await phone.outboxStatus(), {'pending': 35});

      // "App killed and reopened": a new service on the same database.
      await toxi.remove('cut');
      final again = await phone.sync.run(force: true);
      expect(again.ok, isTrue, reason: '$again');
      expect(again.rejected, 0);
      expect(await phone.outboxStatus(), {'sent': 35});
      final other = await Device.activate(admin);
      await other.sync.run();
      final codes = (await other.db.select(other.db.waterSources).get())
          .where((s) => s.code.startsWith('K$unique'))
          .length;
      expect(codes, 5);
      await phone.db.close();
      await other.db.close();
    },
    skip: enabled ? false : 'set WC_CHAOS to run against the dev stack',
  );

  test(
    '#3 two phones edit one source offline: the expected conflict',
    () async {
      final a = await Device.activate(admin);
      await a.visit('C$unique');
      expect((await a.sync.run()).ok, isTrue);
      final b = await Device.activate(admin);
      expect((await b.sync.run()).ok, isTrue);
      final source = (await b.db.select(b.db.waterSources).get()).firstWhere(
        (s) => s.code == 'C$unique',
      );

      await a.sources.update(
        source.id,
        const SourceChanges(functionalStatus: 'broken'),
        a.origin,
      );
      await b.sources.update(
        source.id,
        const SourceChanges(
          functionalStatus: 'partly_functional',
          name: 'Renamed by B',
        ),
        b.origin,
      );
      expect((await a.sync.run()).conflicts, 0);
      final second = await b.sync.run();
      expect(second.conflicts, 1);
      // After the pull, B shows the server's status and its own new name.
      final now = (await b.db.select(b.db.waterSources).get()).firstWhere(
        (s) => s.id == source.id,
      );
      expect(now.functionalStatus, 'broken');
      expect(now.name, 'Renamed by B');
      final note = (await b.db.select(b.db.outbox).get()).last.lastError;
      expect(note, contains('kept_server:functional_status'));
      await a.db.close();
      await b.db.close();
    },
    skip: enabled ? false : 'set WC_CHAOS to run against the dev stack',
  );

  test('#4 clocks a year wrong: flagged, not lost', () async {
    final phone = await Device.activate(admin);
    for (final (skew, flag) in [
      (const Duration(days: 365), 'device_time_in_future'),
      (const Duration(days: -365), 'device_time_too_old'),
    ]) {
      phone.now = () => DateTime.now().add(skew);
      await phone.visit('T$unique-${skew.isNegative ? 'past' : 'future'}');
      phone.now = DateTime.now;
      final report = await phone.sync.run(force: true);
      expect(report.ok, isTrue);
      expect(report.rejected, 0);
      // The server marked the session (read through the raw feed).
      final dio = Dio(BaseOptions(baseUrl: _api))
        ..interceptors.add(
          InstallationSigner(
            installationId: phone.credentials.installationId,
            secret: phone.credentials.secret,
          ),
        );
      final feed = <IncomingChange>[];
      String? cursor;
      while (true) {
        final page = await ApiSyncTransport(dio)
            .pull('area:${phone.villageId}', cursor, limit: 1000);
        feed.addAll(page.changes);
        cursor = page.nextCursor;
        if (!page.hasMore) break;
      }
      final flagged = feed.where(
        (c) =>
            c.entity == 'test_session' &&
            (c.data['clock_flags']! as List).contains(flag),
      );
      expect(flagged, isNotEmpty, reason: flag);
    }
    await phone.db.close();
  }, skip: enabled ? false : 'set WC_CHAOS to run against the dev stack');

  test('#5 a failing server: backoff grows, no busy retry loop', () async {
    final phone = await Device.activate(
      admin,
      receiveTimeout: const Duration(seconds: 3),
    );
    await phone.sync.run();
    await phone.visit('F$unique');
    // Connections hang (timeout), then get reset.
    await toxi.add('hang', 'timeout', {'timeout': 0});
    final first = await phone.sync.run(force: true);
    expect(first.failure, isNotNull);
    await toxi.remove('hang');
    await toxi.add('reset', 'reset_peer', {'timeout': 0});

    final waits = <Duration>[];
    var attempts = 0;
    final until = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(until)) {
      final r = await phone.sync.run();
      if (!r.skipped) attempts++;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    // Within the 5 s+ backoff window nothing more is tried.
    expect(attempts, 0);
    for (var i = 0; i < 4; i++) {
      final state = await (phone.db.select(
        phone.db.syncState,
      )..where((t) => t.stream.equals('push'))).getSingle();
      waits.add(state.nextAttemptAt!.difference(state.lastAttemptAt!));
      await phone.sync.run(force: true);
    }
    for (var i = 1; i < waits.length; i++) {
      expect(waits[i] > waits[i - 1] * 1.4, isTrue, reason: '$waits');
    }
    await toxi.remove('reset');
    expect((await phone.sync.run(force: true)).ok, isTrue);
    expect(await phone.outboxStatus(), {'sent': 7});
    await phone.db.close();
  }, skip: enabled ? false : 'set WC_CHAOS to run against the dev stack');

  test(
    'gate: Collect → Console with the collector, and Console → Collect',
    () async {
      // A stakeholder whose area covers the village (created by the CLI).
      final dio = Dio(BaseOptions(baseUrl: _api));
      final t = await WaterCheckApi(dio).auth.login(
        body: LoginRequest(
          username: _env['WC_STAKEHOLDER_USER']!,
          password: _env['WC_STAKEHOLDER_PASSWORD']!,
        ),
      );
      final me = await WaterCheckApi(
        Dio(
          BaseOptions(
            baseUrl: _api,
            headers: {'Authorization': 'Bearer ${t.accessToken}'},
          ),
        ),
      ).auth.me();
      final consoleDb = memoryDb();
      await SeedImporter(consoleDb).importBundle(await seedFromInfra());
      final console = SyncService(
        consoleDb,
        ApiSyncTransport(
          Dio(
            BaseOptions(
              baseUrl: _proxied,
              headers: {'Authorization': 'Bearer ${t.accessToken}'},
            ),
          )..interceptors.add(GzipRequestInterceptor()),
        ),
        streams: const ['reference', 'scope'],
      );

      final phone = await Device.activate(admin);
      await phone.visit('X$unique', tds: '1500');
      expect((await phone.sync.run()).ok, isTrue);

      // The submission reaches the Console with the collector snapshot.
      expect((await console.run()).ok, isTrue);
      final recent = await ActivityQueries(consoleDb).watchRecent().first;
      final mine = recent.firstWhere((r) => r.sourceCode == 'X$unique');
      expect(mine.collectorName, 'Chaos Collector');
      expect(mine.serverOverall, isNotNull, reason: 'server classified it');

      // The stakeholder marks the source broken; the phone sees it.
      final source = (await consoleDb.select(consoleDb.waterSources).get())
          .firstWhere((s) => s.code == 'X$unique');
      await DriftSourceRepository(consoleDb).update(
        source.id,
        const SourceChanges(functionalStatus: 'broken'),
        SubmissionOrigin.console(userId: me.id),
      );
      final pushed = await console.run();
      expect((pushed.ok, pushed.sent, pushed.rejected), (true, 1, 0));
      expect((await phone.sync.run(force: true)).ok, isTrue);
      final onPhone = await (phone.db.select(
        phone.db.waterSources,
      )..where((s) => s.id.equals(source.id))).getSingle();
      expect(onPhone.functionalStatus, 'broken');
      expect(onPhone.version, 2);
      await phone.db.close();
      await consoleDb.close();
    },
    skip: enabled && _env['WC_STAKEHOLDER_USER'] != null
        ? false
        : 'set WC_CHAOS and WC_STAKEHOLDER_USER/PASSWORD',
  );

  test(
    'P7 gate: a photo upload cut at about 50% resumes; the hash matches',
    () async {
      final phone = await Device.activate(admin);
      await phone.visit('P$unique');
      final source = (await phone.db.select(phone.db.waterSources).get())
          .firstWhere((s) => s.code == 'P$unique');
      // A real-sized photo: noise compresses badly, so it stays large.
      final r = Random(5);
      final image = img.Image(width: 900, height: 700);
      for (final p in image) {
        p
          ..r = r.nextInt(256)
          ..g = r.nextInt(256)
          ..b = r.nextInt(256);
      }
      final jpeg = compressPhoto(img.encodeJpg(image, quality: 95))!;
      final files = MemoryPhotoFiles();
      final id = await DriftAttachmentRepository(phone.db, files).addPhoto(
        owner: PhotoOwner.source,
        ownerId: source.id,
        jpeg: jpeg,
        origin: phone.origin,
      );
      expect((await phone.sync.run()).ok, isTrue); // metadata first

      final dio =
          Dio(
              BaseOptions(
                baseUrl: _proxied,
                receiveTimeout: const Duration(seconds: 10),
              ),
            )
            ..interceptors.add(
              InstallationSigner(
                installationId: phone.credentials.installationId,
                secret: phone.credentials.secret,
              ),
            );
      AttachmentUploader uploader() => AttachmentUploader(
        phone.db,
        files,
        ApiAttachmentTransport(dio),
        networkAllowed: () async => true,
      );
      // The proxy closes the connection after about half of the bytes.
      await toxi.add('half', 'limit_data', {
        'bytes': jpeg.length ~/ 2,
      }, stream: 'upstream');
      final cut = await uploader().run();
      expect(cut.failure, isNotNull);
      final transport = ApiAttachmentTransport(
        Dio(BaseOptions(baseUrl: _api))
          ..interceptors.add(
            InstallationSigner(
              installationId: phone.credentials.installationId,
              secret: phone.credentials.secret,
            ),
          ),
      );
      final midway = await transport.state(id);
      expect(midway.received, greaterThan(0));
      expect(midway.received, lessThan(jpeg.length));

      await toxi.remove('half');
      final resumed = await uploader().run();
      expect(resumed.uploaded, 1, reason: '${resumed.failure}');
      expect((await transport.state(id)).status, 'uploaded');
      // Read back from object storage through the API.
      final stored = await Dio(BaseOptions(baseUrl: _api)).get<List<int>>(
        '/v1/attachments/$id/content',
        options: Options(
          responseType: ResponseType.bytes,
          headers:
              InstallationSigner(
                installationId: phone.credentials.installationId,
                secret: phone.credentials.secret,
              ).headersFor(
                'GET',
                '/v1/attachments/$id/content',
                const [],
                nonce: InstallationSigner.newNonce(),
              ),
        ),
      );
      expect(
        sha256.convert(stored.data!).toString(),
        sha256.convert(jpeg).toString(),
      );
      // ignore: avoid_print
      print('photo ${jpeg.length} B, cut at ${midway.received} B, resumed');
      await phone.db.close();
    },
    skip: enabled ? false : 'set WC_CHAOS to run against the dev stack',
  );

  test(
    'gate: 200 pending records sync in under 2 minutes on a 2G-like link',
    () async {
      final phone = await Device.activate(admin);
      await phone.sync.run(); // reference data arrives with activation
      for (var v = 0; v < 29; v++) {
        await phone.visit('G$unique-$v'); // 29 visits ≈ 203 records
      }
      final pending = (await phone.outboxStatus())['pending']!;
      expect(pending, greaterThanOrEqualTo(200));
      // ≈ 50 kbit/s each way and 500 ms latency (ADR-011, plan [DECIDE]).
      await toxi.add('latency', 'latency', {'latency': 500, 'jitter': 100});
      await toxi.add('down', 'bandwidth', {'rate': 6});
      await toxi.add('up', 'bandwidth', {'rate': 6}, stream: 'upstream');
      final watch = Stopwatch()..start();
      final report = await phone.sync.run(force: true);
      watch.stop();
      expect(report.ok, isTrue, reason: '$report');
      expect(report.sent, pending);
      // ignore: avoid_print
      print('$pending records in ${watch.elapsed} (pulled ${report.pulled})');
      expect(watch.elapsed, lessThan(const Duration(minutes: 2)));
      await phone.db.close();
    },
    skip: enabled ? false : 'set WC_CHAOS to run against the dev stack',
  );
}
