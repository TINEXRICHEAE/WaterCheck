import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/dashboard_state.dart';
import 'admin_api.dart';

final _typedProvider = FutureProvider.autoDispose<List<TypedValue>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.watch(adminApiProvider).admin.typedValues();
});

/// Typed list values (ADR-022): what collectors typed under "Other" for a
/// source type or a collector type, with how often. Adding one puts it in
/// the shared list, before "Other", for every device after the next sync;
/// the records that hold it already match it.
class TypedValuesScreen extends ConsumerWidget {
  const TypedValuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final day = DateFormat('d MMM y');
    final typed = ref.watch(_typedProvider);
    return typed.when(
      loading: () => const PageLoading(),
      error: (e, _) =>
          ErrorView(error: e, onRetry: () => ref.invalidate(_typedProvider)),
      data: (values) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.typedTitle, style: text.headlineSmall),
          Text(l10n.typedHint),
          const SizedBox(height: 16),
          if (values.isEmpty) Text(l10n.typedNone),
          for (final v in values)
            Card(
              child: ListTile(
                leading: Icon(
                  v.list == TypedValueList.sourceTypes
                      ? Icons.water_drop_outlined
                      : Icons.badge_outlined,
                ),
                title: Text(v.value),
                subtitle: Text(
                  [
                    l10n.typedList(v.list.json!),
                    l10n.typedUses(v.uses),
                    if (v.firstSeen case final at?)
                      l10n.typedFirstSeen(
                        day.format(WcTime.local(at, context)),
                      ),
                  ].join(' · '),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => _add(context, ref, v),
                  child: Text(l10n.typedAdd),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, TypedValue v) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminApiProvider)
          .admin
          .addTypedValue(
            body: TypedValueIn(
              list: TypedValueInList.values.byName(v.list.name),
              value: v.value,
            ),
          );
      ref.invalidate(_typedProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.typedAdded(v.value))));
    } on Object {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.adminNeedsConnection)),
      );
    }
  }
}
