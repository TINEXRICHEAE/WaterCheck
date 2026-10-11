// Picks the native (encrypted file) or web (in-memory) database opener.
export 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';
