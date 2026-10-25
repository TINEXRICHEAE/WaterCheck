import 'package:drift/drift.dart';

// Client tables: SPEC §5.3 minus server-only columns, plus ADR-005
// (reading.result_id, classifications, flags, is_derived, limitation_code)
// and the sync tables of §5.5. Exact decimals are stored as TEXT.
// Data classes end in `Row` so they never clash with domain entities.

/// Columns recording who submitted a record from Collect (SPEC §2.1, §5.2).
mixin CollectOrigin on Table {
  TextColumn get installationId => text().nullable()();
  TextColumn get collectorKey => text().nullable()();

  /// JSON copy of the collector profile at submission time.
  TextColumn get collectorSnapshot => text().nullable()();
}

/// Position in the server change feed; null until the record has synced.
mixin ServerSeq on Table {
  IntColumn get serverSeq => integer().nullable()();
}

// ---------------------------------------------------------------- reference

@DataClassName('AdminUnitRow')
class AdminUnits extends Table {
  TextColumn get id => text()();
  TextColumn get level => text()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  TextColumn get parentId => text().nullable().references(AdminUnits, #id)();

  /// Official UBOS/OCHA P-code (regions, districts, sub-counties). Added in v4.
  TextColumn get pcode => text().nullable()();

  /// Centre point, so the map can move to the chosen area. Added in v4.
  RealColumn get centerLat => real().nullable()();
  RealColumn get centerLon => real().nullable()();

  /// The limit set new tests here start with (D11, set by the IT admin;
  /// null: as the area above). Added in v5.
  TextColumn get defaultStandardId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ParameterCategoryRow')
class ParameterCategories extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get displayOrder => integer()();

  @override
  Set<Column> get primaryKey => {code};
}

@DataClassName('ParameterDefinitionRow')
class ParameterDefinitions extends Table with CollectOrigin, ServerSeq {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get categoryCode =>
      text().references(ParameterCategories, #code)();
  TextColumn get defaultUnit => text()();
  TextColumn get valueType => text()();
  BoolColumn get isCore => boolean().withDefault(const Constant(false))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  TextColumn get plausibleMin => text().nullable()();
  TextColumn get plausibleMax => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get scopeAdminUnitId => text().nullable()();
  TextColumn get reviewStatus =>
      text().withDefault(const Constant('approved'))();

  @override
  Set<Column> get primaryKey => {code};
}

@DataClassName('TesterProfileRow')
class TesterProfiles extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get tdsFactor => text().nullable()();

  /// JSON list of `{parameter_code, unit}`.
  TextColumn get parameters => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Reference profiles are immutable and versioned, so their limits are kept
/// as one JSON document (the seed format) rather than a child table.
@DataClassName('ReferenceProfileRow')
class ReferenceProfiles extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get title => text()();
  IntColumn get version => integer()();
  TextColumn get basedOnId => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get customReason => text().nullable()();
  BoolColumn get isProvisional =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get publishedAt => dateTime().nullable()();

  /// Full profile JSON as published (includes `limits`).
  TextColumn get document => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ResponseCardRow')
class ResponseCards extends Table with ServerSeq {
  TextColumn get id => text()();
  TextColumn get triggerRule => text()();
  TextColumn get audience => text()();
  IntColumn get version => integer()();

  /// JSON: title, actions (list), reportTo (list). English only (ADR-007).
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ResponsibilityRow')
class Responsibilities extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {code};
}

/// Key–value configuration documents (e.g. `rules`, `collector_types`).
@DataClassName('ConfigDocumentRow')
class ConfigDocuments extends Table {
  TextColumn get key => text()();
  TextColumn get document => text()();
  IntColumn get version => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Which bundled seed versions have been imported.
@DataClassName('SeedImportRow')
class SeedImports extends Table {
  TextColumn get name => text()();
  IntColumn get version => integer()();
  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {name};
}

// ------------------------------------------------------------ collect-local

/// Collector profiles on this phone (SPEC §2.1). Never synced themselves;
/// a snapshot travels with every submission.
@DataClassName('CollectorProfileRow')
class CollectorProfiles extends Table {
  TextColumn get collectorKey => text()();
  IntColumn get profileVersion => integer()();
  TextColumn get fullName => text()();
  TextColumn get phone => text()();
  TextColumn get collectorType => text()();
  TextColumn get village => text()();
  TextColumn get parish => text()();
  TextColumn get subcounty => text()();
  TextColumn get district => text()();
  TextColumn get organisation => text().nullable()();

  /// Added in v10 (ADR-024): optional, like the phone now.
  TextColumn get email => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {collectorKey};
}

// ------------------------------------------------------------------ domain

@DataClassName('WaterSourceRow')
class WaterSources extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get villageId => text()();
  TextColumn get code => text()();
  TextColumn get name => text().nullable()();
  TextColumn get sourceType => text()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  RealColumn get locationAccuracyM => real().nullable()();
  IntColumn get householdsServed => integer().nullable()();
  TextColumn get functionalStatus =>
      text().withDefault(const Constant('functional'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAtDevice => dateTime()();
  DateTimeColumn get updatedAtDevice => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {villageId, code},
  ];
}

@DataClassName('CalibrationRow')
class Calibrations extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get testerSerial => text().nullable()();
  TextColumn get testerProfileId => text().nullable()();
  TextColumn get referenceStandardId => text()();

  /// JSON list, e.g. `[{"ph": "7.00", "read": "7.02"}]`.
  TextColumn get buffers => text().nullable()();
  BoolColumn get passed => boolean()();
  DateTimeColumn get performedAtDevice => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TestSessionRow')
class TestSessions extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get sourceId => text().references(WaterSources, #id)();
  TextColumn get calibrationId => text().nullable()();
  TextColumn get testerProfileId => text().nullable()();
  TextColumn get referenceStandardId => text()();
  BoolColumn get calibrated => boolean()();
  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();
  RealColumn get locationAccuracyM => real().nullable()();
  RealColumn get distanceFromSourceM => real().nullable()();
  TextColumn get distanceOverrideReason => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Why the test has no picture of the kit or reading (ADR-022). Added
  /// in v7.
  TextColumn get noPhotoReason => text().nullable()();
  DateTimeColumn get testedAtDevice => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Each result owns a full set of readings; amendments are new results
/// (ADR-005 §1).
@DataClassName('TestResultRow')
/// An amendment (a correction) also records who made it (ADR-018); first
/// results leave these empty (their session says who).
class TestResults extends Table with ServerSeq, CollectOrigin {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(TestSessions, #id)();
  TextColumn get overall => text()();
  TextColumn get standardId => text()();
  TextColumn get computedBy => text().withDefault(const Constant('device'))();
  TextColumn get retestOf => text().nullable()();
  TextColumn get amendmentOf => text().nullable()();
  TextColumn get amendmentReason => text().nullable()();

  /// JSON list, e.g. `["uncalibrated", "baseline_jump:tds"]`.
  TextColumn get flags => text().withDefault(const Constant('[]'))();
  TextColumn get limitationCode => text().nullable()();
  DateTimeColumn get createdAtDevice => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReadingRow')
class Readings extends Table with ServerSeq {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(TestSessions, #id)();
  TextColumn get resultId => text().references(TestResults, #id)();
  TextColumn get parameterCode => text()();
  TextColumn get value => text().nullable()();
  BoolColumn get detected => boolean().nullable()();
  BoolColumn get acceptable => boolean().nullable()();
  TextColumn get valueText => text().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get result => text()();
  BoolColumn get isDerived => boolean().withDefault(const Constant(false))();
  TextColumn get sourceDevice => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Server and alternative-profile classifications (ADR-005 §2), pulled.
@DataClassName('ClassificationRow')
class Classifications extends Table {
  TextColumn get resultId => text()();
  TextColumn get standardId => text()();
  TextColumn get computedBy => text()();
  TextColumn get overall => text()();
  TextColumn get readingResults => text()();
  TextColumn get flags => text().withDefault(const Constant('[]'))();
  DateTimeColumn get computedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {resultId, standardId, computedBy};
}

@DataClassName('AlertRow')
class Alerts extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get sourceId => text().references(WaterSources, #id)();
  TextColumn get triggerResultId => text().nullable()();
  TextColumn get triggerRule => text()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get severity => text().withDefault(const Constant('high'))();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get acknowledgedAt => dateTime().nullable()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get linkedAlertId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {triggerResultId, triggerRule},
  ];
}

@DataClassName('AlertEventRow')
class AlertEvents extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get alertId => text().references(Alerts, #id)();
  TextColumn get actorId => text().nullable()();
  TextColumn get eventType => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get occurredAtDevice => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SanitaryInspectionRow')
class SanitaryInspections extends Table with CollectOrigin, ServerSeq {
  TextColumn get id => text()();
  TextColumn get sourceId => text().references(WaterSources, #id)();

  /// JSON map of checklist item code → answer.
  TextColumn get answers => text()();
  DateTimeColumn get inspectedAtDevice => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A stakeholder's judgement of a collector (P9): `known` or `flagged`.
/// Synced down to Console devices only. Added in v3.
@DataClassName('CollectorMarkRow')
class CollectorMarks extends Table with ServerSeq {
  TextColumn get collectorKey => text()();
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();
  TextColumn get markedBy => text().nullable()();
  DateTimeColumn get markedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {collectorKey};
}

/// A submission a stakeholder found suspicious (P9). Added in v3.
@DataClassName('SubmissionFlagRow')
class SubmissionFlags extends Table with ServerSeq {
  TextColumn get id => text()();
  TextColumn get resultId => text()();
  TextColumn get reason => text()();
  TextColumn get flaggedBy => text().nullable()();
  DateTimeColumn get createdAtDevice => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AttachmentRow')
class Attachments extends Table with ServerSeq {
  TextColumn get id => text()();
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text()();
  TextColumn get objectKey => text().nullable()();
  TextColumn get sha256 => text()();
  IntColumn get bytes => integer()();
  TextColumn get mime => text()();

  /// Who added it: only they may remove it (ADR-022). Added in v7.
  TextColumn get collectorKey => text().nullable()();

  /// Where and when it was taken (ADR-029), when the device had a fix.
  /// Added in v11.
  RealColumn get takenLat => real().nullable()();
  RealColumn get takenLon => real().nullable()();
  RealColumn get takenAccuracyM => real().nullable()();
  RealColumn get takenAltitudeM => real().nullable()();
  RealColumn get takenSpeedMps => real().nullable()();
  RealColumn get takenHeadingDeg => real().nullable()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  TextColumn get uploadStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

// -------------------------------------------------------------------- sync

/// Local queue of changes waiting to be pushed (SPEC §5.5, §8.1).
@DataClassName('OutboxRow')
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();

  /// `insert` or `update`.
  TextColumn get op => text()();
  TextColumn get payload => text()();
  IntColumn get baseVersion => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  /// `pending`, `sent` or `rejected` (never deleted, SPEC §8.1).
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

/// One row per pull stream, plus the `push` row for sending (v2).
@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get stream => text()();

  /// Unused since v2: the server's cursor is opaque text ([cursorToken]).
  IntColumn get cursor => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();

  /// The server's opaque pull cursor (ADR-011). Added in v2.
  TextColumn get cursorToken => text().nullable()();

  /// Consecutive failures, for exponential backoff (SPEC §8.1). Added in v2.
  IntColumn get failures => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {stream};
}

/// A lease that keeps two syncs from running at once, also across the
/// background worker and the app (SPEC §8.6). Added in v2.
@DataClassName('SyncLockRow')
class SyncLocks extends Table {
  TextColumn get name => text()();
  TextColumn get owner => text()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {name};
}

@DataClassName('AttachmentQueueRow')
class AttachmentQueue extends Table {
  TextColumn get attachmentId => text()();
  TextColumn get localPath => text()();
  IntColumn get bytesSent => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {attachmentId};
}

/// Records an IT admin archived (ADR-018). The device removes its copies of
/// archived records; a restore brings them back with the next full pull.
@DataClassName('ArchiveMarkRow')
class ArchiveMarks extends Table {
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  BoolColumn get archived => boolean()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {entity, recordId};
}

/// Who changed what, from what to what, and when (ADR-018). Values are JSON
/// text as the server sends them.
@DataClassName('ChangeTrailRow')
class ChangeTrails extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  TextColumn get field => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get actorName => text().nullable()();
  DateTimeColumn get changedAt => dateTime()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Conversations (ADR-022): messages in threads on a test, a source, a
/// collector or an area, between collectors and Console users. Insert-only;
/// [readAt] is this device's own and never synced. Added in v8.
@DataClassName('MessageRow')
class Messages extends Table {
  TextColumn get id => text()();

  /// `test`, `source`, `collector` or `area`.
  TextColumn get subjectType => text()();
  TextColumn get subjectId => text()();
  TextColumn get body => text()();
  TextColumn get authorUserId => text().nullable()();
  TextColumn get installationId => text().nullable()();
  TextColumn get collectorKey => text().nullable()();
  TextColumn get authorName => text().nullable()();
  DateTimeColumn get writtenAtDevice => dateTime().nullable()();
  DateTimeColumn get createdAtServer => dateTime().nullable()();
  DateTimeColumn get readAt => dateTime().nullable()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Names on the map (OpenStreetMap villages, hamlets, trading centres,
/// neighbourhoods) placed in the sub-county they lie in (ADR-023). Only
/// suggestions: picking one fills its sub-county and district. Not part
/// of the official area tree. Added in v9.
@DataClassName('PlaceNameRow')
class PlaceNames extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// The OpenStreetMap `place` value: village, hamlet, locality, town…
  TextColumn get kind => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  TextColumn get subcountyId => text()();

  /// A place someone added from the map (ADR-028): who, and when. Null for
  /// names from OpenStreetMap. Added in v11.
  TextColumn get addedByName => text().nullable()();
  DateTimeColumn get addedAt => dateTime().nullable()();
  IntColumn get serverSeq => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A trip followed live to a source or place (ADR-029). Kept on this
/// device only; never synced. Added in v11.
@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();

  /// The tester it belongs to; removed with their profile.
  TextColumn get collectorKey => text().nullable()();
  TextColumn get toName => text()();
  RealColumn get toLat => real()();
  RealColumn get toLon => real()();

  /// `car` or `foot`, as for routes.
  TextColumn get mode => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get arrived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The fixes of a trip, in order (ADR-029).
@DataClassName('TripPointRow')
class TripPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get at => dateTime()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  RealColumn get accuracyM => real().nullable()();
  RealColumn get altitudeM => real().nullable()();
  RealColumn get speedMps => real().nullable()();
  RealColumn get headingDeg => real().nullable()();
}
