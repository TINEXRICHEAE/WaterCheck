// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Health _$HealthFromJson(Map<String, dynamic> json) => Health(
  database: json['database'] as bool,
  workerLastJobAt: json['worker_last_job_at'] == null
      ? null
      : DateTime.parse(json['worker_last_job_at'] as String),
  jobsQueued: (json['jobs_queued'] as num).toInt(),
  jobsOverdue: (json['jobs_overdue'] as num).toInt(),
  jobsFailed24h: (json['jobs_failed_24h'] as num).toInt(),
  notificationsFailed24h: (json['notifications_failed_24h'] as num).toInt(),
  phonesActive7d: (json['phones_active_7d'] as num).toInt(),
  phonesTotal: (json['phones_total'] as num).toInt(),
  appVersions: Map<String, int>.from(json['app_versions'] as Map),
  recordsReceived24h: (json['records_received_24h'] as num).toInt(),
  syncConflictsOpen: (json['sync_conflicts_open'] as num).toInt(),
  photos: (json['photos'] as num).toInt(),
  photoBytes: (json['photo_bytes'] as num).toInt(),
  lastBackupAt: json['last_backup_at'] == null
      ? null
      : DateTime.parse(json['last_backup_at'] as String),
);

Map<String, dynamic> _$HealthToJson(Health instance) => <String, dynamic>{
  'database': instance.database,
  'worker_last_job_at': instance.workerLastJobAt?.toIso8601String(),
  'jobs_queued': instance.jobsQueued,
  'jobs_overdue': instance.jobsOverdue,
  'jobs_failed_24h': instance.jobsFailed24h,
  'notifications_failed_24h': instance.notificationsFailed24h,
  'phones_active_7d': instance.phonesActive7d,
  'phones_total': instance.phonesTotal,
  'app_versions': instance.appVersions,
  'records_received_24h': instance.recordsReceived24h,
  'sync_conflicts_open': instance.syncConflictsOpen,
  'photos': instance.photos,
  'photo_bytes': instance.photoBytes,
  'last_backup_at': instance.lastBackupAt?.toIso8601String(),
};
