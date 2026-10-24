import 'dart:async';

import 'package:flutter/foundation.dart';
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

/// True where a keyboard is likely (a computer, or a browser on one): the
/// map buttons then show their keys (2026-10-24).
bool get mapKeysLikely => switch (defaultTargetPlatform) {
  TargetPlatform.windows ||
  TargetPlatform.macOS ||
  TargetPlatform.linux => true,
  _ => false,
};

/// A four-way pad to move the map (tap: a third of the view; hold: keep
/// moving) beside the zoom buttons. On a computer each button shows its
/// key: arrows or W/A/S/D, R and F (2026-10-24).
class MapNavigationButtons extends StatefulWidget {
  const MapNavigationButtons({super.key, required this.motion, this.showKeys});

  final MapMotion motion;

  /// Key labels; by default on computers only ([mapKeysLikely]).
  final bool? showKeys;

  @override
  State<MapNavigationButtons> createState() => _MapNavigationButtonsState();
}

class _MapNavigationButtonsState extends State<MapNavigationButtons> {
  Timer? _hold;

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  MapCamera? get _camera {
    try {
      return widget.motion.controller.camera;
    } catch (_) {
      return null;
    }
  }

  /// Moves the centre by [by] screen pixels.
  void _pan(Offset by, {bool animate = true}) {
    final camera = _camera;
    if (camera == null) return;
    final to = camera.unprojectAtZoom(camera.projectAtZoom(camera.center) + by);
    if (animate) {
      widget.motion.moveTo(to, camera.zoom);
    } else {
      widget.motion.controller.move(to, camera.zoom);
    }
  }

  Offset _step(Offset direction) {
    final size = _camera?.size ?? const Size(300, 300);
    return Offset(
      direction.dx * size.width / 3,
      direction.dy * size.height / 3,
    );
  }

  void _zoom(double by) {
    final camera = _camera;
    if (camera == null) return;
    widget.motion.moveTo(
      camera.center,
      (camera.zoom + by).clamp(5, 19).toDouble(),
    );
  }

  Widget _button({
    required IconData icon,
    required String tooltip,
    required String? key_,
    required VoidCallback onTap,
    Offset? hold,
  }) {
    final keys = widget.showKeys ?? mapKeysLikely;
    final button = IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onTap,
    );
    final labelled = !keys || key_ == null
        ? button
        : Stack(
            clipBehavior: Clip.none,
            children: [
              button,
              Positioned(
                right: 2,
                bottom: 2,
                child: ExcludeSemantics(child: _KeyCap(key_)),
              ),
            ],
          );
    if (hold == null) return labelled;
    // Held down: keeps moving in small steps until released.
    return GestureDetector(
      onLongPressStart: (_) {
        _hold?.cancel();
        _hold = Timer.periodic(
          const Duration(milliseconds: 40),
          (_) => _pan(hold * 12, animate: false),
        );
      },
      onLongPressEnd: (_) => _hold?.cancel(),
      onLongPressCancel: () => _hold?.cancel(),
      child: labelled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    const up = Offset(0, -1), down = Offset(0, 1);
    const left = Offset(-1, 0), right = Offset(1, 0);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _button(
              icon: Icons.keyboard_arrow_up,
              tooltip: l10n.mapMoveUp,
              key_: '↑ W',
              hold: up,
              onTap: () => _pan(_step(up)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _button(
                  icon: Icons.keyboard_arrow_left,
                  tooltip: l10n.mapMoveLeft,
                  key_: '← A',
                  hold: left,
                  onTap: () => _pan(_step(left)),
                ),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.open_with, size: 18),
                ),
                _button(
                  icon: Icons.keyboard_arrow_right,
                  tooltip: l10n.mapMoveRight,
                  key_: '→ D',
                  hold: right,
                  onTap: () => _pan(_step(right)),
                ),
              ],
            ),
            _button(
              icon: Icons.keyboard_arrow_down,
              tooltip: l10n.mapMoveDown,
              key_: '↓ S',
              hold: down,
              onTap: () => _pan(_step(down)),
            ),
            const SizedBox(width: 96, child: Divider(height: 9)),
            _button(
              icon: Icons.add,
              tooltip: l10n.mapZoomIn,
              key_: 'R',
              onTap: () => _zoom(1),
            ),
            _button(
              icon: Icons.remove,
              tooltip: l10n.mapZoomOut,
              key_: 'F',
              onTap: () => _zoom(-1),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small key label ("↑ W") on a map button.
class _KeyCap extends StatelessWidget {
  const _KeyCap(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          label,
          style: TextStyle(fontSize: 9, height: 1.2, color: scheme.onSurface),
        ),
      ),
    );
  }
}
