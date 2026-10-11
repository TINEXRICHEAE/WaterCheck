import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// A section that is planned but not built yet; says what it will do.
class PlaceholderSection extends StatelessWidget {
  const PlaceholderSection({
    super.key,
    required this.title,
    required this.hint,
    required this.phase,
  });

  final String title;
  final String hint;
  final String phase;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(hint, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Chip(label: Text(AppLocalizations.of(context).comingIn(phase))),
            ],
          ),
        ),
      ),
    );
  }
}
