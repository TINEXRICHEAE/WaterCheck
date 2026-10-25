import 'dart:js_interop';

@JS('wcCanInstall')
external JSBoolean _canInstall();

@JS('wcInstall')
external JSPromise<JSBoolean> _install();

@JS('wcIsIosBrowser')
external JSBoolean _isIosBrowser();

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

/// iPhone or iPad Safari, not yet added to the Home Screen: no install
/// prompt there, only Share › Add to Home Screen.
bool pwaIsIosBrowser() {
  try {
    return _isIosBrowser().toDart;
  } catch (_) {
    return false;
  }
}
