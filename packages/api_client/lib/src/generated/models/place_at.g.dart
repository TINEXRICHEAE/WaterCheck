// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_at.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceAt _$PlaceAtFromJson(Map<String, dynamic> json) => PlaceAt(
  subcountyId: json['subcounty_id'] as String,
  subcounty: json['subcounty'] as String,
  districtId: json['district_id'] as String?,
  district: json['district'] as String?,
);

Map<String, dynamic> _$PlaceAtToJson(PlaceAt instance) => <String, dynamic>{
  'subcounty_id': instance.subcountyId,
  'subcounty': instance.subcounty,
  'district_id': instance.districtId,
  'district': instance.district,
};
