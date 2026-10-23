import 'dart:js_interop';

@JS('wcCanInstall')
external JSBoolean _canInstall();

@JS('wcInstall')
external JSPromise<JSBoolean> _install();

/// Whether the browser offers to install this web app now (index.html
/// keeps its install prompt).
bool pwaCanInstall() {
  try {
    return _canInstall().toDart;
  } catch (_) {
    return false;
  }
}

/// Shows the browser's install prompt; true when accepted.
Future<bool> pwaInstall() async {
  try {
    return (await _install().toDart).toDart;
  } catch (_) {
    return false;
  }
}
