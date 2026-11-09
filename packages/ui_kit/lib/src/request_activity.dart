import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// Requests to the server running right now: drives the thin progress bar at
/// the top of the app, so anything that waits on the network shows it is
/// working, on slow connections too (2026-10-31: page loads as well as
/// changes, in both apps).
final requestsInFlight = ValueNotifier<int>(0);

/// The server said it is being updated (maintenance mode, ADR-035); clears
/// with the next answer that says otherwise.
final serverInMaintenance = ValueNotifier<bool>(false);

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
    serverInMaintenance.value = false;
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _done(err.requestOptions);
    // No answer at all says nothing either way.
    if (err.response case final r?) {
      final data = r.data;
      serverInMaintenance.value =
          r.statusCode == 503 && data is Map && data['detail'] == 'maintenance';
    }
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
  Widget build(BuildContext context) => Column(
    children: [
      const _MaintenanceBanner(),
      // Keyed: the app keeps its state when the banner comes and goes.
      Expanded(
        key: const ValueKey('app'),
        child: Stack(
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
        ),
      ),
    ],
  );
}

/// Above every page while the server is being updated.
class _MaintenanceBanner extends StatelessWidget {
  const _MaintenanceBanner();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: serverInMaintenance,
    builder: (context, on, _) {
      if (!on) return const SizedBox.shrink();
      final scheme = Theme.of(context).colorScheme;
      return Semantics(
        liveRegion: true,
        child: Material(
          color: scheme.tertiaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.construction, color: scheme.onTertiaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      UiKitLocalizations.of(context).maintenanceBanner,
                      style: TextStyle(color: scheme.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
