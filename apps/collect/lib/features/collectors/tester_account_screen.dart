import 'package:api_client/api_client.dart' show ApiFailure;
import 'package:data/data.dart' show ResearchFormItem;
import 'package:dio/dio.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../activation/installation_service.dart';
import '../research/collector_card.dart';
import '../research/research.dart';
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

/// Contacts confirmed on the server for the tester (ADR-025).
final _confirmedProvider = FutureProvider.autoDispose
    .family<({String? phone, String? email})?, String>((ref, key) async {
      final dio = ref.watch(collectApiDioProvider);
      if (dio == null) return null;
      try {
        final r = await dio.get<Map<String, dynamic>>(
          '/v1/collectors/$key/contacts/status',
        );
        return (
          phone: r.data!['phone'] as String?,
          email: r.data!['email'] as String?,
        );
      } on Object {
        return null;
      }
    });

/// My profile (ADR-024/025), apart from Settings: my details (editable),
/// my email and phone (confirmed with a code), the areas I am officially
/// assigned to (an assignment code from an IT admin), a sign-in code for
/// another device, the devices that use my profile (some can be signed
/// out), and switching person, signing out of this device or deleting my
/// profile. What reaches the server needs the internet.
class TesterAccountScreen extends ConsumerStatefulWidget {
  const TesterAccountScreen({super.key});

  @override
  ConsumerState<TesterAccountScreen> createState() =>
      _TesterAccountScreenState();
}

class _TesterAccountScreenState extends ConsumerState<TesterAccountScreen> {
  final _selected = <String>{};
  var _busy = false;

  bool get _research => ref.read(appModeProvider) == AppMode.research;

  String _message(AppLocalizations l10n, Object e) {
    final code = e is DioException ? ApiFailure.from(e).code : null;
    return switch (code) {
      'invalid_code' => l10n.accountCodeInvalid,
      'expired_code' => l10n.accountCodeExpired,
      'code_used_up' => l10n.accountCodeUsedUp,
      'sync_first' => l10n.accountSyncFirst,
      'wrong_code' => l10n.accountConfirmWrong,
      'request_expired' => l10n.accountConfirmExpired,
      'invalid_email' => l10n.emailInvalid,
      'invalid_phone' => l10n.phoneInvalid,
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
            CopyButton(text: code, label: l10n.accountCopy),
            FilledButton(
              onPressed: () => Navigator.pop(dialog),
              child: Text(l10n.accountDone),
            ),
          ],
        ),
      );
    });
  }

  /// Sends a code for the email or phone on the profile, then asks for it.
  Future<void> _confirmContact(String key, String channel, String value) async {
    final l10n = AppLocalizations.of(context);
    await _run((dio) async {
      final r = await dio.post<Map<String, dynamic>>(
        '/v1/collectors/$key/contacts',
        data: {'channel': channel, 'value': value},
      );
      if (!mounted) return;
      final code = await _ask(
        l10n.accountConfirmTitle,
        l10n.profileContactCodeHint,
        digits: true,
      );
      if (code == null || code.isEmpty) return;
      await dio.post<void>(
        '/v1/collectors/$key/contacts/${r.data!['id']}/confirm',
        data: {'code': code},
      );
      ref.invalidate(_confirmedProvider(key));
    });
  }

  Future<bool> _sure(String title, String body, String confirm) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(confirm),
            ),
          ],
        ),
      ) ??
      false;

  /// Leaves this device: everything of theirs is sent first; a sign-in
  /// code brings them back.
  Future<void> _signOutHere(String key) async {
    final l10n = AppLocalizations.of(context);
    if (!await _sure(
      l10n.profileSignOutTitle,
      l10n.profileSignOutBody,
      l10n.profileSignOut,
    )) {
      return;
    }
    await _leave(key, '/v1/collectors/$key/sign-out-here');
  }

  Future<void> _delete(String key, String name) async {
    final l10n = AppLocalizations.of(context);
    if (!await _sure(
      l10n.profileDeleteTitle,
      _research
          ? l10n.profileDeleteBodyResearch(name)
          : l10n.profileDeleteBody(name),
      l10n.profileDelete,
    )) {
      return;
    }
    await _leave(key, '/v1/collectors/$key/close');
  }

  Future<void> _leave(String key, String path) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    // Nothing of theirs may be left unsent.
    await ref.read(syncControllerProvider.notifier).run(force: true);
    if ((await ref.read(outboxRepositoryProvider).unsynced()).isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSendFirst)));
      return;
    }
    var done = false;
    await _run((dio) async {
      await dio.post<void>(path);
      done = true;
    });
    if (!done) return;
    await ref.read(collectorProfileRepositoryProvider).deactivate(key);
    // Their trips stay on no device once they leave it (ADR-029).
    await ref.read(tripRepositoryProvider).deleteFor(key);
    await ref.read(appGateProvider.notifier).clearCollector();
    router.go('/who');
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
    final confirmed = ref.watch(_confirmedProvider(key)).value;
    final devices = ref.watch(_devicesProvider(key));
    // Each side has its own profile page (ADR-031): water testing shows
    // official areas, research the forms this person may fill.
    final water = me.side == AppSide.water;
    final forms = water
        ? const <ResearchFormItem>[]
        : ref.watch(researchFormsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(water ? l10n.profileTitleWater : l10n.profileTitleResearch),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_circle_outlined, size: 40),
            title: Text(me.fullName, style: text.titleLarge),
            subtitle: Text(
              [
                me.village,
                if (me.subcounty.isNotEmpty) me.subcounty,
                me.district,
              ].join(', '),
            ),
            trailing: TextButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.profileEditDetails),
              onPressed: () => context.push('/who/$key/edit'),
            ),
          ),
          // Username and privacy (ADR-032); on research, the collector code.
          const Divider(height: 24),
          CollectorCardSection(
            collectorKey: key,
            research: !water,
            fullName: me.fullName,
          ),
          const Divider(height: 24),
          for (final (channel, icon, label, value) in [
            ('phone', Icons.phone_outlined, l10n.profilePhoneLabel, me.phone),
            (
              'email',
              Icons.email_outlined,
              l10n.profileEmailLabel,
              me.email ?? '',
            ),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon),
              title: Text(label),
              subtitle: Text(
                value.isEmpty
                    ? l10n.profileNotGiven
                    : '$value · ${(channel == 'phone' ? confirmed?.phone : confirmed?.email) == value ? l10n.profileConfirmedLabel : l10n.profileNotConfirmedLabel}',
              ),
              trailing:
                  value.isEmpty ||
                      (channel == 'phone'
                              ? confirmed?.phone
                              : confirmed?.email) ==
                          value
                  ? null
                  : TextButton(
                      onPressed: _busy
                          ? null
                          : () => _confirmContact(key, channel, value),
                      child: Text(l10n.profileConfirmButton),
                    ),
            ),
          if (water) ...[
            const Divider(height: 32),
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
          ] else ...[
            const Divider(height: 32),
            Text(l10n.researchForms, style: text.titleMedium),
            Text(l10n.accountFormsHint),
            if (forms.isEmpty)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.researchNoFormsShort),
              ),
            for (final f in forms)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(f.code)),
                title: Text(f.title),
                subtitle: Text(f.projectTitle),
              ),
          ],
          const Divider(height: 32),
          Text(l10n.accountOwnCodeSection, style: text.titleMedium),
          Text(
            water ? l10n.accountOwnCodeIntro : l10n.accountOwnCodeIntroResearch,
          ),
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
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.route),
            title: Text(l10n.tripsTitle),
            subtitle: Text(l10n.tripsTileHint),
            onTap: () => context.push(
              sidePath(ref.read(appModeProvider), '/profile/trips'),
            ),
          ),
          const Divider(height: 32),
          Text(l10n.profileAccountTitle, style: text.titleMedium),
          // The same person on the other side (ADR-031).
          const SideSwitchTile(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.switch_account_outlined),
            title: Text(l10n.profileSwitch),
            subtitle: Text(
              water ? l10n.profileSwitchHint : l10n.profileSwitchHintResearch,
            ),
            onTap: () => context.go('/who'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout),
            title: Text(l10n.profileSignOut),
            subtitle: Text(l10n.profileSignOutHint),
            onTap: _busy ? null : () => _signOutHere(key),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.person_remove_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.profileDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(
              water ? l10n.profileDeleteHint : l10n.profileDeleteHintResearch,
            ),
            onTap: _busy ? null : () => _delete(key, me.fullName),
          ),
          const Divider(height: 32),
          LegalTiles(side: me.side),
        ],
      ),
    );
  }
}
