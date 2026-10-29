import 'package:domain/domain.dart' show LocationSource;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:ui_kit/map_kit.dart';
import 'package:ui_kit/ui_kit.dart';

import 'ip_location.dart';

/// On a computer: where its location came from, how good and how old, a
/// fresh reading, and setting it by hand anywhere (2026-10-29).
class IpPlaceBar extends ConsumerWidget {
  const IpPlaceBar({super.key, required this.placing, required this.onPlacing});

  /// The next tap on the map sets the location.
  final bool placing;
  final ValueChanged<bool> onPlacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!deviceHasNoGps) return const SizedBox.shrink();
    final at = ref.watch(computerPositionProvider);
    final p = at.value;
    return ComputerLocationBar(
      source: p?.source.name,
      at: p?.at,
      accuracyM: p?.accuracyM,
      place: p?.area?.place,
      problem: p?.problem,
      loading: at.isLoading,
      placing: placing,
      onPlacing: onPlacing,
      onRefresh: () => ref.read(computerPositionProvider.notifier).refresh(),
    );
  }
}

/// The internet guess's area on the map, while that is the source.
Widget? ipAreaLayer(WidgetRef ref) =>
    switch (ref.watch(computerPositionProvider).value) {
      ComputerPosition(source: LocationSource.internet, :final area?) =>
        IpAreaLayer(area: area),
      _ => null,
    };

/// Sets the computer's location at [at], by hand; says so.
Future<void> placeHere(BuildContext context, WidgetRef ref, LatLng at) async {
  final ui = UiKitLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  await ref.read(computerPositionProvider.notifier).place(at);
  messenger.showSnackBar(SnackBar(content: Text(ui.locSetDone)));
}
