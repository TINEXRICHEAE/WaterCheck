// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'health.g.dart';

@JsonSerializable()
class Health {
  const Health({
    required this.database,
    required this.workerLastJobAt,
    required this.jobsQueued,
    required this.jobsOverdue,
    required this.jobsFailed24h,
    required this.notificationsFailed24h,
    required this.phonesActive7d,
    required this.phonesTotal,
    required this.appVersions,
    required this.recordsReceived24h,
    required this.syncConflictsOpen,
    required this.photos,
    required this.photoBytes,
    required this.lastBackupAt,
  });
  
  factory Health.fromJson(Map<String, Object?> json) => _$HealthFromJson(json);
  
  final bool database;
  @JsonKey(name: 'worker_last_job_at')
  final DateTime? workerLastJobAt;
  @JsonKey(name: 'jobs_queued')
  final int jobsQueued;
  @JsonKey(name: 'jobs_overdue')
  final int jobsOverdue;
  @JsonKey(name: 'jobs_failed_24h')
  final int jobsFailed24h;
  @JsonKey(name: 'notifications_failed_24h')
  final int notificationsFailed24h;
  @JsonKey(name: 'phones_active_7d')
  final int phonesActive7d;
  @JsonKey(name: 'phones_total')
  final int phonesTotal;
  @JsonKey(name: 'app_versions')
  final Map<String, int> appVersions;
  @JsonKey(name: 'records_received_24h')
  final int recordsReceived24h;
  @JsonKey(name: 'sync_conflicts_open')
  final int syncConflictsOpen;
  final int photos;
  @JsonKey(name: 'photo_bytes')
  final int photoBytes;
  @JsonKey(name: 'last_backup_at')
  final DateTime? lastBackupAt;

  Map<String, Object?> toJson() => _$HealthToJson(this);
}
