import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';

/// The dashboard's filters, shared by the dashboard, sources, collectors
/// and map (SPEC P9): one area, one period, one profile.
class DashboardSettings {
  const DashboardSettings({this.areaId, this.days = 30, this.profileId});

  /// Null: all the user's areas.
  final String? areaId;
  final int days;

  /// Null: each result under the profile used at collection (F-RPT-7).
  final String? profileId;

  DashboardSettings copyWith({
    String? areaId,
    int? days,
    String? profileId,
    bool allAreas = false,
    bool asCollected = false,
  }) => DashboardSettings(
    areaId: allAreas ? null : areaId ?? this.areaId,
    days: days ?? this.days,
    profileId: asCollected ? null : profileId ?? this.profileId,
  );
}

class DashboardSettingsNotifier extends Notifier<DashboardSettings> {
  @override
  DashboardSettings build() => const DashboardSettings();

  void area(String? id) => state = id == null
      ? state.copyWith(allAreas: true)
      : state.copyWith(areaId: id);

  void days(int d) => state = state.copyWith(days: d);

  void profile(String? id) => state = id == null
      ? state.copyWith(asCollected: true)
      : state.copyWith(profileId: id);
}

final dashboardSettingsProvider =
    NotifierProvider<DashboardSettingsNotifier, DashboardSettings>(
      DashboardSettingsNotifier.new,
    );

final dashboardQueriesProvider = Provider<DashboardQueries>(
  (ref) => DashboardQueries(ref.watch(databaseProvider)),
);

/// Bumped after each sync and local action, so the dashboard refreshes.
class DataVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final dataVersionProvider = NotifierProvider<DataVersion, int>(DataVersion.new);

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  ref.watch(dataVersionProvider);
  ref.watch(consoleSyncProvider.select((s) => s.last));
  final s = ref.watch(dashboardSettingsProvider);
  final now = DateTime.now().toUtc();
  return ref
      .watch(dashboardQueriesProvider)
      .load(
        DashboardFilter(
          from: now.subtract(Duration(days: s.days)),
          to: now,
          areaId: s.areaId,
          profileId: s.profileId,
        ),
      );
});

/// Published profiles to compare with (custom ones are only "as collected").
final comparableProfilesProvider = FutureProvider<List<ReferenceProfile>>(
  (ref) async => [
    for (final p
        in await ref.watch(referenceDataRepositoryProvider).referenceProfiles())
      if (!p.isCustom) p,
  ],
);

/// Areas the user can pick: theirs and the units below them; IT admins and
/// national scope get every district.
final selectableAreasProvider =
    FutureProvider<List<({String id, String name, String level})>>((ref) async {
      final me = ref.watch(sessionProvider).me;
      final units = await ref
          .watch(referenceDataRepositoryProvider)
          .adminUnits();
      if (me == null) return const [];
      final mine = {for (final a in me.areas) a.id};
      final national =
          me.role == 'it_admin' ||
          me.areas.any((a) => const {'country', 'national'}.contains(a.level));
      return [
        for (final u in units)
          if (mine.contains(u.id) ||
              (national && const {'district', 'region'}.contains(u.level)) ||
              (mine.contains(u.parentId) && u.level != 'village'))
            (id: u.id, name: u.name, level: u.level),
      ]..sort((a, b) => a.name.compareTo(b.name));
    });
