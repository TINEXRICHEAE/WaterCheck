import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../l10n/ui_kit_localizations.dart';
import 'map_motion.dart';

/// How every WaterCheck map can be moved (2026-10-22, ADR-022): touch
/// (drag, pinch, double tap), mouse (drag, wheel), keyboard (arrow keys or
/// W/A/S/D to move, R/F to zoom in/out) and the on-screen zoom buttons.
/// Rotation is off: a turned map confuses more than it helps.
const mapInteraction = InteractionOptions(
  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
  keyboardOptions: KeyboardOptions(
    enableWASDPanning: true,
    enableRFZooming: true,
  ),
);

/// Zoom in and out, for mouse, touch and screen-reader users alike; each
/// button is labelled and at least 48 px.
class MapZoomButtons extends StatelessWidget {
  const MapZoomButtons({super.key, required this.motion});

  final MapMotion motion;

  void _zoom(double by) {
    final MapCamera camera;
    try {
      camera = motion.controller.camera;
    } catch (_) {
      return;
    }
    motion.moveTo(camera.center, (camera.zoom + by).clamp(5, 19).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.mapZoomIn,
            icon: const Icon(Icons.add),
            onPressed: () => _zoom(1),
          ),
          const SizedBox(width: 32, child: Divider(height: 1)),
          IconButton(
            tooltip: l10n.mapZoomOut,
            icon: const Icon(Icons.remove),
            onPressed: () => _zoom(-1),
          ),
        ],
      ),
    );
  }
}
