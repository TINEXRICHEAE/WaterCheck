import 'package:api_client/api_client.dart';
import 'package:data/data.dart' show SeedBundle, SeedImporter;
import 'package:dio/dio.dart';
import 'package:domain/domain.dart' show AppSide;
import 'package:drift/drift.dart' as drift show Table, TableInfo;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/providers.dart';
import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../admin/area_picker.dart';
import 'identity.dart';
import '../research/research_mode.dart';

ProfileClient _profile(WidgetRef ref) =>
    WaterCheckApi(ref.read(consoleDioProvider)).profile;

final _areaRequestsProvider = FutureProvider.autoDispose<List<AreaRequestOut>>((
  ref,
) async {
  try {
    return await WaterCheckApi(ref.watch(consoleDioProvider)).profile
        .myAreaRequests();
  } on Object {
    return const [];
  }
});

/// My profile (ADR-025), apart from settings: my details (editable), my
/// email and phone (confirmed with a code), my areas (a change is a request
/// an IT admin decides) and my account: sign out, sign in as someone else,
/// remove this account from this device, close my account.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  var _busy = false;

  String _message(AppLocalizations l10n, Object e) {
    final code = e is DioException ? ApiFailure.from(e).code : null;
    return switch (code) {
      'invalid_email' => l10n.profileBadEmail,
      'invalid_phone' => l10n.profileBadPhone,
      'wrong_code' => l10n.profileWrongCode,
      'request_expired' => l10n.profileCodeExpired,
      'wrong_password' => l10n.profileWrongPassword,
      'last_it_admin' => l10n.profileLastAdmin,
      _ => l10n.adminNeedsConnection,
    };
  }

  Future<bool> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action();
      return true;
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(_message(l10n, e))));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<List<String>?> _form(
    String title,
    List<(String label, String value, TextInputType? type)> fields, {
    String? hint,
    bool obscure = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final controllers = [
      for (final f in fields) TextEditingController(text: f.$2),
    ];
    return showDialog<List<String>>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hint != null) Text(hint),
              for (final (i, f) in fields.indexed)
                TextField(
                  controller: controllers[i],
                  autofocus: i == 0,
                  obscureText: obscure,
                  keyboardType: f.$3,
                  decoration: InputDecoration(labelText: f.$1),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, [
              for (final c in controllers) c.text.trim(),
            ]),
            child: Text(l10n.profileSave),
          ),
        ],
      ),
    );
  }

  Future<void> _editDetails(MeResponse me) async {
    final l10n = AppLocalizations.of(context);
    final v = await _form(l10n.profileEditDetails, [
      (l10n.profileFullName, me.fullName, TextInputType.name),
      (l10n.profileOrganisation, me.organisation ?? '', null),
      (l10n.profilePosition, me.position ?? '', null),
    ]);
    if (v == null || v[0].isEmpty) return;
    await _run(() async {
      await _profile(ref).editProfile(
        body: ProfileIn(fullName: v[0], organisation: v[1], position: v[2]),
      );
      await ref.read(sessionProvider.notifier).reloadMe();
    });
  }

  /// A new email or phone, then its code (from the IT admin for now).
  Future<void> _changeContact(ContactInChannel channel, String? current) async {
    final l10n = AppLocalizations.of(context);
    final email = channel == ContactInChannel.email;
    final v = await _form(
      email ? l10n.profileChangeEmail : l10n.profileChangePhone,
      [
        (
          email ? l10n.profileEmail : l10n.profilePhone,
          current ?? '',
          email ? TextInputType.emailAddress : TextInputType.phone,
        ),
      ],
      hint: l10n.profileContactHint,
    );
    if (v == null || v[0].isEmpty) return;
    ContactPending? pending;
    final ok = await _run(() async {
      pending = await _profile(ref).changeContact(
        body: ContactIn(channel: channel, value: v[0]),
      );
      await ref.read(sessionProvider.notifier).reloadMe();
    });
    if (!ok || pending == null || !mounted) return;
    final code = await _form(l10n.profileConfirmTitle, [
      (l10n.profileCode, '', TextInputType.number),
    ], hint: l10n.profileConfirmHint);
    if (code == null || code[0].isEmpty) return;
    await _run(() async {
      await _profile(ref).confirmContact(
        requestId: pending!.id,
        body: ConfirmIn(code: code[0]),
      );
      await ref.read(sessionProvider.notifier).reloadMe();
    });
  }

  Future<void> _askAreas(MeResponse me) async {
    final l10n = AppLocalizations.of(context);
    final picked = await pickAreas(
      context,
      selected: [for (final a in me.areas) a.id],
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    final reason = await _form(l10n.profileAreasWhy, [
      (l10n.profileAreasReason, '', null),
    ], hint: l10n.profileAreasHint);
    if (reason == null || reason[0].length < 3) return;
    await _run(() async {
      await _profile(ref).requestAreas(
        body: AreaRequestIn(
          areaIds: [for (final a in picked) a.id],
          reason: reason[0],
        ),
      );
      ref.invalidate(_areaRequestsProvider);
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

  /// Signs out and erases what this device keeps for the account (the
  /// cached data, the saved session and PIN), then shows the sign-in page.
  Future<void> _removeHere() async {
    final l10n = AppLocalizations.of(context);
    if (!await _sure(
      l10n.profileRemoveTitle,
      l10n.profileRemoveBody,
      l10n.profileRemove,
    )) {
      return;
    }
    final db = ref.read(databaseProvider);
    await ref.read(sessionProvider.notifier).signOut();
    await db.customStatement('PRAGMA foreign_keys = OFF');
    await db.transaction(() async {
      for (final drift.TableInfo<drift.Table, dynamic> t in db.allTables) {
        await db.delete(t).go();
      }
    });
    await db.customStatement('PRAGMA foreign_keys = ON');
    if (!kIsWeb) {
      await SeedImporter(db).importBundle(await SeedBundle.fromAssets());
    }
  }

  Future<void> _close() async {
    final l10n = AppLocalizations.of(context);
    if (!await _sure(
      l10n.profileCloseTitle,
      l10n.profileCloseBody,
      l10n.profileCloseContinue,
    )) {
      return;
    }
    if (!mounted) return;
    final pw = await _form(
      l10n.profileCloseTitle,
      [(l10n.profilePassword, '', TextInputType.visiblePassword)],
      hint: l10n.profileClosePassword,
      obscure: true,
    );
    if (pw == null || pw[0].isEmpty) return;
    final ok = await _run(
      () => _profile(ref).closeAccount(body: CloseIn(password: pw[0])),
    );
    if (ok) await ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final session = ref.watch(sessionProvider);
    final me = session.me;
    if (me == null) return const SizedBox.shrink();
    // The side this page is shown on (ADR-031); areas are water's.
    final side = ref.watch(activeModeProvider).side;
    final water = side == AppSide.water;
    final names = UiKitLocalizations.of(context);
    final when = DateFormat('d MMM y');
    final requests = ref.watch(_areaRequestsProvider).value ?? const [];
    final open = requests.where((r) => r.decidedAt == null).firstOrNull;
    final last = requests.where((r) => r.decidedAt != null).firstOrNull;

    Widget contact(
      ContactInChannel channel,
      IconData icon,
      String label,
      String? value,
      bool confirmed,
    ) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        value == null
            ? l10n.profileNone
            : '$value · ${confirmed ? l10n.profileConfirmed : l10n.profileNotConfirmed}',
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (value != null && !confirmed)
            TextButton(
              onPressed: _busy ? null : () => _changeContact(channel, value),
              child: Text(l10n.profileConfirm),
            ),
          TextButton(
            onPressed: _busy ? null : () => _changeContact(channel, value),
            child: Text(value == null ? l10n.profileAdd : l10n.profileChange),
          ),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.profileTitle, style: text.headlineSmall),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.account_circle_outlined, size: 40),
          title: Text(me.fullName, style: text.titleLarge),
          subtitle: Text(
            [
              me.username,
              me.role == 'it_admin'
                  ? l10n.roleAdmin
                  : l10n.roleOnSide(sideName(names, side)),
            ].join(' · '),
          ),
        ),
        const Divider(height: 24),
        const MyIdentity(),
        const Divider(height: 24),
        Row(
          children: [
            Expanded(child: Text(l10n.profileDetails, style: text.titleMedium)),
            TextButton.icon(
              onPressed: _busy ? null : () => _editDetails(me),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.profileEdit),
            ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.business_outlined),
          title: Text(l10n.profileOrganisation),
          subtitle: Text(me.organisation ?? l10n.profileNone),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.work_outline),
          title: Text(l10n.profilePosition),
          subtitle: Text(me.position ?? l10n.profileNone),
        ),
        contact(
          ContactInChannel.email,
          Icons.email_outlined,
          l10n.profileEmail,
          me.email,
          me.emailConfirmed,
        ),
        contact(
          ContactInChannel.phone,
          Icons.phone_outlined,
          l10n.profilePhone,
          me.phone,
          me.phoneConfirmed,
        ),
        if (water) ...[
          const Divider(height: 24),
          Text(l10n.profileAreas, style: text.titleMedium),
          Text(
            me.areas.isEmpty
                ? l10n.profileAllAreas
                : me.areas.map((a) => a.name).join(', '),
          ),
          Text(
            me.responsibilities.isEmpty
                ? l10n.profileAllResponsibilities
                : me.responsibilities.map(l10n.responsibility).join(', '),
            style: text.bodySmall,
          ),
          if (open != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.hourglass_top),
                title: Text(l10n.profileAreasPending(open.areas.join(', '))),
                subtitle: Text(
                  l10n.profileAreasPendingSince(
                    when.format(WcTime.local(open.createdAt, context)),
                  ),
                ),
              ),
            )
          else if (last != null && last.approved == false)
            Text(l10n.profileAreasDeclined(last.areas.join(', '))),
          if (me.role != 'it_admin')
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _askAreas(me),
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: Text(l10n.profileAskAreas),
              ),
            ),
        ],
        const Divider(height: 24),
        // Sides of FieldQuire (ADR-031): separate, linked accounts.
        Text(l10n.profileSides, style: text.titleMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            water ? Icons.water_drop_outlined : Icons.assignment_outlined,
          ),
          title: Text(l10n.profileThisSide(sideName(names, side))),
          subtitle: Text(
            session.isAdmin ? l10n.profileAdminAllSides : l10n.profileSideHint,
          ),
        ),
        if (!session.isAdmin)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.swap_horiz),
            title: Text(sideName(names, side.other)),
            subtitle: Text(
              session.otherSides.contains(side.other)
                  ? l10n.profileLinked
                  : l10n.profileNotJoined,
            ),
            trailing: session.otherSides.contains(side.other)
                ? TextButton(
                    onPressed: () =>
                        switchToSide(context, ref, ConsoleMode.of(side.other)),
                    child: Text(l10n.switchGo),
                  )
                : TextButton(
                    onPressed: () => context.go('/join/${side.other.wire}'),
                    child: Text(l10n.joinMenu(sideName(names, side.other))),
                  ),
          ),
        const Divider(height: 24),
        Text(l10n.profileAccount, style: text.titleMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.settingsTitle),
          subtitle: Text(l10n.profileSettingsHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              context.go(water ? '/dashboard/settings' : '/research/settings'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: Text(l10n.accountSignOut),
          onTap: () => ref.read(sessionProvider.notifier).signOut(),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.switch_account_outlined),
          title: Text(l10n.profileSwitch),
          subtitle: Text(l10n.profileSwitchHint),
          onTap: () => ref.read(sessionProvider.notifier).signOut(),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.phonelink_erase_outlined),
          title: Text(l10n.profileRemove),
          subtitle: Text(l10n.profileRemoveHint),
          onTap: _busy ? null : _removeHere,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.no_accounts_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            l10n.profileClose,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          subtitle: Text(l10n.profileCloseHint),
          onTap: _busy ? null : _close,
        ),
        const Divider(height: 24),
        LegalTiles(side: side),
      ],
    );
  }
}
