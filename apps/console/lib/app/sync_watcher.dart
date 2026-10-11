import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'console_sync.dart';
import 'session.dart';

/// Console syncs after sign-in or unlock, on return to the app and every
/// [every] while open (SPEC §8.6: no background sync on the web).
class SyncWatcher extends ConsumerStatefulWidget {
  const SyncWatcher({
    super.key,
    required this.child,
    this.every = const Duration(minutes: 15),
  });

  final Widget child;
  final Duration every;

  @override
  ConsumerState<SyncWatcher> createState() => _SyncWatcherState();
}

class _SyncWatcherState extends ConsumerState<SyncWatcher> {
  late final AppLifecycleListener _listener;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: _sync);
    _timer = Timer.periodic(widget.every, (_) => _sync());
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _listener.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    unawaited(
      ref.read(consoleSyncProvider.notifier).run().catchError((Object e) {
        debugPrint('Sync failed: $e');
        return null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      if (next.phase == SessionPhase.signedIn &&
          previous?.phase != SessionPhase.signedIn) {
        _sync();
      }
    });
    return widget.child;
  }
}
