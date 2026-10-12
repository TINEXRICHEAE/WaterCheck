import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.people_alt_outlined),
          title: Text(l10n.adminPeople),
          subtitle: Text(l10n.adminPeopleHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/people'),
        ),
        ListTile(
          leading: const Icon(Icons.phone_android),
          title: Text(l10n.adminPhones),
          subtitle: Text(l10n.adminPhonesHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/phones'),
        ),
        ListTile(
          leading: const Icon(Icons.account_tree_outlined),
          title: Text(l10n.adminChain),
          subtitle: Text(l10n.adminChainHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/chain'),
        ),
        ListTile(
          leading: const Icon(Icons.monitor_heart_outlined),
          title: Text(l10n.adminSystem),
          subtitle: Text(l10n.adminSystemHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/system'),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(l10n.adminSecurity),
          subtitle: Text(l10n.adminSecurityHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/security'),
        ),
        ListTile(
          leading: const Icon(Icons.alt_route),
          title: Text(l10n.adminRouting),
          subtitle: Text(l10n.adminRoutingHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/routing'),
        ),
        ListTile(
          leading: const Icon(Icons.add_location_alt_outlined),
          title: Text(l10n.adminPlaces),
          subtitle: Text(l10n.adminPlacesHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/places'),
        ),
        ListTile(
          leading: const Icon(Icons.science_outlined),
          title: Text(l10n.adminParams),
          subtitle: Text(l10n.adminParamsHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/parameters'),
        ),
        ListTile(
          leading: const Icon(Icons.assignment_outlined),
          title: Text(l10n.adminCards),
          subtitle: Text(l10n.adminCardsHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/cards'),
        ),
        ListTile(
          leading: const Icon(Icons.dataset_outlined),
          title: Text(l10n.adminReferenceData),
          subtitle: Text(l10n.adminReferenceDataHint),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/admin/reference-data'),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.adminMoreHint),
        ),
      ],
    );
  }
}
