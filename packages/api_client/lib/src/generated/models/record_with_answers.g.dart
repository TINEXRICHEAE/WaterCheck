// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_with_answers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordWithAnswers _$RecordWithAnswersFromJson(Map<String, dynamic> json) =>
    RecordWithAnswers(
      id: json['id'] as String,
      formId: json['form_id'] as String,
      formCode: json['form_code'] as String,
      formVersion: (json['form_version'] as num).toInt(),
      number: json['number'] as String,
      numberClash: json['number_clash'] as bool,
      collector: json['collector'] as String?,
      collectorKey: json['collector_key'] as String?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      lat: json['lat'] as num?,
      lon: json['lon'] as num?,
      accuracyM: json['accuracy_m'] as num?,
      declined: json['declined'] as bool,
      endLat: json['end_lat'] as num?,
      endLon: json['end_lon'] as num?,
      answers: json['answers'],
      pictures: (json['pictures'] as num).toInt(),
    );

Map<String, dynamic> _$RecordWithAnswersToJson(RecordWithAnswers instance) =>
    <String, dynamic>{
      'id': instance.id,
      'form_id': instance.formId,
      'form_code': instance.formCode,
      'form_version': instance.formVersion,
      'number': instance.number,
      'number_clash': instance.numberClash,
      'collector': instance.collector,
      'collector_key': instance.collectorKey,
      'started_at': instance.startedAt?.toIso8601String(),
      'finished_at': instance.finishedAt?.toIso8601String(),
      'lat': instance.lat,
      'lon': instance.lon,
      'accuracy_m': instance.accuracyM,
      'declined': instance.declined,
      'end_lat': instance.endLat,
      'end_lon': instance.endLon,
      'answers': instance.answers,
      'pictures': instance.pictures,
    };
