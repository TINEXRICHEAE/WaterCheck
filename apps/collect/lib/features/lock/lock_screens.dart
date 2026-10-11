import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/gate.dart';
import '../../app/services.dart';
import '../../l10n/app_localizations.dart';

/// Turns an unlock attempt into a message, or null when unlocked.
String? unlockMessage(UiKitLocalizations l10n, UnlockResult r) => switch (r) {
  Unlocked() => null,
  WrongPin(:final triesBeforeWait) => l10n.pinWrong(triesBeforeWait),
  MustWait(:final remaining) => l10n.pinWait(
    (remaining.inMilliseconds / 1000).ceil(),
  ),
};

/// Shown on start and after a while in the background (F-AUTH-2).
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  var _biometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setUp());
  }

  Future<void> _setUp() async {
    final config = await ref.read(appLockProvider).config();
    final available =
        config.biometric && await ref.read(biometricsProvider).available();
    if (!mounted) return;
    setState(() => _biometric = available);
    if (available) await _useBiometric();
  }

  Future<void> _useBiometric() async {
    final reason = AppLocalizations.of(context).lockBiometricReason;
    if (await ref.read(biometricsProvider).authenticate(reason)) {
      await ref.read(appLockProvider).unlockedByBiometric();
      ref.read(appGateProvider.notifier).unlock();
    }
  }

  Future<void> _forgot() async {
    final l10n = AppLocalizations.of(context);
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lockForgotTitle),
        content: Text(l10n.lockForgotBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.lockForgotReset),
          ),
        ],
      ),
    );
    if (reset == true && mounted) context.go('/reset');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    return PinUnlockScreen(
      message: l10n.lockMessage,
      onSubmit: (pin) async {
        final result = await ref.read(appLockProvider).unlock(pin);
        if (result is Unlocked) ref.read(appGateProvider.notifier).unlock();
        return unlockMessage(ui, result);
      },
      onBiometric: _biometric ? _useBiometric : null,
      actions: [TextButton(onPressed: _forgot, child: Text(l10n.lockForgot))],
    );
  }
}

/// Offers a fingerprint unlock after a PIN is set, if the phone has one.
Future<void> offerBiometric(BuildContext context, WidgetRef ref) async {
  if (!await ref.read(biometricsProvider).available() || !context.mounted) {
    return;
  }
  final l10n = AppLocalizations.of(context);
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.lockBiometricOfferTitle),
      content: Text(l10n.lockBiometricOfferBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.lockBiometricNo),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.lockBiometricYes),
        ),
      ],
    ),
  );
  await ref.read(appLockProvider).setBiometric(yes ?? false);
}

/// After activation: the lock is on by default, so choose a PIN; it can be
/// turned off here or later in Settings.
class LockSetupScreen extends ConsumerWidget {
  const LockSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PinSetupScreen(
      title: l10n.lockSetupTitle,
      onDone: (pin) async {
        await ref.read(appLockProvider).setPin(pin);
        if (context.mounted) await offerBiometric(context, ref);
        await ref.read(appGateProvider.notifier).lockDecided(declined: false);
      },
      actions: [
        TextButton(
          onPressed: () async {
            final off = await confirmLockOff(context);
            if (off) {
              await ref
                  .read(appGateProvider.notifier)
                  .lockDecided(declined: true);
            }
          },
          child: Text(l10n.lockTurnOff),
        ),
      ],
    );
  }
}

Future<bool> confirmLockOff(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.lockOffTitle),
          content: Text(l10n.lockOffBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.lockTurnOff),
            ),
          ],
        ),
      ) ??
      false;
}

/// Settings: set or change the PIN (the current one is asked first), or
/// turn the lock off ([turnOff]).
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key, this.turnOff = false});

  final bool turnOff;

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  bool? _verified;

  @override
  void initState() {
    super.initState();
    ref.read(appLockProvider).config().then((c) {
      if (mounted) setState(() => _verified = !c.enabled);
    });
  }

  Future<void> _finish() async {
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ui = UiKitLocalizations.of(context);
    final verified = _verified;
    if (verified == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!verified) {
      return PinUnlockScreen(
        title: l10n.lockCurrentPin,
        onSubmit: (pin) async {
          final lock = ref.read(appLockProvider);
          final result = await lock.unlock(pin);
          if (result is! Unlocked) return unlockMessage(ui, result);
          if (widget.turnOff) {
            await lock.disable();
            await ref
                .read(appGateProvider.notifier)
                .lockDecided(declined: true);
            await _finish();
          } else {
            setState(() => _verified = true);
          }
          return null;
        },
        actions: [TextButton(onPressed: _finish, child: Text(l10n.cancel))],
      );
    }
    return PinSetupScreen(
      onDone: (pin) async {
        await ref.read(appLockProvider).setPin(pin);
        if (mounted) await offerBiometric(this.context, ref);
        await ref.read(appGateProvider.notifier).lockDecided(declined: false);
        await _finish();
      },
      actions: [TextButton(onPressed: _finish, child: Text(l10n.cancel))],
    );
  }
}
