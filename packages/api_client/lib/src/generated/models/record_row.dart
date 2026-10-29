// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'record_row.g.dart';

@JsonSerializable()
class RecordRow {
  const RecordRow({
    required this.id,
    required this.formId,
    required this.formCode,
    required this.formVersion,
    required this.number,
    required this.numberClash,
    required this.collector,
    required this.collectorKey,
    required this.startedAt,
    required this.finishedAt,
    required this.lat,
    required this.lon,
    required this.accuracyM,
    required this.declined,
    this.locationSource,
  });
  
  factory RecordRow.fromJson(Map<String, Object?> json) => _$RecordRowFromJson(json);
  
  final String id;
  @JsonKey(name: 'form_id')
  final String formId;
  @JsonKey(name: 'form_code')
  final String formCode;
  @JsonKey(name: 'form_version')
  final int formVersion;
  final String number;
  @JsonKey(name: 'number_clash')
  final bool numberClash;
  final String? collector;
  @JsonKey(name: 'collector_key')
  final String? collectorKey;
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @JsonKey(name: 'finished_at')
  final DateTime? finishedAt;
  final num? lat;
  final num? lon;
  @JsonKey(name: 'accuracy_m')
  final num? accuracyM;
  @JsonKey(name: 'location_source')
  final String? locationSource;
  final bool declined;

  Map<String, Object?> toJson() => _$RecordRowToJson(this);
}
