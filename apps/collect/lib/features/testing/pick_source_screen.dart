import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../sync/refresh_button.dart';
import '../sources/source_browser.dart';
import 'test_draft.dart';

/// "Test a source": tap it in the list, or pick the nearest (SPEC §3.1 step 4).
class PickSourceScreen extends ConsumerStatefulWidget {
  const PickSourceScreen({super.key});

  @override
  ConsumerState<PickSourceScreen> createState() => _PickSourceScreenState();
}

class _PickSourceScreenState extends ConsumerState<PickSourceScreen> {
  void _choose(String sourceId) {
    ref.read(testDraftProvider.notifier).start(sourceId);
    context.push('/test/setup');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickTitle),
        actions: const [SyncRefreshButton()],
      ),
      body: SourceBrowser(
        bottomPadding: 16,
        onOpen: (s) => _choose(s.source.id),
      ),
    );
  }
}
