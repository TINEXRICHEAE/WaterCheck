// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkOut _$LinkOutFromJson(Map<String, dynamic> json) => LinkOut(
  id: json['id'] as String,
  token: json['token'] as String,
  kind: json['kind'] as String,
  madeBy: json['made_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  active: json['active'] as bool,
);

Map<String, dynamic> _$LinkOutToJson(LinkOut instance) => <String, dynamic>{
  'id': instance.id,
  'token': instance.token,
  'kind': instance.kind,
  'made_by': instance.madeBy,
  'created_at': instance.createdAt.toIso8601String(),
  'active': instance.active,
};
