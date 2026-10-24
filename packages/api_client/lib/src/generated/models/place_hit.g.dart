// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_hit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceHit _$PlaceHitFromJson(Map<String, dynamic> json) => PlaceHit(
  id: json['id'] as String,
  name: json['name'] as String,
  kind: json['kind'] as String,
  source: json['source'] as String,
  lat: json['lat'] as num?,
  lon: json['lon'] as num?,
  subcountyId: json['subcounty_id'] as String?,
  subcounty: json['subcounty'] as String?,
  districtId: json['district_id'] as String?,
  district: json['district'] as String?,
);

Map<String, dynamic> _$PlaceHitToJson(PlaceHit instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'kind': instance.kind,
  'source': instance.source,
  'lat': instance.lat,
  'lon': instance.lon,
  'subcounty_id': instance.subcountyId,
  'subcounty': instance.subcounty,
  'district_id': instance.districtId,
  'district': instance.district,
};
