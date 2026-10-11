/// WaterCheck API client. The clients and models under `src/generated` come
/// from `docs/api/openapi.yaml` (swagger_parser); only the signing interceptor
/// [GzipRequestInterceptor] and [ApiFailure] are hand-written.
library;

export 'src/api_failure.dart';
export 'src/generated/export.dart';
export 'src/gzip_request.dart';
export 'src/installation_signer.dart';
