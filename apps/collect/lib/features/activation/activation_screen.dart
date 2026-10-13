import 'package:api_client/api_client.dart';
import 'package:data/data.dart' show defaultApiUrl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'collect_api.dart';
import 'installation_service.dart';

/// Scanning needs a camera plugin, which this app ships on Android only.
bool get canScanCodes =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// First run, once online: the IT admin's activation code (F-AUTH-7).
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _code = TextEditingController();
  final _server = TextEditingController(text: defaultApiUrl());
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _server.dispose();
    super.dispose();
  }

  String _message(AppLocalizations l10n, ApiFailure f) => switch (f.code) {
    'invalid_code' => l10n.activationInvalidCode,
    'expired_code' => l10n.activationExpiredCode,
    'code_used_up' => l10n.activationUsedUp,
    ApiFailure.offline => l10n.activationOffline,
    _ => l10n.activationFailed(f.code),
  };

  Future<void> _scan() async {
    final raw = await context.push<String>('/activate/scan');
    if (raw == null || !mounted) return;
    final parsed = parseActivationInput(raw);
    if (parsed == null) {
      setState(() => _error = AppLocalizations.of(context).activationBadQr);
      return;
    }
    setState(() {
      _code.text = parsed.code;
      if (parsed.server != null) _server.text = parsed.server!;
      _error = null;
    });
  }

  Future<void> _activate() async {
    final l10n = AppLocalizations.of(context);
    final parsed = parseActivationInput(_code.text);
    final server = _server.text.trim();
    if (parsed == null) {
      setState(() => _error = l10n.activationCodeFormat);
      return;
    }
    if (Uri.tryParse(server)?.hasScheme != true) {
      setState(() => _error = l10n.activationServerFormat);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(installationServiceProvider)
          .activate(apiUrl: server, code: parsed.code);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = _message(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activationTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(child: AppLogo(size: 72, decorative: true)),
            const SizedBox(height: 12),
            Text(l10n.activationIntro, style: text.bodyLarge),
            const SizedBox(height: 24),
            TextField(
              controller: _code,
              enabled: !_busy,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              enableSuggestions: false,
              style: text.titleLarge?.copyWith(letterSpacing: 2),
              decoration: InputDecoration(
                labelText: l10n.activationCodeLabel,
                hintText: 'K7QM-RT4W-9XHB',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _activate(),
            ),
            if (canScanCodes) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _busy ? null : _scan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.activationScan),
                ),
              ),
            ],
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.activationServer),
              subtitle: Text(
                _server.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              children: [
                TextField(
                  controller: _server,
                  enabled: !_busy,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.activationServerLabel,
                    helperText: l10n.activationServerHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
              ],
            ),
            SizedBox(
              height: 56,
              child: _error == null
                  ? null
                  : Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
            ),
            FilledButton.icon(
              onPressed: _busy ? null : _activate,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_busy ? l10n.activationWorking : l10n.activationGo),
            ),
          ],
        ),
      ),
    );
  }
}
