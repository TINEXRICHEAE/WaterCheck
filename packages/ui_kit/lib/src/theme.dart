import 'package:flutter/material.dart';

/// Status colours, chosen for contrast in sunlight; always paired with text
/// and an icon (SPEC §11).
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.safe,
    required this.unsafe,
    required this.inconclusive,
    required this.due,
    required this.neutral,
  });

  static const light = StatusColors(
    safe: Color(0xFF1B6B3A),
    unsafe: Color(0xFFB3261E),
    inconclusive: Color(0xFF7A4F00),
    due: Color(0xFF8A4B00),
    neutral: Color(0xFF4A5A62),
  );

  static const dark = StatusColors(
    safe: Color(0xFF7DD99C),
    unsafe: Color(0xFFFFB4AB),
    inconclusive: Color(0xFFF2C46B),
    due: Color(0xFFFFB86B),
    neutral: Color(0xFFB4C4CB),
  );

  final Color safe;
  final Color unsafe;
  final Color inconclusive;
  final Color due;
  final Color neutral;

  @override
  StatusColors copyWith({
    Color? safe,
    Color? unsafe,
    Color? inconclusive,
    Color? due,
    Color? neutral,
  }) => StatusColors(
    safe: safe ?? this.safe,
    unsafe: unsafe ?? this.unsafe,
    inconclusive: inconclusive ?? this.inconclusive,
    due: due ?? this.due,
    neutral: neutral ?? this.neutral,
  );

  @override
  StatusColors lerp(StatusColors? other, double t) => other == null
      ? this
      : StatusColors(
          safe: Color.lerp(safe, other.safe, t)!,
          unsafe: Color.lerp(unsafe, other.unsafe, t)!,
          inconclusive: Color.lerp(inconclusive, other.inconclusive, t)!,
          due: Color.lerp(due, other.due, t)!,
          neutral: Color.lerp(neutral, other.neutral, t)!,
        );
}

/// High-contrast theme readable in sunlight (SPEC §11).
abstract final class WaterCheckTheme {
  static const _seed = Color(0xFF0B5CAD);

  /// Minimum touch target for field use (SPEC §11: ≥ 48 dp).
  static const double minTouchTarget = 48;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      contrastLevel: 1,
    );
    return ThemeData(
      colorScheme: scheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [
        brightness == Brightness.light ? StatusColors.light : StatusColors.dark,
      ],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, minTouchTarget),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 12),
    );
  }
}
