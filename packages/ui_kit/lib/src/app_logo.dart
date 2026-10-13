import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// The WaterCheck icon (design/watercheck-icons): a drop with a check on a
/// navy disc. Used wherever the app shows its own image.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64, this.decorative = false});

  final double size;

  /// True when a visible app name sits next to it (screen readers skip it).
  final bool decorative;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/watercheck.png',
    package: 'ui_kit',
    width: size,
    height: size,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: decorative,
    semanticLabel: decorative ? null : UiKitLocalizations.of(context).appLogo,
  );
}

/// The logo with the app's name, for sign-in, activation and splash screens.
class AppBrand extends StatelessWidget {
  const AppBrand({
    super.key,
    required this.name,
    this.subtitle,
    this.size = 72,
  });

  final String name;
  final String? subtitle;
  final double size;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: size, decorative: true),
        const SizedBox(height: 12),
        Text(name, style: text.headlineSmall, textAlign: TextAlign.center),
        if (subtitle != null)
          Text(subtitle!, style: text.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
