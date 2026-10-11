import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';

typedef _GetDiskFreeSpaceExNative = Int32 Function(
  Pointer<Utf16> directory,
  Pointer<Uint64> freeBytesAvailable,
  Pointer<Uint64> totalBytes,
  Pointer<Uint64> totalFreeBytes,
);
typedef _GetDiskFreeSpaceEx = int Function(
  Pointer<Utf16> directory,
  Pointer<Uint64> freeBytesAvailable,
  Pointer<Uint64> totalBytes,
  Pointer<Uint64> totalFreeBytes,
);

/// Free bytes on the drive holding the app's data (kernel32).
Future<int?> windowsFreeBytes() async {
  final dir = (await getApplicationSupportDirectory()).path;
  final kernel32 = DynamicLibrary.open('kernel32.dll');
  final getFree = kernel32
      .lookupFunction<_GetDiskFreeSpaceExNative, _GetDiskFreeSpaceEx>(
        'GetDiskFreeSpaceExW',
      );
  final path = dir.toNativeUtf16();
  final free = calloc<Uint64>();
  try {
    return getFree(path, free, nullptr, nullptr) == 0 ? null : free.value;
  } finally {
    calloc
      ..free(path)
      ..free(free);
  }
}
