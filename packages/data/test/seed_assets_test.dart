@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

/// The bundled assets must equal `infra/seed`; run tools/sync_seed.ps1.
void main() {
  test('assets/seed is an exact copy of infra/seed', () {
    final source = Directory(infraSeed);
    final files = source
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    expect(files, isNotEmpty);
    for (final f in files) {
      final rel = f.path.substring(source.path.length + 1);
      final copy = File('assets/seed/$rel');
      expect(
        copy.existsSync(),
        isTrue,
        reason: '$rel missing: run tools/sync_seed.ps1',
      );
      expect(
        copy.readAsStringSync(),
        f.readAsStringSync(),
        reason: '$rel differs: run tools/sync_seed.ps1',
      );
    }
    final copies = Directory('assets/seed')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'));
    expect(copies.length, files.length, reason: 'stale files in assets/seed');
  });
}
