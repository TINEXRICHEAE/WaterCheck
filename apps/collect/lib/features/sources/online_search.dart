import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../sync/collect_sync.dart';

/// A source found on the server, outside the districts this phone holds
/// (ADR-019 slice B).
typedef SourceHit = ({
  String id,
  String code,
  String? name,
  String village,
  String? districtId,
  String? district,
  String? latest,
});

/// Searches all of Uganda (online). Null: offline or not activated.
final onlineSourceSearchProvider = FutureProvider.autoDispose
    .family<List<SourceHit>?, String>((ref, query) async {
      final dio = ref.watch(collectApiDioProvider);
      if (dio == null || query.trim().length < 2) return null;
      try {
        final r = await dio.get<List<dynamic>>(
          '/v1/sources/search',
          queryParameters: {'q': query.trim()},
        );
        return [
          for (final h in r.data!.cast<Map<String, dynamic>>())
            (
              id: h['id'] as String,
              code: h['code'] as String,
              name: h['name'] as String?,
              village: h['village'] as String,
              districtId: h['district_id'] as String?,
              district: h['district'] as String?,
              latest: h['latest'] as String?,
            ),
        ];
      } catch (_) {
        return null;
      }
    });

/// A place found on the server anywhere in Uganda: a name on the map, a
/// place someone added (ADR-028), or an official area (with parishes and
/// villages added from phones), with the sub-county it lies in.
typedef OnlinePlace = ({
  String id,
  String name,
  String kind,
  String source,
  double? lat,
  double? lon,
  String? subcountyId,
  String? addedBy,
});

/// Searches places in all of Uganda (online); empty offline, before
/// activation, or on any error, so local suggestions still show.
final onlinePlaceSearchProvider =
    Provider<Future<List<OnlinePlace>> Function(String text)>((ref) {
      return (text) async {
        final dio = ref.read(collectApiDioProvider);
        if (dio == null || text.trim().length < 2) return const [];
        try {
          final r = await dio.get<List<dynamic>>(
            '/v1/places/search',
            queryParameters: {'q': text.trim(), 'limit': 20},
          );
          return [
            for (final h in r.data!.cast<Map<String, dynamic>>())
              (
                id: h['id'] as String,
                name: h['name'] as String,
                kind: h['kind'] as String,
                source: h['source'] as String,
                lat: (h['lat'] as num?)?.toDouble(),
                lon: (h['lon'] as num?)?.toDouble(),
                subcountyId: h['subcounty_id'] as String?,
                addedBy: h['added_by'] as String?,
              ),
          ];
        } catch (_) {
          return const [];
        }
      };
    });

/// Districts added by hand to what this phone syncs ("Get this district");
/// read by the sync in `collect_sync.dart`.
const extraDistrictsKey = 'sync.extra_districts';

/// Adds [districtId] to what this phone syncs, then syncs.
Future<void> addDistrict(WidgetRef ref, String districtId) async {
  final settings = ref.read(localSettingsRepositoryProvider);
  final current =
      (await settings.read(extraDistrictsKey))?.split(',').toSet() ?? {};
  await settings.write(
    extraDistrictsKey,
    {...current, districtId}.where((s) => s.isNotEmpty).join(','),
  );
  await ref.read(syncControllerProvider.notifier).run(force: true);
}
