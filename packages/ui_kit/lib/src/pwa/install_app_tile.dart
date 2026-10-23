import 'package:flutter/material.dart';

import '../../l10n/ui_kit_localizations.dart';
import 'pwa_stub.dart' if (dart.library.js_interop) 'pwa_web.dart';

/// "Install app" on the web (ADR-022): adds WaterCheck to the device's home
/// screen or app list, where the browser allows it. Hidden otherwise
/// (already installed, not supported, or not on the web).
class InstallAppTile extends StatefulWidget {
  const InstallAppTile({super.key});

  @override
  State<InstallAppTile> createState() => _InstallAppTileState();
}

class _InstallAppTileState extends State<InstallAppTile> {
  late var _can = pwaCanInstall();

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    if (!_can) return const SizedBox.shrink();
    return ListTile(
      leading: const Icon(Icons.install_desktop),
      title: Text(l10n.installApp),
      subtitle: Text(l10n.installAppHint),
      onTap: () async {
        await pwaInstall();
        if (mounted) setState(() => _can = pwaCanInstall());
      },
    );
  }
}
