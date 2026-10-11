import 'package:flutter/material.dart';

/// Temporary home screen used until the real shells land in P2.
class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({
    super.key,
    required this.appName,
    required this.subtitle,
  });

  final String appName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop_outlined, size: 64),
              const SizedBox(height: 16),
              Text(appName, style: text.headlineMedium),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
