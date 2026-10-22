import 'package:api_client/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../dashboard/dashboard_state.dart';

/// The IT admin's API (P11). Online only: people and phones are managed on
/// the server.
final adminApiProvider = Provider<WaterCheckApi>(
  (ref) => WaterCheckApi(ref.watch(consoleDioProvider)),
);

/// The refresh button bumps the data version: every list fetches again.
WaterCheckApi _api(Ref ref) {
  ref.watch(dataVersionProvider);
  return ref.watch(adminApiProvider);
}

final adminUsersProvider = FutureProvider.autoDispose<List<UserOut>>(
  (ref) => _api(ref).admin.users(),
);

final adminInstallationsProvider =
    FutureProvider.autoDispose<List<InstallationOut>>(
      (ref) => _api(ref).admin.installations(),
    );

final adminCodesProvider = FutureProvider.autoDispose<List<ActivationCodeOut>>(
  (ref) => _api(ref).admin.activationCodes(),
);

/// Responsibility codes and names, from the synced reference data.
final responsibilitiesProvider =
    FutureProvider<List<({String code, String name})>>((ref) async {
      ref.watch(dataVersionProvider);
      final db = ref.watch(databaseProvider);
      final rows = await db.select(db.responsibilities).get();
      return [for (final r in rows) (code: r.code, name: r.name)]
        ..sort((a, b) => a.name.compareTo(b.name));
    });

final adminHealthProvider = FutureProvider.autoDispose<Health>(
  (ref) => _api(ref).admin.systemHealth(),
);

final adminSecurityProvider = FutureProvider.autoDispose<SecurityIn>(
  (ref) => _api(ref).admin.getSecurity(),
);

final adminRoutingProvider = FutureProvider.autoDispose<Routing>(
  (ref) => _api(ref).admin.routing(),
);

final adminPendingParametersProvider =
    FutureProvider.autoDispose<List<PendingParameter>>(
      (ref) => _api(ref).admin.pendingParameters(),
    );

final adminCardsProvider = FutureProvider.autoDispose<List<CardOut>>(
  (ref) => _api(ref).admin.adminResponseCards(),
);

/// The audit log filters (F-ADM-7): an action prefix and a date range.
typedef AuditFilter = ({String? action, DateTime? since, DateTime? until});

final adminAuditProvider = FutureProvider.autoDispose
    .family<List<AuditEntry>, AuditFilter>(
      (ref, f) =>
          _api(ref).admin
              .audit(action: f.action, since: f.since, until: f.until),
    );

/// Archive actions that can still be restored (ADR-018).
final adminArchivedProvider = FutureProvider.autoDispose<List<ArchivedItem>>(
  (ref) => _api(ref).admin.archived(),
);
