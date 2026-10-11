// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tiles_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TilesInfo _$TilesInfoFromJson(Map<String, dynamic> json) => TilesInfo(
  name: json['name'] as String,
  format: json['format'] as String,
  minzoom: (json['minzoom'] as num).toInt(),
  maxzoom: (json['maxzoom'] as num).toInt(),
  bounds: json['bounds'] as String?,
  attribution: json['attribution'] as String?,
  bytes: (json['bytes'] as num).toInt(),
);

Map<String, dynamic> _$TilesInfoToJson(TilesInfo instance) => <String, dynamic>{
  'name': instance.name,
  'format': instance.format,
  'minzoom': instance.minzoom,
  'maxzoom': instance.maxzoom,
  'bounds': instance.bounds,
  'attribution': instance.attribution,
  'bytes': instance.bytes,
};
