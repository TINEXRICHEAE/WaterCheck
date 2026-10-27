// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PictureOut _$PictureOutFromJson(Map<String, dynamic> json) => PictureOut(
  id: json['id'] as String,
  fieldName: json['field_name'] as String?,
  uploaded: json['uploaded'] as bool,
  takenLat: json['taken_lat'] as num?,
  takenLon: json['taken_lon'] as num?,
  takenAt: json['taken_at'] == null
      ? null
      : DateTime.parse(json['taken_at'] as String),
);

Map<String, dynamic> _$PictureOutToJson(PictureOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'field_name': instance.fieldName,
      'uploaded': instance.uploaded,
      'taken_lat': instance.takenLat,
      'taken_lon': instance.takenLon,
      'taken_at': instance.takenAt?.toIso8601String(),
    };
