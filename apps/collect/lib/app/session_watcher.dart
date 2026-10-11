import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/activation/installation_service.dart';
import '../features/sync/collect_sync.dart';
import 'gate.dart';
import 'providers.dart';
import 'services.dart';

/// While Collect is open:
/// - locks after [lockAfterBackground] away (F-AUTH-2);
/// - asks the server whether the installation is still allowed (F-AUTH-4);
/// - syncs on start, on return, when the network comes back, shortly after
///   new records and every [syncEvery] (SPEC §8.6; the Android background
///   worker covers the time the app is closed).
/// Everything works offline: a failed attempt changes nothing on screen.
class SessionWatcher extends ConsumerStatefulWidget {
  const SessionWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionWatcher> createState() => _SessionWatcherState();
}

/// How often the open app syncs on its own.
const syncEvery = Duration(minutes: 15);

/// Wait after a new record before sending, so a whole visit goes together.
const syncAfterChanges = Duration(seconds: 20);

class _SessionWatcherState extends ConsumerState<SessionWatcher> {
  late final AppLifecycleListener _listener;
  DateTime? _awaySince;
  Timer? _periodic;
  Timer? _soon;
  StreamSubscription<bool>? _network;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onHide: _away, onShow: _back);
    _periodic = Timer.periodic(syncEvery, (_) => _sync());
    _network = ref.read(connectivityProvider).listen((online) {
      if (online) {
        unawaited(
          _quietly(ref.read(syncControllerProvider.notifier).connected),
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startup());
  }

  @override
  void dispose() {
    _listener.dispose();
    _periodic?.cancel();
    _soon?.cancel();
    unawaited(_network?.cancel());
    super.dispose();
  }

  Future<void> _startup() async {
    await _check();
    await _sync();
  }

  void _away() => _awaySince ??= DateTime.now();

  Future<void> _back() async {
    final since = _awaySince;
    _awaySince = null;
    if (since != null &&
        DateTime.now().difference(since) >= lockAfterBackground &&
        (await ref.read(appLockProvider).config()).enabled) {
      ref.read(appGateProvider.notifier).lock();
    }
    await _check();
    await _sync();
  }

  Future<void> _check() =>
      _quietly(() => ref.read(installationServiceProvider).checkStatus());

  Future<void> _sync() =>
      _quietly(() => ref.read(syncControllerProvider.notifier).run());

  Future<void> _quietly(Future<Object?> Function() action) async {
    if (!mounted) return;
    try {
      await action();
    } catch (e) {
      debugPrint('Background work failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // New records waiting: send them soon.
    ref.listen(syncSummaryProvider, (previous, next) {
      final before = previous?.value?.pending ?? 0;
      final now = next.value?.pending ?? 0;
      if (now > before) {
        _soon?.cancel();
        _soon = Timer(syncAfterChanges, () => unawaited(_sync()));
      }
    });
    return widget.child;
  }
}
