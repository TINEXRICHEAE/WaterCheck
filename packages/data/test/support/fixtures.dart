import 'dart:io';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';

/// `flutter test` runs from `packages/data`.
const infraSeed = '../../infra/seed';

Future<SeedBundle> seedFromInfra() {
  final profiles =
      Directory('$infraSeed/reference_profiles')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .map((f) => 'reference_profiles/${f.uri.pathSegments.last}')
          .toList()
        ..sort();
  return SeedBundle.load(
    read: (path) => File('$infraSeed/$path').readAsString(),
    referenceProfilePaths: profiles,
  );
}

AppDatabase memoryDb() {
  // Tests open many independent in-memory databases on purpose.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// A fixed clock for deterministic tests.
DateTime fixedClock() => DateTime.utc(2026, 10, 10, 9);

const collector = CollectorSnapshot(
  collectorKey: '0199d000-0000-7000-8000-000000000001',
  profileVersion: 1,
  fullName: 'Example Collector',
  phone: '+256700000000',
  collectorType: 'vht',
  village: 'Entebbe',
  parish: 'TODO-verify parish',
  subcounty: 'TODO-verify sub-county',
  district: 'Abim',
);

const origin = SubmissionOrigin.collect(
  installationId: '0199d000-0000-7000-8000-0000000000aa',
  collector: collector,
);
