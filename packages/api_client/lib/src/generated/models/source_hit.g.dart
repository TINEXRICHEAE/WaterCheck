// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_hit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceHit _$SourceHitFromJson(Map<String, dynamic> json) => SourceHit(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String?,
  villageId: json['village_id'] as String,
  village: json['village'] as String,
  districtId: json['district_id'] as String?,
  district: json['district'] as String?,
  lat: json['lat'] as num?,
  lon: json['lon'] as num?,
  latest: json['latest'] as String?,
);

Map<String, dynamic> _$SourceHitToJson(SourceHit instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'village_id': instance.villageId,
  'village': instance.village,
  'district_id': instance.districtId,
  'district': instance.district,
  'lat': instance.lat,
  'lon': instance.lon,
  'latest': instance.latest,
};
