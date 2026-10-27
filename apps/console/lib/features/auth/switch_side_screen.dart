import 'package:domain/domain.dart' show AppSide;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';
import '../research/research_mode.dart';

/// The full switch to the other side, for someone without an account
/// there yet (ADR-031): sign in with an account on that side, join it with
/// the details of the account in use, or make a new account there. The
/// sides run apart: nothing of one is shown on the other.
class SwitchSideScreen extends ConsumerWidget {
  const SwitchSideScreen({super.key, required this.side});

  final AppSide side;

  /// Leaves this account and opens [route] (sign-in or sign-up) on [side].
  Future<void> _leaveFor(
    WidgetRef ref,
    BuildContext context,
    String route,
  ) async {
    await ref.read(sessionProvider.notifier).signOut();
    await ref.read(consoleModeProvider.notifier).set(ConsoleMode.of(side));
    if (context.mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = sideName(UiKitLocalizations.of(context), side);
    final text = Theme.of(context).textTheme;
    Widget option(IconData icon, String title, String hint, VoidCallback go) =>
        Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(hint),
            trailing: const Icon(Icons.chevron_right),
            onTap: go,
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.switchTo(name), style: text.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.switchIntro(name)),
        const SizedBox(height: 16),
        option(
          Icons.login,
          l10n.switchSignIn(name),
          l10n.switchSignInHint(name),
          () => _leaveFor(ref, context, '/sign-in'),
        ),
        option(
          Icons.how_to_reg_outlined,
          l10n.switchJoin(name),
          l10n.switchJoinHint(name),
          () => context.go('/join/${side.wire}'),
        ),
        option(
          Icons.person_add_alt_outlined,
          l10n.switchNew(name),
          l10n.switchNewHint(name),
          () => _leaveFor(ref, context, '/sign-up'),
        ),
      ],
    );
  }
}
