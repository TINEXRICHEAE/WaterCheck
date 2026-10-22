import 'package:flutter_map/flutter_map.dart';

/// Web Mercator drawn once, not repeated sideways (2026-10-22, ADR-021).
///
/// flutter_map 8 paints lines once per world copy and stops when a copy is
/// off screen; with a long road route it kept finding copies "visible" and
/// threw "Infinite loop going beyond 30 for world width …" on every frame
/// (seen in the Console map). Uganda never crosses the date line, so the
/// copies are not needed.
class NoRepeatCrs extends Epsg3857 {
  const NoRepeatCrs();

  @override
  bool get replicatesWorldLongitude => false;
}
