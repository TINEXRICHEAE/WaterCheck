import 'package:flutter/foundation.dart';

/// Where the API is, unless changed by the user (Collect's activation
/// screen). Production builds pass `--dart-define=WC_API_URL=https://…/api`.
String defaultApiUrl() {
  // Web is served by the same Caddy as the API (single origin, P0), on
  // whichever name it was opened (fieldquire…, watercheck.fieldquire…,
  // research.fieldquire…): never a fixed address (2026-10-27).
  if (kIsWeb) return '${Uri.base.origin}/api';
  const configured = String.fromEnvironment('WC_API_URL');
  if (configured.isNotEmpty) return configured;
  // The Android emulator reaches the development machine at 10.0.2.2.
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2/api';
  }
  return 'http://localhost/api';
}
