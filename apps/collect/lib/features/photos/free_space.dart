import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'free_space_windows.dart'
    if (dart.library.js_interop) 'free_space_web.dart';

/// Below this much free storage, photos are refused so readings can still
/// be saved (SPEC P7, chaos test #7).
const minFreeBytesForPhotos = 100 * 1024 * 1024;

abstract interface class FreeSpace {
  /// Free bytes for the app's own files, or null if unknown.
  Future<int?> bytes();
}

class DeviceFreeSpace implements FreeSpace {
  static const _channel = MethodChannel('watercheck/storage');

  @override
  Future<int?> bytes() async {
    if (kIsWeb) return null;
    try {
      return switch (defaultTargetPlatform) {
        TargetPlatform.android => await _channel.invokeMethod<int>('freeBytes'),
        TargetPlatform.windows => await windowsFreeBytes(),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }
}
