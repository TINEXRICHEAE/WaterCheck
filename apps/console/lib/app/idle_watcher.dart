import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session.dart';

/// Ends (web) or locks (Windows/Android) a signed-in session after
/// [timeout] without taps, mouse or keys (F-AUTH-3). Without [timeout], the
/// IT admin's setting from the server applies (P11), else [idleTimeout].
class IdleWatcher extends ConsumerStatefulWidget {
  const IdleWatcher({super.key, required this.child, this.timeout});

  final Widget child;
  final Duration? timeout;

  @override
  ConsumerState<IdleWatcher> createState() => _IdleWatcherState();
}

class _IdleWatcherState extends ConsumerState<IdleWatcher> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent _) {
    _restart();
    return false;
  }

  void _restart() {
    _timer?.cancel();
    final minutes = ref.read(sessionProvider).me?.consoleIdleMinutes;
    _timer = Timer(
      widget.timeout ??
          (minutes == null ? idleTimeout : Duration(minutes: minutes)),
      () => ref.read(sessionProvider.notifier).idle(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Any sign-in restarts the clock.
    ref.listen(sessionProvider, (previous, next) {
      if (previous?.phase != next.phase) _restart();
    });
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerHover: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}
