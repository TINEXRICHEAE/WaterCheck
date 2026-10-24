// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_request_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaRequestIn _$AreaRequestInFromJson(Map<String, dynamic> json) =>
    AreaRequestIn(
      areaIds: (json['area_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$AreaRequestInToJson(AreaRequestIn instance) =>
    <String, dynamic>{'area_ids': instance.areaIds, 'reason': instance.reason};
