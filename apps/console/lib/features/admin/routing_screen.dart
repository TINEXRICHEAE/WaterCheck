import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/console_sync.dart';
import '../../l10n/app_localizations.dart';
import 'admin_api.dart';

/// Which responsibilities each alert reaches besides the area chain
/// (F-ADM-4), and the list of responsibilities people can be given.
class RoutingScreen extends ConsumerStatefulWidget {
  const RoutingScreen({super.key});

  @override
  ConsumerState<RoutingScreen> createState() => _RoutingScreenState();
}

class _RoutingScreenState extends ConsumerState<RoutingScreen> {
  Set<(String, String)>? _rules;
  var _dirty = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminApiProvider)
          .admin
          .setRouting(
            body: RoutingIn(
              rules: [
                for (final (t, r) in _rules!)
                  RoutingRule(triggerRule: t, responsibilityCode: r),
              ],
            ),
          );
      setState(() => _dirty = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.routingSaved)));
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }

  Future<void> _addResponsibility() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NameDialog(),
    );
    if (name == null) return;
    final code = name
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    try {
      await ref
          .read(adminApiProvider)
          .admin
          .newResponsibility(
            body: Responsibility(
              code: RegExp('^[a-z]').hasMatch(code) ? code : 'r_$code',
              name: name,
            ),
          );
      ref.invalidate(adminRoutingProvider);
      // People can be given it once the reference data arrives.
      await ref.read(consoleSyncProvider.notifier).run(force: true);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.routingExists)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final routing = ref.watch(adminRoutingProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.routingTitle, style: text.headlineSmall),
        Text(l10n.routingHint),
        const SizedBox(height: 12),
        ...routing.when(
          loading: () => [const LinearProgressIndicator()],
          error: (_, _) => [Text(l10n.adminNeedsConnection)],
          data: (r) {
            final rules = _rules ??= {
              for (final x in r.rules) (x.triggerRule, x.responsibilityCode),
            };
            return [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(l10n.routingResponsibility)),
                    for (final t in r.triggers)
                      DataColumn(label: Text(l10n.routingTrigger(t))),
                  ],
                  rows: [
                    for (final resp in r.responsibilities)
                      DataRow(
                        cells: [
                          DataCell(Text(resp.name)),
                          for (final t in r.triggers)
                            DataCell(
                              Checkbox(
                                key: ValueKey('route-$t-${resp.code}'),
                                value: rules.contains((t, resp.code)),
                                onChanged: (on) => setState(() {
                                  on!
                                      ? rules.add((t, resp.code))
                                      : rules.remove((t, resp.code));
                                  _dirty = true;
                                }),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: _dirty ? _save : null,
                    child: Text(l10n.routingSave),
                  ),
                  OutlinedButton.icon(
                    onPressed: _addResponsibility,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.routingAdd),
                  ),
                ],
              ),
            ];
          },
        ),
      ],
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.routingAdd),
      content: TextField(
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.routingAddName),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _name.text.trim().length < 2
              ? null
              : () => Navigator.pop(context, _name.text.trim()),
          child: Text(l10n.routingAddCreate),
        ),
      ],
    );
  }
}
