// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointOut _$PointOutFromJson(Map<String, dynamic> json) => PointOut(
  id: json['id'] as String,
  number: json['number'] as String,
  formCode: json['form_code'] as String,
  lat: json['lat'] as num,
  lon: json['lon'] as num,
  at: json['at'] == null ? null : DateTime.parse(json['at'] as String),
  collector: json['collector'] as String?,
);

Map<String, dynamic> _$PointOutToJson(PointOut instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'form_code': instance.formCode,
  'lat': instance.lat,
  'lon': instance.lon,
  'at': instance.at?.toIso8601String(),
  'collector': instance.collector,
};
