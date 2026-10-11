import 'dart:io' show gzip;

/// Compresses a request body (Android, Windows).
List<int>? gzipBytes(List<int> bytes) => gzip.encode(bytes);
