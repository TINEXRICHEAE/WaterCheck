@TestOn('vm')
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart' show CollectorSnapshot, GeoFix;
import 'package:data/src/db/database.dart'
    show AttachmentQueueCompanion, OutboxCompanion;
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'support/fixtures.dart';

/// A server that keeps chunks like the real one (ADR-012) and can fail
/// after a number of chunks.
class FakeUploads implements AttachmentTransport {
  final received = <String, BytesBuilder>{};
  final completed = <String, Uint8List>{};
  final sizes = <String, int>{};
  int? failAfterPuts;
  var puts = 0;

  BytesBuilder _of(String id) => received.putIfAbsent(id, BytesBuilder.new);

  @override
  Future<UploadProgress> state(String id) async => UploadProgress(
    _of(id).length,
    sizes[id]!,
    completed.containsKey(id) ? 'uploaded' : 'pending',
  );

  @override
  Future<UploadProgress> put(String id, int offset, Uint8List chunk) async {
    if (failAfterPuts != null && puts >= failAfterPuts!) {
      throw const SyncFailure(SyncFailureKind.offline, 'offline');
    }
    puts++;
    final have = _of(id);
    if (offset != have.length) throw OffsetMismatch(have.length);
    have.add(chunk);
    return UploadProgress(have.length, sizes[id]!, 'pending');
  }

  @override
  Future<UploadProgress> complete(String id) async {
    completed[id] = _of(id).toBytes();
    return UploadProgress(sizes[id]!, sizes[id]!, 'uploaded');
  }
}

Uint8List noisyJpeg({int width = 3000, int height = 2000}) {
  final r = Random(3);
  final image = img.Image(width: width, height: height);
  for (final p in image) {
    p
      ..r = r.nextInt(256)
      ..g = r.nextInt(256)
      ..b = r.nextInt(256);
  }
  image.exif.gpsIfd.data[0x0002] = img.IfdValueAscii('2.7 N');
  image.exif.imageIfd.orientation = 6; // rotated 90°
  return img.encodeJpg(image, quality: 95);
}

void main() {
  test('photos shrink to 300 KB, upright, without EXIF', () {
    final big = noisyJpeg();
    expect(big.length, greaterThan(1024 * 1024));
    final small = compressPhoto(big)!;
    expect(small.length, lessThanOrEqualTo(maxPhotoBytes));
    final decoded = img.decodeJpg(small)!;
    expect(decoded.exif.isEmpty, isTrue, reason: 'no GPS or device data');
    // Orientation 6 was applied to the pixels: portrait now.
    expect(decoded.height, greaterThan(decoded.width));
    expect(
      compressPhoto(Uint8List.fromList(utf8.encode('not an image'))),
      isNull,
    );
  });

  test('a located photo carries only where and when it was taken', () {
    final small = compressPhoto(
      noisyJpeg(width: 800, height: 600),
      taken: GeoFix(
        lat: 0.4512,
        lon: -33.2041,
        at: DateTime.utc(2026, 10, 25, 8, 30, 5),
        accuracyM: 6.5,
        altitudeM: 1143.2,
        speedMps: 2.5,
        headingDeg: 271,
      ),
    )!;
    final exif = img.decodeJpg(small)!.exif;
    final gps = exif.gpsIfd;
    double deg(String tag) {
      final r = gps[tag]!.toRational(0);
      final m = gps[tag]!.toRational(1);
      final s = gps[tag]!.toRational(2);
      return r.toDouble() + m.toDouble() / 60 + s.toDouble() / 3600;
    }

    expect(gps['GPSLatitudeRef']!.toString(), 'N');
    expect(deg('GPSLatitude'), closeTo(0.4512, 1e-6));
    expect(gps['GPSLongitudeRef']!.toString(), 'W');
    expect(deg('GPSLongitude'), closeTo(33.2041, 1e-6));
    expect(gps['GPSAltitude']!.toRational().toDouble(), closeTo(1143.2, 0.01));
    expect(gps['GPSSpeed']!.toRational().toDouble(), closeTo(9, 0.01));
    expect(gps['GPSDate']!.toString(), '2026:10:25');
    expect(exif.exifIfd['DateTimeOriginal']!.toString(), '2026:10:25 08:30:05');
    // Nothing about the device.
    expect(exif.imageIfd['Make'], isNull);
    expect(exif.imageIfd['Model'], isNull);
  });

  group('photos and uploads', () {
    late AppDatabase db;
    late MemoryPhotoFiles files;
    late DriftAttachmentRepository repo;
    late FakeUploads server;
    var wifi = true;

    AttachmentUploader uploader() => AttachmentUploader(
      db,
      files,
      server,
      networkAllowed: () async => wifi,
      chunkSize: 1000,
    );

    Future<Uint8List> photo() async {
      final bytes = Uint8List.fromList(
        [0xff, 0xd8, 0xff] + List.generate(9997, (i) => i % 251),
      );
      return bytes;
    }

    Future<String> add(Uint8List bytes) async {
      final id = await repo.addPhoto(
        owner: PhotoOwner.source,
        ownerId: 'src-1',
        jpeg: bytes,
        origin: origin,
      );
      server.sizes[id] = bytes.length;
      return id;
    }

    Future<void> metadataSent(String id, {String status = 'sent'}) =>
        (db.update(db.outbox)..where((o) => o.entityId.equals(id))).write(
          OutboxCompanion(status: Value(status)),
        );

    setUp(() {
      db = memoryDb();
      files = MemoryPhotoFiles();
      repo = DriftAttachmentRepository(db, files, clock: fixedClock);
      server = FakeUploads();
      wifi = true;
    });
    tearDown(() => db.close());

    test(
      'adding a photo stores the file, metadata and outbox together',
      () async {
        final bytes = await photo();
        final id = await add(bytes);
        expect(files.files, hasLength(1));
        final out = await db.select(db.outbox).getSingle();
        final payload = jsonDecode(out.payload) as Map;
        expect(payload['owner_type'], 'water_source');
        expect(payload['sha256'], sha256.convert(bytes).toString());
        expect(payload['bytes'], bytes.length);
        expect(await repo.watchWaiting().first, 1);
        final listed = await repo.watchPhotos(PhotoOwner.source, 'src-1').first;
        expect(listed.single.id, id);
        expect(await repo.read(listed.single.path), bytes);
      },
    );

    test(
      'an upload cut at 50% resumes from the server and completes',
      () async {
        final bytes = await photo();
        final id = await add(bytes);
        await metadataSent(id);
        server.failAfterPuts = 5; // 5 of 10 chunks, then the network drops
        final first = await uploader().run();
        expect(first.failure, isNotNull);
        expect(server.received[id]!.length, 5000);
        final queued = await db.select(db.attachmentQueue).getSingle();
        expect((queued.status, queued.bytesSent), ('pending', 5000));

        server.failAfterPuts = null;
        final second = await uploader().run();
        expect(second.uploaded, 1);
        expect(server.puts, 10, reason: 'no chunk sent twice');
        expect(
          sha256.convert(server.completed[id]!).toString(),
          sha256.convert(bytes).toString(),
        );
        expect(
          (await db.select(db.attachments).getSingle()).uploadStatus,
          'uploaded',
        );
        expect(await repo.watchWaiting().first, 0);
      },
    );

    test(
      'a resumed upload follows the server when the phone was wrong',
      () async {
        final bytes = await photo();
        final id = await add(bytes);
        await metadataSent(id);
        // The server already holds 3000 bytes (the phone lost track).
        server.received[id] = BytesBuilder()..add(bytes.sublist(0, 3000));
        await (db.update(db.attachmentQueue))
            .write(const AttachmentQueueCompanion(bytesSent: Value(0)));
        expect((await uploader().run()).uploaded, 1);
        expect(server.completed[id], bytes);
      },
    );

    test('photos wait for their metadata, and for Wi-Fi', () async {
      final id = await add(await photo());
      expect((await uploader().run()).waiting, 1, reason: 'metadata not sent');
      await metadataSent(id);
      wifi = false;
      expect((await uploader().run()).waiting, 1, reason: 'mobile data');
      expect(server.puts, 0);
      wifi = true;
      expect((await uploader().run()).uploaded, 1);
    });

    test('an unsent photo its author removes simply goes', () async {
      final id = await add(await photo());
      final listed = await repo.watchPhotos(PhotoOwner.source, 'src-1').first;
      expect(listed.single.collectorKey, origin.collectorKey);
      await repo.removePhoto(id, origin);
      expect(await repo.watchPhotos(PhotoOwner.source, 'src-1').first, isEmpty);
      expect(files.files, isEmpty);
      expect(await db.select(db.outbox).get(), isEmpty);
    });

    test(
      'a sent photo is removed by telling the server; not by others',
      () async {
        final id = await add(await photo());
        await metadataSent(id);
        const other = SubmissionOrigin.collect(
          installationId: '0199d000-0000-7000-8000-0000000000aa',
          collector: CollectorSnapshot(
            collectorKey: '0199d000-0000-7000-8000-0000000000bb',
            profileVersion: 1,
            fullName: 'Someone Else',
            phone: '+256700000001',
            collectorType: 'vht',
            village: 'Entebbe',
            parish: 'TODO-verify parish',
            subcounty: 'TODO-verify sub-county',
            district: 'Abim',
          ),
        );
        await expectLater(repo.removePhoto(id, other), throwsStateError);
        await repo.removePhoto(id, origin);
        final out = await (db.select(
          db.outbox,
        )..where((o) => o.op.equals('update'))).getSingle();
        expect(out.entity, 'attachment');
        expect(jsonDecode(out.payload)['removed'], true);
        expect(await db.select(db.attachments).get(), isEmpty);
      },
    );

    test('refused metadata ends the upload as rejected', () async {
      final id = await add(await photo());
      await metadataSent(id, status: 'rejected');
      expect((await uploader().run()).rejected, 1);
      expect(
        (await db.select(db.attachmentQueue).getSingle()).status,
        'rejected',
      );
      expect(files.files, hasLength(1), reason: 'the photo is kept');
    });
  });
}
