import 'dart:convert';
import 'dart:io';

import 'package:domain/domain.dart';

/// Repo-relative paths; `dart test` runs from `packages/domain`.
const seedDir = '../../infra/seed';
const vectorDir = 'test/vectors';

JsonMap readJson(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

JsonMap seedJson(String name) => readJson('$seedDir/$name');

class Seed {
  Seed({
    required this.catalogueJson,
    required this.rulesJson,
    required this.profileJsons,
  });

  factory Seed.load() => Seed(
    catalogueJson: seedJson('catalogue.json'),
    rulesJson: seedJson('rules.json'),
    profileJsons: [
      for (final f in Directory('$seedDir/reference_profiles').listSync())
        if (f.path.endsWith('.json')) readJson(f.path),
    ],
  );

  final JsonMap catalogueJson;
  final JsonMap rulesJson;
  final List<JsonMap> profileJsons;

  late final ParameterCatalogue catalogue = ParameterCatalogue.fromJson(
    catalogueJson,
  );
  late final DomainRules rules = DomainRules.fromJson(rulesJson);
  late final Map<String, ReferenceProfile> profiles = {
    for (final j in profileJsons)
      j['code']! as String: ReferenceProfile.fromJson(j),
  };
}

/// Builds the session profile named by a vector: a seeded code, or a custom
/// profile spec `{based_on, code, reason, overrides}`.
ReferenceProfile profileFor(Object? spec, Map<String, ReferenceProfile> all) {
  if (spec is String) return all[spec]!;
  final m = (spec! as Map).cast<String, Object?>();
  return all[m['based_on']! as String]!.customize(
    id: 'custom-${m['code']}',
    code: m['code']! as String,
    reason: m['reason']! as String,
    overrides: [
      for (final o in m['overrides']! as List)
        ParameterLimit.fromJson((o as Map).cast<String, Object?>()),
    ],
  );
}

ReadingInput readingFromVector(JsonMap j) => ReadingInput(
  parameterCode: j['parameter']! as String,
  unit: j['unit'] as String?,
  value: decimalOrNull(j['value']),
  detected: j['detected'] as bool?,
  acceptable: j['acceptable'] as bool?,
  text: j['text'] as String?,
  isDerived: j['derived'] as bool? ?? false,
);
