import 'dart:math' as math;

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
    // Light: highest contrast, for sunlight. Dark: standard contrast, so the
    // blue accents and tinted surfaces stay; at full contrast the dark scheme
    // turned almost black and white (2026-10-25).
    final generated = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      contrastLevel: brightness == Brightness.light ? 1 : 0,
    );
    final scheme = brightness == Brightness.light
        ? generated
        : _darkAccents(generated);
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

/// Dark mode: deep-navy surfaces (not neutral grey) and blue for what is
/// chosen (tabs, toggles, chips), so the app keeps its water-blue identity.
ColorScheme _darkAccents(ColorScheme s) => s.copyWith(
  primary: const Color(0xFF8FC4FF),
  onPrimary: const Color(0xFF00315E),
  primaryContainer: const Color(0xFF0B4C8F),
  onPrimaryContainer: const Color(0xFFD5E6FF),
  secondaryContainer: const Color(0xFF1D4F82),
  onSecondaryContainer: const Color(0xFFDCEBFF),
  surface: const Color(0xFF0D1520),
  onSurface: const Color(0xFFE3E9F1),
  onSurfaceVariant: const Color(0xFFB9C4D2),
  surfaceContainerLowest: const Color(0xFF09101A),
  surfaceContainerLow: const Color(0xFF111B28),
  surfaceContainer: const Color(0xFF15202F),
  surfaceContainerHigh: const Color(0xFF1A2737),
  surfaceContainerHighest: const Color(0xFF223042),
  outline: const Color(0xFF7D8B9C),
  outlineVariant: const Color(0xFF34435A),
);

/// Narrower than this (a phone held upright), screens use [phoneDensity].
const phoneWidth = 600.0;

bool isPhone(BuildContext context) =>
    MediaQuery.sizeOf(context).width < phoneWidth;

/// A share of the screen's width for this kind of screen (phone, tablet,
/// computer), so sizes follow the device rather than fixed pixel caps
/// (2026-10-25).
double screenShare(
  BuildContext context, {
  double phone = 1,
  double tablet = 0.7,
  double desktop = 0.5,
}) {
  final w = MediaQuery.sizeOf(context).width;
  return w * (w < phoneWidth ? phone : (w < 1200 ? tablet : desktop));
}

/// Keeps [child] within [screenShare] of the screen's width.
class RelativeWidth extends StatelessWidget {
  const RelativeWidth({
    super.key,
    required this.child,
    this.phone = 1,
    this.tablet = 0.7,
    this.desktop = 0.5,
  });

  final Widget child;
  final double phone;
  final double tablet;
  final double desktop;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: screenShare(
        context,
        phone: phone,
        tablet: tablet,
        desktop: desktop,
      ),
    ),
    child: child,
  );
}

/// Phones (2026-10-25): smaller text and icons, compact controls and
/// fields, a lower app bar and a lower bottom bar with small labels, so
/// content keeps the screen. Touch targets stay at least 40 dp.
ThemeData phoneDensity(ThemeData base) {
  final text = _phoneText(base.textTheme);
  return base.copyWith(
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textTheme: text,
    iconTheme: base.iconTheme.copyWith(size: 20),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        iconSize: 20,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.all(8),
      ),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      toolbarHeight: 44,
      titleTextStyle: text.titleMedium,
      iconTheme: const IconThemeData(size: 20),
      actionsIconTheme: const IconThemeData(size: 20),
    ),
    navigationBarTheme: base.navigationBarTheme.copyWith(
      height: 56,
      // Every label stays (they name the tabs), in small type.
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: const WidgetStatePropertyAll(IconThemeData(size: 20)),
      labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: text.labelSmall,
      padding: const EdgeInsets.symmetric(horizontal: 2),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: text.labelMedium,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(56, 40),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      iconSize: 20,
      extendedSizeConstraints: const BoxConstraints.tightFor(height: 44),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 14),
      extendedTextStyle: text.labelLarge,
    ),
    listTileTheme: const ListTileThemeData(minVerticalPadding: 6, dense: true),
  );
}

/// Text at 84 %, but never below 10.5 so small print stays readable.
TextTheme _phoneText(TextTheme t) {
  TextStyle? f(TextStyle? s) => s?.fontSize == null
      ? s
      : s!.copyWith(fontSize: math.max(10.5, s.fontSize! * 0.84));
  return t.copyWith(
    displayLarge: f(t.displayLarge),
    displayMedium: f(t.displayMedium),
    displaySmall: f(t.displaySmall),
    headlineLarge: f(t.headlineLarge),
    headlineMedium: f(t.headlineMedium),
    headlineSmall: f(t.headlineSmall),
    titleLarge: f(t.titleLarge),
    titleMedium: f(t.titleMedium),
    titleSmall: f(t.titleSmall),
    bodyLarge: f(t.bodyLarge),
    bodyMedium: f(t.bodyMedium),
    bodySmall: f(t.bodySmall),
    labelLarge: f(t.labelLarge),
    labelMedium: f(t.labelMedium),
    labelSmall: f(t.labelSmall),
  );
}

/// Applies [phoneDensity] below [phoneWidth]; use in MaterialApp.builder.
class PhoneDensity extends StatelessWidget {
  const PhoneDensity({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => isPhone(context)
      ? Theme(data: phoneDensity(Theme.of(context)), child: child)
      : child;
}
