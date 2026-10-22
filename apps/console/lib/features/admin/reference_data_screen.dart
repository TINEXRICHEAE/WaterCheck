import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../dashboard/dashboard_state.dart';

typedef _ReferenceData = ({
  ParameterCatalogue catalogue,
  List<ReferenceProfile> profiles,
  List<TesterProfile> testers,
  DomainRules rules,
  List<RefArea> areas,
});

final _referenceDataProvider = FutureProvider<_ReferenceData>((ref) async {
  ref.watch(dataVersionProvider);
  final repo = ref.watch(referenceDataRepositoryProvider);
  const order = ['country', 'district', 'subcounty', 'parish', 'village'];
  final units = await repo.adminUnits()
    ..sort((a, b) => order.indexOf(a.level) - order.indexOf(b.level));
  return (
    catalogue: await repo.catalogue(),
    profiles: await repo.referenceProfiles(),
    testers: await repo.testerProfiles(),
    rules: await repo.rules(),
    areas: [for (final u in units) (id: u.id, level: u.level, name: u.name)],
  );
});

/// Debug view of the seeded reference data (P2 gate).
class ReferenceDataScreen extends ConsumerWidget {
  const ReferenceDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_referenceDataProvider);
    return data.when(
      loading: () => const PageLoading(),
      error: (e, _) => ErrorView(
        error: e,
        onRetry: () => ref.invalidate(_referenceDataProvider),
      ),
      data: (d) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ReferenceDataView(
            catalogue: d.catalogue,
            profiles: d.profiles,
            testerProfiles: d.testers,
            rules: d.rules,
            areas: d.areas,
          ),
        ),
      ),
    );
  }
}
