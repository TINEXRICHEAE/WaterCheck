@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:data/data.dart';
import 'package:data/src/db/database.dart' show OutboxCompanion;
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

/// Shared with backend/tests/test_export_file.py: the server must be able to
/// decrypt what Collect exports (ADR-010).
final _vectorFile = File('test/vectors/export_v1.json');

void main() {
  group('PIN hash', () {
    test('verifies the right PIN only', () async {
      const hasher = PinHasher(iterations: 1000);
      final hash = await hasher.hash('2468');
      expect(hash, startsWith(r'pbkdf2-sha256$1000$'));
      expect(await hasher.verify('2468', hash), isTrue);
      expect(await hasher.verify('2469', hash), isFalse);
      expect(await hasher.verify('2468', 'garbage'), isFalse);
      // A fresh salt every time.
      expect(await hasher.hash('2468'), isNot(hash));
    });

    test('accepts 4 to 8 digits', () {
      expect(PinHasher.isValid('1234'), isTrue);
      expect(PinHasher.isValid('12345678'), isTrue);
      expect(PinHasher.isValid('123'), isFalse);
      expect(PinHasher.isValid('12a4'), isFalse);
    });
  });

  group('AppLock', () {
    late DateTime now;
    late AppLock lock;

    setUp(() {
      now = DateTime.utc(2026, 10, 10, 9);
      lock = AppLock(
        MemoryValues(),
        hasher: const PinHasher(iterations: 100),
        clock: () => now,
      );
    });

    test('is off until a PIN is set', () async {
      expect((await lock.config()).enabled, isFalse);
      expect(await lock.unlock('0000'), isA<Unlocked>());
      await lock.setPin('1357');
      expect((await lock.config()).enabled, isTrue);
      expect(await lock.unlock('1357'), isA<Unlocked>());
      await lock.disable();
      expect((await lock.config()).enabled, isFalse);
    });

    test('wrong PINs lead to doubling waits', () async {
      await lock.setPin('1357');
      for (var left = 4; left >= 1; left--) {
        final r = await lock.unlock('0000');
        expect((r as WrongPin).triesBeforeWait, left);
      }
      final fifth = await lock.unlock('0000');
      expect((fifth as MustWait).remaining, const Duration(seconds: 30));
      // During the wait even the right PIN is refused.
      expect(await lock.unlock('1357'), isA<MustWait>());
      now = now.add(const Duration(seconds: 31));
      final sixth = await lock.unlock('0000');
      expect((sixth as MustWait).remaining, const Duration(seconds: 60));
      now = now.add(const Duration(minutes: 2));
      expect(await lock.unlock('1357'), isA<Unlocked>());
      expect((await lock.config()).failures, 0);
    });

    test('keeps the biometric choice when the PIN changes', () async {
      await lock.setPin('1357');
      await lock.setBiometric(true);
      await lock.setPin('2468');
      expect((await lock.config()).biometric, isTrue);
      expect(() => lock.setPin('12'), throwsArgumentError);
    });
  });

  test('installation store round-trips and clears', () async {
    final store = InstallationStore(MemoryValues());
    expect(await store.read(), isNull);
    final creds = InstallationCredentials(
      installationId: 'inst-1',
      secret: 's3cret',
      apiUrl: 'http://localhost/api',
      areaId: 'area-1',
      areaCode: 'ABIM-ENT',
      areaName: 'Entebbe',
      activatedAt: DateTime.utc(2026, 10, 10),
    );
    await store.save(creds);
    await store.setClockOffset(const Duration(seconds: -42));
    await store.markRevoked();
    expect((await store.read())!.areaCode, 'ABIM-ENT');
    expect(await store.clockOffset(), const Duration(seconds: -42));
    expect(await store.isRevoked(), isTrue);
    await store.clear();
    expect(await store.read(), isNull);
    expect(await store.isRevoked(), isFalse);
    expect(await store.clockOffset(), Duration.zero);
  });

  group('export file', () {
    test('round-trips and fails with the wrong secret', () async {
      final file = await ExportFile.encrypt(
        installationId: 'inst-1',
        secret: 'right',
        content: {
          'items': [1, 2, 3],
        },
        createdAt: DateTime.utc(2026, 10, 10),
      );
      final header = jsonDecode(file) as Map;
      expect(header['installation_id'], 'inst-1');
      expect(file, isNot(contains('items')));
      expect((await ExportFile.decrypt(file, 'right'))['items'], [1, 2, 3]);
      await expectLater(ExportFile.decrypt(file, 'wrong'), throwsA(anything));
    });

    test('matches the shared vector', () async {
      final v = (jsonDecode(_vectorFile.readAsStringSync()) as Map)
          .cast<String, Object?>();
      final file = await ExportFile.encrypt(
        installationId: v['installation_id']! as String,
        secret: v['secret']! as String,
        content: (v['content']! as Map).cast(),
        createdAt: DateTime.parse(v['created_at']! as String),
        nonce: base64.decode(v['nonce']! as String),
      );
      expect(file, v['file']);
    });
  });

  test('unsynced rows and export content', () async {
    final db = memoryDb();
    addTearDown(db.close);
    await SeedImporter(
      db,
      clock: fixedClock,
    ).importBundle(await seedFromInfra());
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            entity: 'water_source',
            entityId: 'src-1',
            op: 'insert',
            payload: '{"code":"ABIM-ENT-001"}',
            createdAt: DateTime.utc(2026, 10, 10),
          ),
        );
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            entity: 'water_source',
            entityId: 'src-2',
            op: 'insert',
            payload: '{}',
            createdAt: DateTime.utc(2026, 10, 10),
            status: const Value('sent'),
          ),
        );
    final rows = await DriftOutboxRepository(db).unsynced();
    expect(rows.map((r) => r.entityId), ['src-1']);
    final content = unsyncedExportContent(
      installationId: 'inst-1',
      schemaVersion: localSchemaVersion,
      exportedAt: DateTime.utc(2026, 10, 10),
      rows: rows,
    );
    final items = content['items']! as List;
    expect((items.single as Map)['payload'], {'code': 'ABIM-ENT-001'});
  });

  test('published documents import only when newer', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final seed = await seedFromInfra();
    final importer = SeedImporter(db, clock: fixedClock);
    await importer.importBundle(seed);
    expect(await importer.importPublished(rules: seed.rules), isEmpty);
    final newer = {
      ...seed.rules,
      'version': (seed.rules['version']! as int) + 1,
    };
    expect(await importer.importPublished(rules: newer), ['rules']);
    final profile = seed.referenceProfiles.first;
    expect(
      await importer.importPublished(
        profiles: [
          {...profile, 'version': (profile['version']! as int) + 1},
        ],
      ),
      ['reference_profile:${profile['code']}'],
    );
  });
}
