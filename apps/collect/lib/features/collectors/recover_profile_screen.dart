import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sync/collect_sync.dart';

/// "I already have a profile" (ADR-020): a collector who lost a phone, or
/// works on a second one, enters the one-time code from their IT admin or
/// stakeholder and comes back as the same person.
class RecoverProfileScreen extends ConsumerStatefulWidget {
  const RecoverProfileScreen({super.key});

  @override
  ConsumerState<RecoverProfileScreen> createState() =>
      _RecoverProfileScreenState();
}

class _RecoverProfileScreenState extends ConsumerState<RecoverProfileScreen> {
  final _code = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  /// Older phones sent only some details; missing ones stay empty for the
  /// collector to fill in with "Edit".
  static CollectorSnapshot _snapshot(String key, Map<String, dynamic> j) =>
      CollectorSnapshot(
        collectorKey: key,
        profileVersion: (j['profile_version'] as num?)?.toInt() ?? 1,
        fullName: j['full_name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        collectorType: j['collector_type'] as String? ?? 'other',
        village: j['village'] as String? ?? '',
        parish: j['parish'] as String? ?? '',
        subcounty: j['subcounty'] as String? ?? '',
        district: j['district'] as String? ?? '',
        organisation: j['organisation'] as String?,
      );

  Future<void> _recover() async {
    final l10n = AppLocalizations.of(context);
    final dio = ref.read(collectApiDioProvider);
    if (dio == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await dio.post<Map<String, dynamic>>(
        '/v1/collectors/recover',
        data: {'code': _code.text.trim()},
      );
      final key = r.data!['collector_key'] as String;
      final saved = await ref
          .read(collectorProfileRepositoryProvider)
          .restore(
            _snapshot(
              key,
              (r.data!['snapshot'] as Map).cast<String, dynamic>(),
            ),
          );
      await ref.read(appGateProvider.notifier).selectCollector(key);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recoverWelcome(saved.fullName))),
      );
      context.go('/');
      // Their district's sources come with the next sync.
      await ref.read(syncControllerProvider.notifier).run(force: true);
    } on Object catch (e) {
      if (!mounted) return;
      setState(
        () => _error = '$e'.contains('404')
            ? l10n.recoverInvalid
            : l10n.recoverOffline,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recoverTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.recoverIntro),
          const SizedBox(height: 16),
          TextField(
            controller: _code,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: l10n.recoverCode,
              hintText: 'ABCDE-23456',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _recover(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy || _code.text.trim().length < 6 ? null : _recover,
            child: BusyLabel(busy: _busy, child: Text(l10n.recoverButton)),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.recoverWhoGives,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
