import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:test/test.dart';

import 'support/seed.dart';

/// The P1 exit-gate properties that are not single vectors.
void main() {
  final seed = Seed.load();
  final classII = 'US201-2008-ClassII';

  List<ReadingInput> core({String tds = '1200'}) => [
    ReadingInput(parameterCode: 'temp', unit: '°C', value: Decimal.parse('25')),
    ReadingInput(parameterCode: 'ph', unit: 'pH', value: Decimal.parse('7')),
    ReadingInput(
      parameterCode: 'ec',
      unit: 'µS/cm',
      value: Decimal.parse('900'),
    ),
    ReadingInput(parameterCode: 'tds', unit: 'mg/L', value: Decimal.parse(tds)),
  ];

  JsonMap deepCopy(JsonMap j) =>
      (jsonDecode(jsonEncode(j)) as Map).cast<String, Object?>();

  test('changing a limit in the seed JSON changes the outcome, no code '
      'change', () {
    final classifier = Classifier(catalogue: seed.catalogue, rules: seed.rules);
    final original = seed.profiles[classII]!;
    expect(
      classifier.classify(readings: core(), profile: original).overall,
      OverallStatus.safe,
    );

    final edited = deepCopy(
      seed.profileJsons.firstWhere((j) => j['code'] == classII),
    );
    for (final l in (edited['limits']! as List).cast<Map<String, Object?>>()) {
      if (l['parameter_code'] == 'tds') l['max'] = 1000;
    }
    expect(
      classifier
          .classify(
            readings: core(),
            profile: ReferenceProfile.fromJson(edited),
          )
          .overall,
      OverallStatus.unsafe,
    );
  });

  test('changing a rule in rules.json changes behaviour, no code change', () {
    final rules = deepCopy(seed.rulesJson)
      ..['required_parameters'] = ['ph', 'ec', 'tds'];
    final classifier = Classifier(
      catalogue: seed.catalogue,
      rules: DomainRules.fromJson(rules),
    );
    final result = classifier.classify(
      readings: core().where((r) => r.parameterCode != 'temp').toList(),
      profile: seed.profiles[classII]!,
    );
    expect(result.overall, OverallStatus.safe);
  });

  test('classification uses only the session profile', () {
    final classifier = Classifier(catalogue: seed.catalogue, rules: seed.rules);
    final readings = core(tds: '800');
    final c1 = seed.profiles['US201-2008-ClassI']!;
    final c2 = seed.profiles[classII]!;
    final r1 = classifier.classify(readings: readings, profile: c1);
    final r2 = classifier.classify(readings: readings, profile: c2);
    expect(r1.overall, OverallStatus.unsafe);
    expect(r1.profileId, c1.id);
    expect(r2.overall, OverallStatus.safe);
    expect(r2.profileId, c2.id);
    // The default profile in rules.json is never consulted implicitly.
    expect(seed.rules.defaultReferenceProfile, classII);
  });

  test('a parameter added to the catalogue JSON is usable with no code '
      'change', () {
    final catalogueJson = deepCopy(seed.catalogueJson);
    (catalogueJson['parameters']! as List).add({
      'code': 'boron',
      'name': 'Boron',
      'category': 'chemical',
      'default_unit': 'mg/L',
      'value_type': 'numeric',
      'plausible_min': 0,
      'plausible_max': 100,
    });
    final catalogue = ParameterCatalogue.fromJson(catalogueJson);
    expect(
      catalogue.inCategory('chemical').map((p) => p.code),
      contains('boron'),
    );

    final profileJson = deepCopy(
      seed.profileJsons.firstWhere((j) => j['code'] == classII),
    );
    (profileJson['limits']! as List).add({
      'parameter_code': 'boron',
      'unit': 'mg/L',
      'max': 1.0,
    });
    final classifier = Classifier(catalogue: catalogue, rules: seed.rules);
    final result = classifier.classify(
      readings: [
        ...core(),
        ReadingInput(
          parameterCode: 'boron',
          unit: 'mg/L',
          value: Decimal.parse('2.4'),
        ),
      ],
      profile: ReferenceProfile.fromJson(profileJson),
    );
    expect(result['boron']!.result, ReadingResult.high);
    expect(result.overall, OverallStatus.unsafe);
  });

  test('every safe vector carries a limitation message code', () {
    final vectors =
        (readJson('$vectorDir/classification.json')['vectors']! as List)
            .cast<Map<String, Object?>>();
    final safe = vectors.where(
      (v) => (v['expect'] as Map)['overall'] == 'safe',
    );
    expect(safe, isNotEmpty);
    for (final v in safe) {
      final limitation = (v['expect'] as Map)['limitation'];
      final hasNegativeEcoli =
          (v['expect'] as Map)['readings'] is Map &&
          ((v['expect'] as Map)['readings'] as Map)['ecoli'] == 'ok';
      expect(
        limitation,
        hasNegativeEcoli ? 'ecoli_negative_reminder' : 'no_germ_test',
        reason: v['id'] as String,
      );
    }
  });
}
