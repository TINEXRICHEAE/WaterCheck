import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

/// The signed-in user's details and how alerts reach them (F-ALR-2).
/// In-app notifications are always on.
extension on String {
  String ifEmpty(String other) => isEmpty ? other : this;
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  var _saving = false;
  String? _error;

  Future<void> _set({bool? email, bool? push, bool? sms}) async {
    final me = ref.read(sessionProvider).me!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionProvider.notifier)
          .setPreferences(
            email: email ?? me.notifyEmail,
            push: push ?? me.notifyPush,
            sms: sms ?? me.notifySms,
          );
    } on ApiFailure catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(
          () => _error = e.isOffline ? l10n.profileOffline : l10n.profileFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _appearance(ThemeChoice theme, TimeZoneChoice zone) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(sessionProvider.notifier).setAppearance(theme, zone);
    } on ApiFailure {
      messenger.showSnackBar(SnackBar(content: Text(l10n.appearanceLocalOnly)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final me = ref.watch(sessionProvider).me;
    if (me == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.profileTitle, style: text.headlineSmall),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.account_circle_outlined),
          title: Text(me.fullName),
          subtitle: Text(
            [me.username, ?me.position, ?me.organisation].join(' · '),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined),
          title: Text(l10n.profileAreas),
          subtitle: Text(me.areas.map((a) => a.name).join(', ')),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.assignment_ind_outlined),
          title: Text(l10n.profileResponsibilities),
          subtitle: Text(
            me.responsibilities.isEmpty
                ? l10n.profileAllResponsibilities
                : me.responsibilities.map(l10n.responsibility).join(', '),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.contact_phone_outlined),
          title: Text(l10n.profileContacts),
          subtitle: Text(
            [?me.email, ?me.phone].join(' · ').ifEmpty(l10n.profileNoContacts),
          ),
        ),
        const Divider(height: 32),
        Text(l10n.appearanceTitle, style: text.titleMedium),
        Text(l10n.appearanceHint),
        AppearanceSettings(
          theme: ThemeChoice.parse(me.theme),
          zone: TimeZoneChoice.parse(me.timeZone),
          onTheme: (t) => _appearance(t, TimeZoneChoice.parse(me.timeZone)),
          onZone: (z) => _appearance(ThemeChoice.parse(me.theme), z),
        ),
        const Divider(height: 32),
        Text(l10n.notifyTitle, style: text.titleMedium),
        Text(l10n.notifyHint),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: true,
          onChanged: null,
          title: Text(l10n.notifyInApp),
          subtitle: Text(l10n.notifyInAppHint),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: me.notifyEmail,
          onChanged: _saving ? null : (v) => _set(email: v),
          title: Text(l10n.notifyEmail),
          subtitle: Text(me.email ?? l10n.notifyNoEmail),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: me.notifyPush,
          onChanged: _saving ? null : (v) => _set(push: v),
          title: Text(l10n.notifyPush),
          subtitle: Text(l10n.notifyPushHint),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: me.notifySms,
          onChanged: _saving ? null : (v) => _set(sms: v),
          title: Text(l10n.notifySms),
          subtitle: Text(me.phone ?? l10n.notifyNoPhone),
        ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
