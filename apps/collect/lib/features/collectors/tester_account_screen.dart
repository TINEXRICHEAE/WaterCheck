import 'package:api_client/api_client.dart' show ApiFailure;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../activation/installation_service.dart';
import '../sync/collect_sync.dart';

typedef _Assignment = ({String id, String area, String level, bool byCode});

typedef _Device = ({
  String id,
  String? platform,
  String? label,
  String? shortCode,
  String via,
  DateTime lastSeen,
  bool signedOut,
  bool thisDevice,
});

/// Signed requests for the tester in use; null offline or before sync.
Future<Dio?> _api(WidgetRef ref) async {
  await ref.read(installationServiceProvider).ensureRegistered();
  return ref.read(collectApiDioProvider);
}

final _assignmentsProvider = FutureProvider.autoDispose
    .family<List<_Assignment>?, String>((ref, key) async {
      final dio = ref.watch(collectApiDioProvider);
      if (dio == null) return null;
      try {
        final r = await dio.get<List<dynamic>>(
          '/v1/collectors/$key/assignments',
        );
        return _assignments(r.data!);
      } on Object {
        return null;
      }
    });

List<_Assignment> _assignments(List<dynamic> data) => [
  for (final a in data.cast<Map<String, dynamic>>())
    (
      id: a['id'] as String,
      area: a['area'] as String,
      level: a['level'] as String,
      byCode: a['by_code'] as bool,
    ),
];

final _devicesProvider = FutureProvider.autoDispose
    .family<List<_Device>?, String>((ref, key) async {
      final dio = ref.watch(collectApiDioProvider);
      if (dio == null) return null;
      try {
        final r = await dio.get<List<dynamic>>('/v1/collectors/$key/devices');
        return [
          for (final d in r.data!.cast<Map<String, dynamic>>())
            (
              id: d['installation_id'] as String,
              platform: d['platform'] as String?,
              label: d['label'] as String?,
              shortCode: d['short_code'] as String?,
              via: d['signed_in_via'] as String,
              lastSeen: DateTime.parse(d['last_seen_at'] as String),
              signedOut: d['signed_out_at'] != null,
              thisDevice: d['this_device'] as bool,
            ),
        ];
      } on Object {
        return null;
      }
    });

/// The tester in use (ADR-024): the areas they are officially assigned to
/// (an assignment code from an IT admin), a sign-in code for another
/// device, and the devices that use their profile, some of which they can
/// sign out. Everything here needs the internet.
class TesterAccountScreen extends ConsumerStatefulWidget {
  const TesterAccountScreen({super.key});

  @override
  ConsumerState<TesterAccountScreen> createState() =>
      _TesterAccountScreenState();
}

class _TesterAccountScreenState extends ConsumerState<TesterAccountScreen> {
  final _selected = <String>{};
  var _busy = false;

  String _message(AppLocalizations l10n, Object e) {
    final code = e is DioException ? ApiFailure.from(e).code : null;
    return switch (code) {
      'invalid_code' => l10n.accountCodeInvalid,
      'expired_code' => l10n.accountCodeExpired,
      'code_used_up' => l10n.accountCodeUsedUp,
      'sync_first' => l10n.accountSyncFirst,
      'wrong_code' => l10n.accountConfirmWrong,
      'request_expired' => l10n.accountConfirmExpired,
      _ => l10n.recoverOffline,
    };
  }

  Future<void> _run(Future<void> Function(Dio dio) action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final dio = await _api(ref);
      if (dio == null) throw StateError('offline');
      await action(dio);
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_message(l10n, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _ask(String title, String hint, {bool digits = false}) {
    final l10n = AppLocalizations.of(context);
    final text = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hint),
            TextField(
              controller: text,
              autofocus: true,
              keyboardType: digits ? TextInputType.number : null,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.recoverCode),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, text.text.trim()),
            child: Text(l10n.accountContinue),
          ),
        ],
      ),
    );
  }

  Future<void> _assign(String key) async {
    final l10n = AppLocalizations.of(context);
    final code = await _ask(l10n.accountAssignTitle, l10n.accountAssignHint);
    if (code == null || code.isEmpty) return;
    await _run((dio) async {
      await dio.post<List<dynamic>>(
        '/v1/collectors/$key/assign',
        data: {'code': code},
      );
      ref.invalidate(_assignmentsProvider(key));
    });
  }

  Future<void> _ownCode(String key) async {
    final l10n = AppLocalizations.of(context);
    await _run((dio) async {
      final r = await dio.post<Map<String, dynamic>>(
        '/v1/collectors/$key/recovery-code/own',
      );
      final code = r.data!['code'] as String;
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l10n.accountOwnCodeTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                code,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(l10n.accountOwnCodeHint),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(l10n.accountCopy),
              onPressed: () => Clipboard.setData(ClipboardData(text: code)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog),
              child: Text(l10n.accountDone),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _signOut(String key) async {
    final l10n = AppLocalizations.of(context);
    await _run((dio) async {
      final r = await dio.post<Map<String, dynamic>>(
        '/v1/collectors/$key/devices/sign-out',
        data: {'installation_ids': _selected.toList()},
      );
      final request = r.data!['request_id'] as String;
      if (!mounted) return;
      final code = await _ask(
        l10n.accountConfirmTitle,
        l10n.accountConfirmHint,
        digits: true,
      );
      if (code == null || code.isEmpty) return;
      await dio.post<Map<String, dynamic>>(
        '/v1/collectors/$key/devices/sign-out/$request/confirm',
        data: {'code': code},
      );
      _selected.clear();
      ref.invalidate(_devicesProvider(key));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final when = DateFormat('d MMM y, HH:mm');
    final me = ref.watch(activeCollectorProvider);
    if (me == null) return const Scaffold(body: PageLoading());
    final key = me.collectorKey;
    final assignments = ref.watch(_assignmentsProvider(key));
    final devices = ref.watch(_devicesProvider(key));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle(me.fullName))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.accountAreaTitle, style: text.titleMedium),
          Text(l10n.accountAreaHint),
          ...switch (assignments) {
            AsyncData(value: final list?) when list.isEmpty => [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.accountNotAssigned),
              ),
            ],
            AsyncData(value: final list?) => [
              for (final a in list)
                ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: Text(a.area),
                  subtitle: Text(
                    a.byCode ? l10n.accountByCode : l10n.accountByAdmin,
                  ),
                ),
            ],
            AsyncLoading() => [const LinearProgressIndicator()],
            _ => [
              ListTile(
                leading: const Icon(Icons.cloud_off),
                title: Text(l10n.accountOffline),
              ),
            ],
          },
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : () => _assign(key),
              icon: const Icon(Icons.qr_code_2),
              label: Text(l10n.accountAssignButton),
            ),
          ),
          const Divider(height: 32),
          Text(l10n.accountOwnCodeSection, style: text.titleMedium),
          Text(l10n.accountOwnCodeIntro),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : () => _ownCode(key),
              icon: const Icon(Icons.key_outlined),
              label: Text(l10n.accountOwnCodeButton),
            ),
          ),
          const Divider(height: 32),
          Text(l10n.accountDevicesTitle, style: text.titleMedium),
          Text(l10n.accountDevicesHint),
          ...switch (devices) {
            AsyncData(value: final list?) => [
              for (final d in list)
                CheckboxListTile(
                  value: _selected.contains(d.id),
                  onChanged: d.thisDevice || d.signedOut
                      ? null
                      : (on) => setState(
                          () => on == true
                              ? _selected.add(d.id)
                              : _selected.remove(d.id),
                        ),
                  secondary: Icon(
                    d.signedOut ? Icons.phonelink_erase : Icons.devices,
                  ),
                  title: Text(
                    [
                      d.label ?? d.platform ?? l10n.accountDevice,
                      ?d.shortCode,
                      if (d.thisDevice) l10n.accountThisDevice,
                    ].join(' · '),
                  ),
                  subtitle: Text(
                    [
                      l10n.accountVia(d.via),
                      d.signedOut
                          ? l10n.accountSignedOut
                          : l10n.accountLastSeen(
                              when.format(WcTime.local(d.lastSeen, context)),
                            ),
                    ].join(' · '),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: _busy || _selected.isEmpty
                      ? null
                      : () => _signOut(key),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.accountSignOutButton(_selected.length)),
                ),
              ),
            ],
            AsyncLoading() => [const LinearProgressIndicator()],
            _ => [
              ListTile(
                leading: const Icon(Icons.cloud_off),
                title: Text(l10n.accountOffline),
              ),
            ],
          },
        ],
      ),
    );
  }
}
