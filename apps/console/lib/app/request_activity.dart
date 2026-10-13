import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Changes being sent to the server right now (not background sync): drives
/// the thin progress bar at the top of the window, so every action that
/// waits on the server shows it is working, even from a closed dialog.
final requestsInFlight = ValueNotifier<int>(0);

class RequestActivityInterceptor extends Interceptor {
  static bool _counts(RequestOptions o) =>
      o.method != 'GET' && !o.path.startsWith('/v1/sync/');

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

/// The bar itself, over the top edge of the app.
class RequestActivityBar extends StatelessWidget {
  const RequestActivityBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: ValueListenableBuilder<int>(
          valueListenable: requestsInFlight,
          builder: (context, n, _) => n == 0
              ? const SizedBox.shrink()
              : Semantics(
                  liveRegion: true,
                  label: MaterialLocalizations.of(context)
                      .refreshIndicatorSemanticLabel,
                  child: const LinearProgressIndicator(minHeight: 3),
                ),
        ),
      ),
    ],
  );
}
