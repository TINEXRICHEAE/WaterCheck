import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:flutter/services.dart';

/// The bundled reference data (a copy of `infra/seed`), decoded.
class SeedBundle {
  const SeedBundle({
    required this.catalogue,
    required this.rules,
    required this.lists,
    required this.testerProfiles,
    required this.referenceProfiles,
    required this.responseCards,
    required this.responsibilities,
    required this.adminUnits,
  });

  static const assetPrefix = 'packages/data/assets/seed/';

  /// Builds a bundle from a file reader keyed by seed-relative path, e.g.
  /// `rules.json` or `reference_profiles/US201-2008-ClassII.json`.
  static Future<SeedBundle> load({
    required Future<String> Function(String path) read,
    required List<String> referenceProfilePaths,
  }) async {
    Future<JsonMap> json(String path) async =>
        (jsonDecode(await read(path)) as Map).cast<String, Object?>();
    return SeedBundle(
      catalogue: await json('catalogue.json'),
      rules: await json('rules.json'),
      lists: await json('lists.json'),
      testerProfiles: await json('tester_profiles.json'),
      referenceProfiles: [for (final p in referenceProfilePaths) await json(p)],
      responseCards: await json('response_cards.json'),
      responsibilities: await json('responsibilities.json'),
      adminUnits: await json('admin_units.json'),
    );
  }

  /// Loads from the app bundle; reference profiles are discovered through
  /// the asset manifest, so adding a profile file needs no code change.
  static Future<SeedBundle> fromAssets([AssetBundle? bundle]) async {
    final assets = bundle ?? rootBundle;
    final manifest = await AssetManifest.loadFromAssetBundle(assets);
    final profiles =
        manifest
            .listAssets()
            .where(
              (a) =>
                  a.startsWith('${assetPrefix}reference_profiles/') &&
                  a.endsWith('.json'),
            )
            .map((a) => a.substring(assetPrefix.length))
            .toList()
          ..sort();
    return load(
      read: (path) => assets.loadString('$assetPrefix$path'),
      referenceProfilePaths: profiles,
    );
  }

  final JsonMap catalogue;
  final JsonMap rules;
  final JsonMap lists;
  final JsonMap testerProfiles;
  final List<JsonMap> referenceProfiles;
  final JsonMap responseCards;
  final JsonMap responsibilities;
  final JsonMap adminUnits;
}
