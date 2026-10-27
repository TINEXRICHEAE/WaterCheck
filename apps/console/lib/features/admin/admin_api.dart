import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// A side's Console accounts and the IT admins (ADR-031).
final adminUsersProvider = FutureProvider.autoDispose
    .family<List<UserOut>, AppSide>(
      (ref, side) => _api(ref).admin.users(side: sideParam(side)),
    );

/// The devices a side's testers use.
final adminInstallationsProvider = FutureProvider.autoDispose
    .family<List<InstallationOut>, AppSide>(
      (ref, side) => _api(ref).admin.installations(side: sideParam(side)),
    );

/// The side as the API names it.
Side sideParam(AppSide side) => Side.values.byName(side.name);

/// The side an admin page is shown on (ADR-031): research's own admin
/// pages live under /research, water's under /admin. They never lead to
/// the other side's pages.
AppSide adminSide(BuildContext context) =>
    GoRouterState.of(context).uri.path.startsWith('/research')
    ? AppSide.research
    : AppSide.water;

/// Where this side's admin pages are.
String adminBase(AppSide side) =>
    side == AppSide.research ? '/research/admin' : '/admin';

/// A collector's page on this side.
String collectorPath(AppSide side, String key) =>
    side == AppSide.research ? '/research/collectors/$key' : '/collectors/$key';

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
