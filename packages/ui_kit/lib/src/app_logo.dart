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
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/fieldquire.png',
      package: 'ui_kit',
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: decorative,
      semanticLabel: decorative ? null : UiKitLocalizations.of(context).appLogo,
    );
    if (Theme.of(context).brightness == Brightness.light) return logo;
    // The dark round logo needs a ring to stand out on a dark background.
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          width: size < 40 ? 1.5 : 2,
        ),
      ),
      child: logo,
    );
  }
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
