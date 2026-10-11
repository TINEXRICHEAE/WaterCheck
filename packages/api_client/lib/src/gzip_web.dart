/// Browsers have no synchronous gzip encoder here; the web Console sends
/// small requests uncompressed.
List<int>? gzipBytes(List<int> bytes) => null;
