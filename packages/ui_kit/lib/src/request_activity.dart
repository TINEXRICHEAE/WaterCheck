import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Requests to the server running right now: drives the thin progress bar at
/// the top of the app, so anything that waits on the network shows it is
/// working, on slow connections too (2026-10-31: page loads as well as
/// changes, in both apps).
final requestsInFlight = ValueNotifier<int>(0);

/// Shows the bar while [work] runs: work that loads data without a single
/// request to count, such as a sync of many pages.
Future<T> showingActivity<T>(Future<T> Function() work) async {
  requestsInFlight.value++;
  try {
    return await work();
  } finally {
    if (requestsInFlight.value > 0) requestsInFlight.value--;
  }
}

/// Counts each request of the Dio it is added to. Background sync and the
/// chats' own refreshes are left out: they run on a timer and show their
/// own state.
class RequestActivityInterceptor extends Interceptor {
  static bool _counts(RequestOptions o) =>
      !o.path.contains('/v1/sync/') &&
      !(o.method == 'GET' && o.path.contains('/chats'));

  void _done(RequestOptions o) {
    if (_counts(o) && requestsInFlight.value > 0) requestsInFlight.value--;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_counts(options)) requestsInFlight.value++;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _done(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _done(err.requestOptions);
    handler.next(err);
  }
}

/// The bar itself, over the top edge of the app. It shows only once a
/// request has taken longer than [after], so quick ones do not flicker.
class RequestActivityBar extends StatefulWidget {
  const RequestActivityBar({
    super.key,
    required this.child,
    this.after = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Duration after;

  @override
  State<RequestActivityBar> createState() => _RequestActivityBarState();
}

class _RequestActivityBarState extends State<RequestActivityBar> {
  Timer? _wait;
  var _shown = false;

  @override
  void initState() {
    super.initState();
    requestsInFlight.addListener(_changed);
    _changed();
  }

  @override
  void dispose() {
    requestsInFlight.removeListener(_changed);
    _wait?.cancel();
    super.dispose();
  }

  void _changed() {
    if (requestsInFlight.value == 0) {
      _wait?.cancel();
      _wait = null;
      if (_shown) setState(() => _shown = false);
    } else if (!_shown && _wait == null) {
      _wait = Timer(widget.after, () {
        _wait = null;
        if (mounted && requestsInFlight.value > 0) {
          setState(() => _shown = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (_shown)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Semantics(
            liveRegion: true,
            label: MaterialLocalizations.of(context)
                .refreshIndicatorSemanticLabel,
            child: const LinearProgressIndicator(minHeight: 3),
          ),
        ),
    ],
  );
}
