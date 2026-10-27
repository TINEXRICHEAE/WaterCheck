/// WaterCheck local data layer: the encrypted Drift database, repositories
/// (the only way screens reach data, ADR-001), the outbox and seed import.
library;

export 'src/api_location.dart';
export 'src/attachments/attachment_repository.dart';
export 'src/attachments/attachment_uploader.dart';
export 'src/attachments/photo_compressor.dart';
export 'src/attachments/photo_files.dart';
export 'src/dashboard/dashboard_queries.dart';
export 'src/db/connection.dart';
export 'src/db/database.dart'
    show
        AppDatabase,
        CollectorMarkRow,
        OutboxRow,
        ResearchDraftRow,
        ResearchRecordRow,
        SubmissionFlagRow,
        SyncStateRow;
export 'src/db/key_store.dart';
export 'src/reports/report_queries.dart';
export 'src/repositories/activity_queries.dart';
export 'src/repositories/alert_repository.dart';
export 'src/repositories/area_tree.dart';
export 'src/repositories/collector_profile_repository.dart';
export 'src/repositories/inspection_repository.dart';
export 'src/repositories/map_place_repository.dart';
export 'src/repositories/message_repository.dart';
export 'src/repositories/local_settings_repository.dart';
export 'src/repositories/outbox_repository.dart';
export 'src/repositories/place_repository.dart';
export 'src/repositories/reference_data_repository.dart';
export 'src/repositories/research_repository.dart';
export 'src/repositories/source_repository.dart';
export 'src/repositories/stakeholder_repository.dart';
export 'src/repositories/trail_queries.dart';
export 'src/repositories/support.dart'
    show Clock, IdGenerator, SubmissionOrigin, alertIdFor, systemClock;
export 'src/repositories/testing_repository.dart';
export 'src/repositories/trip_repository.dart';
export 'src/security/app_lock.dart';
export 'src/security/export_file.dart';
export 'src/security/installation_store.dart';
export 'src/security/pin_hash.dart';
export 'src/security/secure_values.dart';
export 'src/seed/seed_bundle.dart';
export 'src/sync/pull_applier.dart';
export 'src/sync/sync_service.dart';
export 'src/sync/sync_transport.dart';
export 'src/seed/seed_importer.dart';

/// Local database schema version (see `drift_schemas/`).
const int localSchemaVersion = 12;
