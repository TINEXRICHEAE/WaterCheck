import 'package:api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';

/// The IT admin's API (P11). Online only: people and phones are managed on
/// the server.
final adminApiProvider = Provider<WaterCheckApi>(
  (ref) => WaterCheckApi(ref.watch(consoleDioProvider)),
);

final adminUsersProvider = FutureProvider.autoDispose<List<UserOut>>(
  (ref) => ref.watch(adminApiProvider).admin.users(),
);

final adminInstallationsProvider =
    FutureProvider.autoDispose<List<InstallationOut>>(
      (ref) => ref.watch(adminApiProvider).admin.installations(),
    );

final adminCodesProvider = FutureProvider.autoDispose<List<ActivationCodeOut>>(
  (ref) => ref.watch(adminApiProvider).admin.activationCodes(),
);

/// Responsibility codes and names, from the synced reference data.
final responsibilitiesProvider =
    FutureProvider<List<({String code, String name})>>((ref) async {
      final db = ref.watch(databaseProvider);
      final rows = await db.select(db.responsibilities).get();
      return [for (final r in rows) (code: r.code, name: r.name)]
        ..sort((a, b) => a.name.compareTo(b.name));
    });
