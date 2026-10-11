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
