import 'dart:typed_data';

import 'save_file_io.dart'
    if (dart.library.js_interop) 'save_file_web.dart'
    as impl;

/// Saves a report or export. Web: a browser download. Windows/Android: the
/// system "save as" dialog. Returns the file name, or null if cancelled.
Future<String?> saveFile(String name, Uint8List bytes, String mime) =>
    impl.saveFile(name, bytes, mime);
