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
