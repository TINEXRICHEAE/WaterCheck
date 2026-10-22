import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/session.dart';
import '../../l10n/app_localizations.dart';

/// Windows/Android, after the first sign-in: a PIN protects the data kept on
/// this device and unlocks it offline (F-AUTH-2). Optional for stakeholders,
/// required for IT admins (2026-10-22).
class ChoosePinScreen extends ConsumerWidget {
  const ChoosePinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final admin = ref.watch(sessionProvider).isAdmin;
    return PinSetupScreen(
      title: l10n.pinChooseTitle,
      onDone: (pin) => ref.read(sessionProvider.notifier).choosePin(pin),
      actions: [
        if (!admin)
          TextButton(
            onPressed: () => ref.read(sessionProvider.notifier).skipPin(),
            child: Text(l10n.pinSkip),
          ),
        TextButton(
          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          child: Text(l10n.accountSignOut),
        ),
      ],
    );
  }
}

class UnlockScreen extends ConsumerWidget {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final me = ref.watch(sessionProvider).me;
    return PinUnlockScreen(
      message: me == null ? null : l10n.unlockFor(me.fullName),
      onSubmit: (pin) async {
        final r = await ref.read(sessionProvider.notifier).unlock(pin);
        return switch (r) {
          Unlocked() => null,
          WrongPin(:final triesBeforeWait) => ui.pinWrong(triesBeforeWait),
          MustWait(:final remaining) => ui.pinWait(
            (remaining.inMilliseconds / 1000).ceil(),
          ),
        };
      },
      actions: [
        TextButton(
          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          child: Text(l10n.unlockForgot),
        ),
      ],
    );
  }
}
