import 'alert_status.dart';
import 'overall_status.dart';
import 'reading.dart';

/// The collector's self-declared identification, copied onto every
/// submission (SPEC §2.1). No national ID is ever collected.
class CollectorSnapshot {
  const CollectorSnapshot({
    required this.collectorKey,
    required this.profileVersion,
    required this.fullName,
    required this.phone,
    required this.collectorType,
    required this.village,
    required this.parish,
    required this.subcounty,
    required this.district,
    this.organisation,
  });

  factory CollectorSnapshot.fromJson(Map<String, Object?> json) =>
      CollectorSnapshot(
        collectorKey: json['collector_key']! as String,
        profileVersion: json['profile_version']! as int,
        fullName: json['full_name']! as String,
        phone: json['phone']! as String,
        collectorType: json['collector_type']! as String,
        village: json['village']! as String,
        parish: json['parish']! as String,
        subcounty: json['subcounty']! as String,
        district: json['district']! as String,
        organisation: json['organisation'] as String?,
      );

  Map<String, Object?> toJson() => {
    'collector_key': collectorKey,
    'profile_version': profileVersion,
    'full_name': fullName,
    'phone': phone,
    'collector_type': collectorType,
    'village': village,
    'parish': parish,
    'subcounty': subcounty,
    'district': district,
    'organisation': organisation,
  };

  /// Random UUID created with the profile; stable across edits.
  final String collectorKey;
  final int profileVersion;
  final String fullName;
  final String phone;
  final String collectorType;
  final String village;
  final String parish;
  final String subcounty;
  final String district;
  final String? organisation;
}

/// A GPS fix with its accuracy.
class GeoPoint {
  const GeoPoint({required this.lat, required this.lon, this.accuracyM});

  final double lat;
  final double lon;
  final double? accuracyM;
}

class WaterSource {
  const WaterSource({
    required this.id,
    required this.villageId,
    required this.code,
    required this.sourceType,
    required this.version,
    this.name,
    this.location,
    this.householdsServed,
    this.functionalStatus = 'functional',
    this.isActive = true,
  });

  final String id;
  final String villageId;

  /// `VILLAGECODE-NNN`, editable (F-SRC-1).
  final String code;
  final String? name;

  /// borehole, protected_spring, shallow_well, tap, rain_tank, other.
  final String sourceType;
  final GeoPoint? location;
  final int? householdsServed;
  final String functionalStatus;

  /// Sources are deactivated, never deleted (F-SRC-5).
  final bool isActive;

  /// Optimistic-concurrency version (SPEC §8.4).
  final int version;
}

/// One visit to test a source. Immutable once saved (SPEC §5.4).
class TestSession {
  const TestSession({
    required this.id,
    required this.sourceId,
    required this.installationId,
    required this.collector,
    required this.referenceProfileId,
    required this.calibrated,
    required this.testedAtDevice,
    this.calibrationId,
    this.testerProfileId,
    this.location,
    this.distanceFromSourceM,
    this.distanceOverrideReason,
    this.notes,
  });

  final String id;
  final String sourceId;
  final String installationId;
  final CollectorSnapshot collector;
  final String referenceProfileId;
  final bool calibrated;
  final DateTime testedAtDevice;
  final String? calibrationId;
  final String? testerProfileId;
  final GeoPoint? location;
  final double? distanceFromSourceM;
  final String? distanceOverrideReason;
  final String? notes;
}

/// A result with its own complete set of readings (ADR-005 §1). An
/// amendment is a new result with [amendmentOf] and a reason.
class TestResult {
  TestResult({
    required this.id,
    required this.sessionId,
    required this.standardId,
    required this.overall,
    required List<ReadingInput> readings,
    this.flags = const [],
    this.limitationCode,
    this.retestOf,
    this.amendmentOf,
    this.amendmentReason,
  }) : readings = List.unmodifiable(readings) {
    if (amendmentOf != null && (amendmentReason ?? '').trim().isEmpty) {
      throw ArgumentError.value(id, 'amendmentReason', 'Amendment needs one');
    }
  }

  final String id;
  final String sessionId;
  final String standardId;
  final OverallStatus overall;
  final List<ReadingInput> readings;
  final List<String> flags;
  final String? limitationCode;
  final String? retestOf;
  final String? amendmentOf;
  final String? amendmentReason;

  bool get isAmendment => amendmentOf != null;
}

class Alert {
  const Alert({
    required this.id,
    required this.sourceId,
    required this.triggerRule,
    required this.status,
    required this.openedAt,
    required this.version,
    this.triggerResultId,
    this.linkedAlertId,
  });

  final String id;
  final String sourceId;

  /// `unsafe`, `baseline_jump` or `ecoli`.
  final String triggerRule;
  final AlertStatus status;
  final DateTime openedAt;
  final int version;
  final String? triggerResultId;

  /// Set when an invalid offline transition reopened a closed alert
  /// (SPEC §8.4, errata G5).
  final String? linkedAlertId;
}
