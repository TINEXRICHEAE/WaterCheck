import 'package:api_client/api_client.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'admin_api.dart';
import 'area_picker.dart';

/// People (F-ADM-1): every Console user, at any level from village to
/// national. Online only.
class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  var _query = '';
  var _raw = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final users = ref.watch(adminUsersProvider);
    final when = DateFormat('d MMM y, HH:mm');
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.usersNew),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(
            l10n.usersTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          SearchField(
            value: _raw,
            label: l10n.usersSearch,
            onChanged: (v) => setState(() {
              _raw = v;
              _query = v.trim().toLowerCase();
            }),
          ),
          const SizedBox(height: 8),
          ...users.when(
            loading: () => [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [
              ErrorView(
                error: e,
                compact: true,
                onRetry: () => ref.invalidate(adminUsersProvider),
              ),
            ],
            data: (list) => [
              for (final u in list)
                if (_query.isEmpty ||
                    u.fullName.toLowerCase().contains(_query) ||
                    u.username.toLowerCase().contains(_query) ||
                    u.areas.any((a) => a.name.toLowerCase().contains(_query)))
                  Card(
                    child: ListTile(
                      leading: Icon(
                        u.role == 'it_admin'
                            ? Icons.admin_panel_settings_outlined
                            : Icons.person_outline,
                      ),
                      title: Text(u.fullName),
                      subtitle: Text(
                        [
                          u.username,
                          if (u.areas.isNotEmpty)
                            u.areas
                                .map(
                                  (a) =>
                                      '${a.name} (${l10n.areaLevel(a.level)})',
                                )
                                .join(', '),
                          u.lastSignInAt == null
                              ? l10n.usersNeverSignedIn
                              : l10n.usersLastSignIn(
                                  when.format(
                                    WcTime.local(u.lastSignInAt!, context),
                                  ),
                                ),
                        ].join('\n'),
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          if (!u.isActive)
                            Chip(label: Text(l10n.usersDisabled)),
                          if (u.locked) Chip(label: Text(l10n.usersLocked)),
                          if (u.mustChangePassword && u.isActive)
                            Chip(label: Text(l10n.usersFirstSignIn)),
                        ],
                      ),
                      onTap: () => _edit(u),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _edit(UserOut? user) async {
    final result = await showDialog<_Saved>(
      context: context,
      builder: (_) => _UserDialog(user: user),
    );
    if (result == null || !mounted) return;
    ref.invalidate(adminUsersProvider);
    if (result.password case final p?) {
      await showCredentials(context, result.username, p);
    }
  }
}

typedef _Saved = ({String username, String? password});

/// The temporary password, shown once, to pass on in person, by SMS or by
/// email; it must be changed at first sign-in (F-AUTH-6).
Future<void> showCredentials(
  BuildContext context,
  String username,
  String password,
) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.credentialsTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.credentialsHint),
          const SizedBox(height: 12),
          SelectableText(l10n.credentialsUsername(username)),
          SelectableText(
            password,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontFamily: 'monospace', letterSpacing: 1.5),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () =>
              Clipboard.setData(ClipboardData(text: '$username\n$password')),
          icon: const Icon(Icons.copy),
          label: Text(l10n.credentialsCopy),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.credentialsDone),
        ),
      ],
    ),
  );
}

class _UserDialog extends ConsumerStatefulWidget {
  const _UserDialog({this.user});

  final UserOut? user;

  @override
  ConsumerState<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends ConsumerState<_UserDialog> {
  late final u = widget.user;
  late final _name = TextEditingController(text: u?.fullName);
  late final _username = TextEditingController(text: u?.username);
  late final _org = TextEditingController(text: u?.organisation);
  late final _position = TextEditingController(text: u?.position);
  late final _phone = TextEditingController(text: u?.phone);
  late final _email = TextEditingController(text: u?.email);
  late var _role = u?.role ?? 'stakeholder';
  late var _active = u?.isActive ?? true;
  late List<({String id, String name, String level})> _areas = [
    for (final a in u?.areas ?? const <AreaOut>[])
      (id: a.id, name: a.name, level: a.level),
  ];
  late final Set<String> _resp = {...?u?.responsibilities};
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _username, _org, _position, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _opt(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final api = ref.read(adminApiProvider).admin;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (u == null) {
        final made = await api.newUser(
          body: NewUserIn(
            username: _username.text.trim(),
            fullName: _name.text.trim(),
            role: _role == 'it_admin'
                ? NewUserInRole.itAdmin
                : NewUserInRole.stakeholder,
            organisation: _opt(_org),
            position: _opt(_position),
            phone: _opt(_phone),
            email: _opt(_email),
            areaIds: [for (final a in _areas) a.id],
            responsibilities: _resp.toList(),
          ),
        );
        if (mounted) {
          Navigator.pop(context, (
            username: made.user.username,
            password: made.temporaryPassword,
          ));
        }
      } else {
        await api.changeUser(
          userId: u!.id,
          body: UserChangesIn(
            fullName: _name.text.trim(),
            organisation: _opt(_org),
            position: _opt(_position),
            phone: _opt(_phone),
            email: _opt(_email),
            role: _role == 'it_admin'
                ? UserChangesInRole.itAdmin
                : UserChangesInRole.stakeholder,
            isActive: _active,
            areaIds: [for (final a in _areas) a.id],
            responsibilities: _resp.toList(),
          ),
        );
        if (mounted) {
          Navigator.pop(context, (username: u!.username, password: null));
        }
      }
    } on Object catch (e) {
      final failure = ApiFailure.from(e);
      setState(() {
        _saving = false;
        _error = switch (failure.code) {
          'username_taken' => l10n.usersTaken,
          'cannot_lock_yourself_out' => l10n.usersSelfLockout,
          'offline' => l10n.adminNeedsConnection,
          final c => l10n.usersFailed(c),
        };
      });
    }
  }

  Future<void> _reset() async {
    final made = await ref
        .read(adminApiProvider)
        .admin
        .resetPassword(userId: u!.id);
    if (mounted) {
      Navigator.pop(context, (
        username: made.user.username,
        password: made.temporaryPassword,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final responsibilities =
        ref.watch(responsibilitiesProvider).value ?? const [];
    final valid =
        _name.text.trim().isNotEmpty && _username.text.trim().length >= 3;
    Widget field(
      TextEditingController c,
      String label, {
      bool enabled = true,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
    return AlertDialog(
      title: Text(u == null ? l10n.usersNew : u!.fullName),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field(_name, l10n.usersFullName),
              field(_username, l10n.usersUsername, enabled: u == null),
              field(_org, l10n.usersOrganisation),
              field(_position, l10n.usersPosition),
              field(_phone, l10n.usersPhone),
              field(_email, l10n.usersEmail),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'stakeholder',
                    label: Text(l10n.roleStakeholder),
                  ),
                  ButtonSegment(value: 'it_admin', label: Text(l10n.roleAdmin)),
                ],
                selected: {_role},
                onSelectionChanged: (v) => setState(() => _role = v.single),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.usersAreas,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in _areas)
                    InputChip(
                      label: Text('${a.name} (${l10n.areaLevel(a.level)})'),
                      onDeleted: () => setState(
                        () => _areas = [
                          for (final x in _areas)
                            if (x.id != a.id) x,
                        ],
                      ),
                    ),
                  ActionChip(
                    avatar: const Icon(
                      Icons.add_location_alt_outlined,
                      size: 18,
                    ),
                    label: Text(l10n.usersAddArea),
                    onPressed: () async {
                      final picked = await pickAreas(
                        context,
                        selected: [for (final a in _areas) a.id],
                      );
                      if (picked != null) {
                        setState(
                          () => _areas = [
                            for (final AdminUnit p in picked)
                              (id: p.id, name: p.name, level: p.level),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
              Text(
                l10n.usersAreasHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.usersResponsibilities,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final r in responsibilities)
                    FilterChip(
                      label: Text(r.name),
                      selected: _resp.contains(r.code),
                      onSelected: (v) => setState(
                        () => v ? _resp.add(r.code) : _resp.remove(r.code),
                      ),
                    ),
                ],
              ),
              Text(
                l10n.usersResponsibilitiesHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (u != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  title: Text(l10n.usersActive),
                  subtitle: Text(l10n.usersActiveHint),
                  onChanged: (v) => setState(() => _active = v),
                ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (u != null)
          TextButton.icon(
            onPressed: _saving ? null : _reset,
            icon: const Icon(Icons.lock_reset),
            label: Text(l10n.usersResetPassword),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saving || !valid ? null : _save,
          child: BusyLabel(
            busy: _saving,
            child: Text(u == null ? l10n.usersCreate : l10n.alertSave),
          ),
        ),
      ],
    );
  }
}
