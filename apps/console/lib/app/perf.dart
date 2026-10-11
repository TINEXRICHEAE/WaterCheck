import 'package:flutter/foundation.dart';

/// Timing marks for the P9 performance gate (tools/measure_web_dashboard.py).
/// Only on the web, and only when the page is opened with `?perf=1`.
final perfEnabled = kIsWeb && Uri.base.queryParameters.containsKey('perf');

final _sinceStart = Stopwatch()..start();
final _marked = <String>{};

/// Logs `wc-perf <name> ms=<since app start> ...` once per name.
void perfMark(String name, [Map<String, Object> extra = const {}]) {
  if (!perfEnabled || !_marked.add(name)) return;
  final details = extra.entries.map((e) => ' ${e.key}=${e.value}').join();
  debugPrint('wc-perf $name ms=${_sinceStart.elapsedMilliseconds}$details');
}
